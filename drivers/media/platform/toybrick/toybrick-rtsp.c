/*
 * toybrick-rtsp.c
 *
 * Copyright (C) Rockchip Electronics Co.Ltd
 *
 * This file is licensed under the terms of the GNU General Public License
 * version 2. This program is licensed "as is" without any warranty of any
 * kind, whether express or implied.
 *
 * Leveraged code from the OMAP2 camera driver
 * Video-for-Linux (Version 2) camera capture driver for
 * the OMAP24xx camera controller.
 *
 * Author: Addy Ke (addy.ke@rock-chips.com)
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/vmalloc.h>
#include <linux/sched.h>
#include <linux/types.h>
#include <linux/platform_device.h>
#include <linux/irq.h>
#include <linux/videodev2.h>
#include <linux/dma-mapping.h>
#include <linux/slab.h>
#include <linux/kthread.h>
#include <linux/freezer.h>
#include <linux/delay.h>

#include <media/videobuf-dma-contig.h>
#include <media/v4l2-device.h>
#include <media/v4l2-ioctl.h>

#include <linux/fs.h>
#include <linux/uaccess.h>

#include "android_rga.h"

struct buffer_state {
	int				index;
	bool				data_ready;
};

struct toybrick_rtsp_device;
struct toybrick_rtsp {
	struct v4l2_device 		v4l2_dev;
	struct toybrick_rtsp_device 	*vcap;
	struct toybrick_rtsp_device 	*vout;

	struct buffer_state		state[VIDEO_MAX_FRAME];

	struct task_struct              *kthread;

	struct file			*fp;
};

struct toybrick_rtsp_device {
	struct toybrick_rtsp 		*rtsp;
	struct video_device 		*vfd;
	enum v4l2_buf_type              type;
	struct v4l2_capability		cap;

	struct videobuf_buffer 		*cur_frm;

	int 				opened;
	int				streaming;
	int				mmap_count;

	struct list_head 		queue;
	spinlock_t			vbq_lock;
	struct videobuf_queue 		vbq;

	struct v4l2_pix_format 		pix;
	u32				buffer_size;
	u32				buffer_allocated;
	unsigned long 			buf_virt_addr[VIDEO_MAX_FRAME];
	unsigned long 			buf_phys_addr[VIDEO_MAX_FRAME];
};

struct toybrick_rtsp_fmt {
	char *desc;
	u32 format;
	int depth;
};

/* Driver Configuration macros */
#define RTSP_NAME		"toybrick_rtsp"

#define VCAP_NAME		"rtsp_vcap"
#define VOUT_NAME		"rtsp_vout"

#define RTSP_WIDTH		1920
#define RTSP_HEIGHT		1080

#define NUM_BUFFERS		4

#define TRACE_ENTER(vdev, level)	v4l2_dbg(level, debug, (vdev)->vfd, "Entering %s\n", __func__)
#define TRACE_EXIT(vdev, level)		v4l2_dbg(level, debug, (vdev)->vfd, "Exit %s\n", __func__)

static unsigned int debug = 2;
module_param(debug, int, 0644);
MODULE_PARM_DESC(debug, "Debug level (0-1)");

static const struct toybrick_rtsp_fmt toybrick_formats[] = {
	{
		.desc = "Y/CbCr 4:2:0",
		.format = V4L2_PIX_FMT_NV12,
		.depth = 12,
	},
};

static const struct v4l2_frmsize_discrete toybrick_vcap_sizes[] = {
	{  320, 180 },
	{  640, 360 },
	{ 1280, 720 },
	{ 1920, 1080 },
};

static const struct v4l2_fract toybrick_vcap_intervals[] = {
	{  1, 2 },
	{  1, 5 },
	{  1, 10 },
	{  1, 15 },
	{  1, 25 },
	{  1, 30 },
	{  1, 50 },
	{  1, 60 },
};

static const int sinaTable[360] = {
	0,   1144,   2287,   3430,   4572,   5712,   6850,   7987,   9121,  10252,
	11380,  12505,  13626,  14742,  15855,  16962,  18064,  19161,  20252,  21336,
	22415,  23486,  24550,  25607,  26656,  27697,  28729,  29753,  30767,  31772,
	32768,  33754,  34729,  35693,  36647,  37590,  38521,  39441,  40348,  41243,
	42126,  42995,  43852,  44695,  45525,  46341,  47143,  47930,  48703,  49461,
	50203,  50931,  51643,  52339,  53020,  53684,  54332,  54963,  55578,  56175,
	56756,  57319,  57865,  58393,  58903,  59396,  59870,  60326,  60764,  61183,
	61584,  61966,  62328,  62672,  62997,  63303,  63589,  63856,  64104,  64332,
	64540,  64729,  64898,  65048,  65177,  65287,  65376,  65446,  65496,  65526,
	65536,  65526,  65496,  65446,  65376,  65287,  65177,  65048,  64898,  64729,
	64540,  64332,  64104,  63856,  63589,  63303,  62997,  62672,  62328,  61966,
	61584,  61183,  60764,  60326,  59870,  59396,  58903,  58393,  57865,  57319,
	56756,  56175,  55578,  54963,  54332,  53684,  53020,  52339,  51643,  50931,
	50203,  49461,  48703,  47930,  47143,  46341,  45525,  44695,  43852,  42995,
	42126,  41243,  40348,  39441,  38521,  37590,  36647,  35693,  34729,  33754,
	32768,  31772,  30767,  29753,  28729,  27697,  26656,  25607,  24550,  23486,
	22415,  21336,  20252,  19161,  18064,  16962,  15855,  14742,  13626,  12505,
	11380,  10252,   9121,   7987,   6850,   5712,   4572,   3430,   2287,   1144,
	0,  -1144,  -2287,  -3430,  -4572,  -5712,  -6850,  -7987,  -9121, -10252,
	-11380, -12505, -13626, -14742, -15855, -16962, -18064, -19161, -20252, -21336,
	-22415, -23486, -24550, -25607, -26656, -27697, -28729, -29753, -30767, -31772,
	-32768, -33754, -34729, -35693, -36647, -37590, -38521, -39441, -40348, -41243,
	-42126, -42995, -43852, -44695, -45525, -46341, -47143, -47930, -48703, -49461,
	-50203, -50931, -51643, -52339, -53020, -53684, -54332, -54963, -55578, -56175,
	-56756, -57319, -57865, -58393, -58903, -59396, -59870, -60326, -60764, -61183,
	-61584, -61966, -62328, -62672, -62997, -63303, -63589, -63856, -64104, -64332,
	-64540, -64729, -64898, -65048, -65177, -65287, -65376, -65446, -65496, -65526,
	-65536, -65526, -65496, -65446, -65376, -65287, -65177, -65048, -64898, -64729,
	-64540, -64332, -64104, -63856, -63589, -63303, -62997, -62672, -62328, -61966,
	-61584, -61183, -60764, -60326, -59870, -59396, -58903, -58393, -57865, -57319,
	-56756, -56175, -55578, -54963, -54332, -53684, -53020, -52339, -51643, -50931,
	-50203, -49461, -48703, -47930, -47143, -46341, -45525, -44695, -43852, -42995,
	-42126, -41243, -40348, -39441, -38521, -37590, -36647, -35693, -34729, -33754,
	-32768, -31772, -30767, -29753, -28729, -27697, -26656, -25607, -24550, -23486,
	-22415, -21336, -20252, -19161, -18064, -16962, -15855, -14742, -13626, -12505,
	-11380, -10252, -9121,   -7987,  -6850,  -5712,  -4572,  -3430,  -2287,  -1144
};

static const int cosaTable[360] = {
	65536,  65526,  65496,  65446,  65376,  65287,  65177,  65048,  64898,  64729,
	64540,  64332,  64104,  63856,  63589,  63303,  62997,  62672,  62328,  61966,
	61584,  61183,  60764,  60326,  59870,  59396,  58903,  58393,  57865,  57319,
	56756,  56175,  55578,  54963,  54332,  53684,  53020,  52339,  51643,  50931,
	50203,  49461,  48703,  47930,  47143,  46341,  45525,  44695,  43852,  42995,
	42126,  41243,  40348,  39441,  38521,  37590,  36647,  35693,  34729,  33754,
	32768,  31772,  30767,  29753,  28729,  27697,  26656,  25607,  24550,  23486,
	22415,  21336,  20252,  19161,  18064,  16962,  15855,  14742,  13626,  12505,
	11380,  10252,   9121,   7987,   6850,   5712,   4572,   3430,   2287,   1144,
	0,  -1144,  -2287,  -3430,  -4572,  -5712,  -6850,  -7987,  -9121, -10252,
	-11380, -12505, -13626, -14742, -15855, -16962, -18064, -19161, -20252, -21336,
	-22415, -23486, -24550, -25607, -26656, -27697, -28729, -29753, -30767, -31772,
	-32768, -33754, -34729, -35693, -36647, -37590, -38521, -39441, -40348, -41243,
	-42126, -42995, -43852, -44695, -45525, -46341, -47143, -47930, -48703, -49461,
	-50203, -50931, -51643, -52339, -53020, -53684, -54332, -54963, -55578, -56175,
	-56756, -57319, -57865, -58393, -58903, -59396, -59870, -60326, -60764, -61183,
	-61584, -61966, -62328, -62672, -62997, -63303, -63589, -63856, -64104, -64332,
	-64540, -64729, -64898, -65048, -65177, -65287, -65376, -65446, -65496, -65526,
	-65536, -65526, -65496, -65446, -65376, -65287, -65177, -65048, -64898, -64729,
	-64540, -64332, -64104, -63856, -63589, -63303, -62997, -62672, -62328, -61966,
	-61584, -61183, -60764, -60326, -59870, -59396, -58903, -58393, -57865, -57319,
	-56756, -56175, -55578, -54963, -54332, -53684, -53020, -52339, -51643, -50931,
	-50203, -49461, -48703, -47930, -47143, -46341, -45525, -44695, -43852, -42995,
	-42126, -41243, -40348, -39441, -38521, -37590, -36647, -35693, -34729, -33754,
	-32768, -31772, -30767, -29753, -28729, -27697, -26656, -25607, -24550, -23486,
	-22415, -21336, -20252, -19161, -18064, -16962, -15855, -14742, -13626, -12505,
	-11380, -10252,  -9121,  -7987,  -6850,  -5712,  -4572,  -3430,  -2287,  -1144,
	0,   1144,   2287,   3430,   4572,   5712,   6850,   7987,   9121,  10252,
	11380,  12505,  13626,  14742,  15855,  16962,  18064,  19161,  20252,  21336,
	22415,  23486,  24550,  25607,  26656,  27697,  28729,  29753,  30767,  31772,
	32768,  33754,  34729,  35693,  36647,  37590,  38521,  39441,  40348,  41243,
	42126,  42995,  43852,  44695,  45525,  46341,  47143,  47930,  48703,  49461,
	50203,  50931,  51643,  52339,  53020,  53684,  54332,  54963,  55578,  56175,
	56756,  57319,  57865,  58393,  58903,  59396,  59870,  60326,  60764,  61183,
	61584,  61966,  62328,  62672,  62997,  63303,  63589,  63856,  64104,  64332,
	64540,  64729,  64898,  65048,  65177,  65287,  65376,  65446,  65496,  65526
};

static RgaSURF_FORMAT
V4l2ToRgaFormat(__u32 v4l2Format) {
	switch(v4l2Format) {
	case V4L2_PIX_FMT_ARGB32:
		return RK_FORMAT_RGBA_8888;
	case V4L2_PIX_FMT_RGB24:
		return RK_FORMAT_RGB_888;
	case V4L2_PIX_FMT_BGR24:
		return RK_FORMAT_BGR_888;
	case V4L2_PIX_FMT_ABGR32:
		return RK_FORMAT_BGRA_8888;
	case V4L2_PIX_FMT_RGB565:
		return RK_FORMAT_RGB_565;
	case V4L2_PIX_FMT_NV21:
		return RK_FORMAT_YCrCb_420_SP;
	case V4L2_PIX_FMT_NV12:
		return RK_FORMAT_YCbCr_420_SP;
	case V4L2_PIX_FMT_YUV420:
		return RK_FORMAT_YCbCr_420_P;
	case V4L2_PIX_FMT_NV16:
		return RK_FORMAT_YCrCb_422_SP;

	default:
		return RK_FORMAT_UNKNOWN;
	}
}

static int toybrick_rga_convert(struct toybrick_rtsp *rtsp,
				unsigned long src_phys, unsigned long dst_phys,
				struct v4l2_pix_format src_pix,
				struct v4l2_pix_format dst_pix)
{
	int ret = -ENODEV;
	struct rga_req req;
	u32 stretch, scaleMode, orientation;

	if(!rtsp->fp) {
		v4l2_err(&rtsp->v4l2_dev, "RGA device is not ready\n");
		return -ENODEV;
	}
	v4l2_dbg(1, debug, &rtsp->v4l2_dev, "SRC: %ux%u, addr 0x%lx, DST: %ux%u, 0x%lx\n",
			src_pix.width, src_pix.height, src_phys,
			dst_pix.width, dst_pix.height, dst_phys);

	memset(&req, 0, sizeof(struct rga_req));

	if((src_pix.width > (16 * dst_pix.width)) ||
	   (dst_pix.width > (16 * src_pix.width)) ||
	   (src_pix.height > (16 * dst_pix.height)) ||
	   (dst_pix.height > (16 * src_pix.height))) {
		v4l2_err(&rtsp->v4l2_dev, "Scal should less than 16 and greate than 1/16\n");
		return -EINVAL;
	}

	scaleMode = 0;
	stretch = (src_pix.width != dst_pix.width) || (src_pix.height != dst_pix.height);
	if (src_pix.width < dst_pix.width || src_pix.height < dst_pix.height)
		scaleMode = 2;
	orientation = stretch;

	req.src.uv_addr  = (unsigned long)src_phys;
	req.src.vir_w = src_pix.width;
	req.src.vir_h = src_pix.height;
	req.src.format = V4l2ToRgaFormat(src_pix.pixelformat);
	req.src.alpha_swap = 0;
	req.src.act_w = src_pix.width;
	req.src.act_h = src_pix.height;
	req.src.x_offset = 0;
	req.src.y_offset = 0;

	req.dst.uv_addr  = (unsigned long)dst_phys;
	req.dst.vir_w = dst_pix.width;
	req.dst.vir_h = dst_pix.height;
	req.dst.format = V4l2ToRgaFormat(dst_pix.pixelformat);
	req.dst.alpha_swap = 0;
	req.dst.act_w = dst_pix.width;
	req.dst.act_h = dst_pix.height;
	req.dst.x_offset = 0;
	req.dst.y_offset = 0;

	req.clip.xmin = 0;
	req.clip.xmax = dst_pix.width - 1;
	req.clip.ymin = 0;
	req.clip.ymax = dst_pix.height - 1;

	/* Set Bitblt Mode */
	req.render_mode = bitblt_mode;
	req.scale_mode = scaleMode;
	req.rotate_mode = BB_BYPASS;
	req.sina = sinaTable[orientation];
	req.cosa = cosaTable[orientation];
	req.yuv2rgb_mode = 0;
	req.alpha_rop_flag = 0;

	req.mmu_info.base_addr = 0;
	req.mmu_info.mmu_flag  = ((2 & 0x3) << 4) |
                          ((0 & 0x1) << 3) |
                          ((0 & 0x1) << 2) |
                          ((0 & 0x1) << 1) | 1;
	req.mmu_info.mmu_flag |= 0x1 << 31;

	ret = rtsp->fp->f_op->unlocked_ioctl(rtsp->fp, RGA_BLIT_SYNC, (unsigned long)(&req));
	if(ret < 0)
		v4l2_err(&rtsp->v4l2_dev, "RGA_BLIT_SYNC failed, ret %d\n", ret);
	return ret;
}

/*
 * Allocate buffers
 */
static unsigned long toybrick_alloc_buffer(u32 buffer_size, unsigned long *phys_addr)
{
	u32 order, size;
	unsigned long virt_addr, addr;

	size = PAGE_ALIGN(buffer_size);
	order = get_order(size);
	virt_addr = __get_free_pages(GFP_KERNEL, order);
	addr = virt_addr;
	if (virt_addr) {
		while (size > 0) {
			SetPageReserved(virt_to_page(addr));
			addr += PAGE_SIZE;
			size -= PAGE_SIZE;
		}
	}
	*phys_addr = virt_to_phys((void *) virt_addr);
	return virt_addr;
}

/*
 * Free buffers
 */
static void toybrick_free_buffer(unsigned long virt_addr, u32 buffer_size)
{
	u32 order, size;
	unsigned long addr = virt_addr;

	size = PAGE_ALIGN(buffer_size);
	order = get_order(size);

	while (size > 0) {
		ClearPageReserved(virt_to_page(addr));
		addr += PAGE_SIZE;
		size -= PAGE_SIZE;
	}
	free_pages((unsigned long) virt_addr, order);
}

/*
 * Free v4l2 buffers for RTSP
 */
static void toybrick_free_buffers(struct toybrick_rtsp_device *vdev)
{
	int i;
	
	for(i = 0; i < vdev->buffer_allocated; i++)
		toybrick_free_buffer(vdev->buf_virt_addr[i], vdev->buffer_size);

	vdev->buffer_allocated = 0;
}

/*
 * Alloc v4l2 buffers for RTSP
 */
static void toybrick_alloc_buffers(struct toybrick_rtsp_device *vdev)
{
	int i;
	unsigned long phys_addr = 0;
	unsigned long virt_addr = 0;
	u32 size = (RTSP_WIDTH * RTSP_HEIGHT * toybrick_formats[0].depth) >> 3;

	vdev->buffer_size = PAGE_ALIGN(size);
	for(i = 0; i < NUM_BUFFERS; i++) {
		virt_addr = toybrick_alloc_buffer(vdev->buffer_size, &phys_addr);
		if(!virt_addr)
			break;
		
		vdev->buf_virt_addr[i] = virt_addr;
		vdev->buf_phys_addr[i] = phys_addr;
	}
	vdev->buffer_allocated = i;
	v4l2_dbg(1, debug, vdev->vfd, "Allocated %d buffers for RTSP\n", vdev->buffer_allocated);
}

/* Video buffer call backs */

/*
 * Buffer setup function is called by videobuf layer when REQBUF ioctl is
 * called. This is used to setup buffers and return size and count of
 * buffers allocated. After the call to this buffer, videobuf layer will
 * setup buffer queue depending on the size and count of buffers
 */
static int toybrick_buffer_setup(struct videobuf_queue *q, unsigned int *count, unsigned int *size)
{
	int i;
	struct toybrick_rtsp_device *vdev = q->priv_data;

	if(q->type != vdev->type) {
		v4l2_err(vdev->vfd, "Buffer type is unsupported\n");
		return -EINVAL;
	}
	for(i = 0; i < vdev->buffer_allocated; i++) {
		if(vdev->type == V4L2_BUF_TYPE_VIDEO_OUTPUT)
			vdev->rtsp->state[i].data_ready = false;
	}

	vdev->buffer_size = vdev->pix.sizeimage;
	*size = vdev->pix.sizeimage;
	*count = vdev->buffer_allocated;

	v4l2_dbg(2, debug, vdev->vfd, "%s, size %u, count %u\n",
			__func__, *size, *count);

	return 0;
}

/*
 * This function will be called when VIDIOC_QBUF ioctl is called.
 * It prepare buffers before give out for the display. This function
 * converts user space virtual address into physical address if userptr memory
 * exchange mechanism is used.
 */
static int toybrick_buffer_prepare(struct videobuf_queue *q, struct videobuf_buffer *vb,
						enum v4l2_field field)
{
	struct toybrick_rtsp_device *vdev = q->priv_data;

	TRACE_ENTER(vdev, 2);
	vb->state = VIDEOBUF_PREPARED;

	return 0;
}

/*
 * Buffer queue function will be called from the videobuf layer when VIDIOC_QBUF
 * ioctl is called. It is used to enqueue buffer, which is ready to be
 * displayed.
 */
static void toybrick_buffer_queue(struct videobuf_queue *q, struct videobuf_buffer *vb)
{
	struct toybrick_rtsp_device *vdev = q->priv_data;

	TRACE_ENTER(vdev, 2);
        /* Driver is also maintainig a queue. So enqueue buffer in the driver
         * queue */
	list_add_tail(&vb->queue, &vdev->queue);

        vb->state = VIDEOBUF_QUEUED;

}

/*
 * Buffer release function is called from videobuf layer to release buffer
 * which are already allocated
 */
static void toybrick_buffer_release(struct videobuf_queue *q,
			   struct videobuf_buffer *vb)
{
	struct toybrick_rtsp_device *vdev = q->priv_data;

	TRACE_ENTER(vdev, 2);

	vb->state = VIDEOBUF_NEEDS_INIT;
}
	
static struct videobuf_queue_ops toybrick_vbq_ops = {
        .buf_setup      = toybrick_buffer_setup,
        .buf_prepare    = toybrick_buffer_prepare,
        .buf_queue      = toybrick_buffer_queue,
        .buf_release    = toybrick_buffer_release,
};

static void toybrick_rtsp_cancel_buffers(struct toybrick_rtsp_device *vdev)
{
	struct videobuf_buffer *vb;
	struct buffer_state *state = NULL;

	while(!list_empty(&vdev->queue)) {
		vb = list_entry(vdev->queue.next,
                        	struct videobuf_buffer, queue);
        	list_del(&vb->queue);
		state = (struct buffer_state *)vb->priv;
		v4l2_dbg(1, debug, vdev->vfd, "%s: %d, frm: 0x%lx, index: %d\n", __func__, __LINE__, (unsigned long)vb, vb->i);
        	vb->state = VIDEOBUF_ERROR;
		wake_up_interruptible(&vb->done);
	}

	if(vdev->cur_frm) {
		state = (struct buffer_state *)vdev->cur_frm->priv;
		v4l2_dbg(1, debug, vdev->vfd, "%s: %d, frm: 0x%lx, index: %d\n", __func__, __LINE__, (unsigned long)vdev->cur_frm, vdev->cur_frm->i);
        	vdev->cur_frm->state = VIDEOBUF_ERROR;
		wake_up_interruptible(&vdev->cur_frm->done);
		vdev->cur_frm = NULL;
	}
}

/*
 *  File operations
 */
static unsigned int toybrick_rtsp_poll(struct file *file,
                                      struct poll_table_struct *wait)
{
	int ret;
	struct toybrick_rtsp_device *vdev = file->private_data;
	struct videobuf_queue *q = &vdev->vbq;

	TRACE_ENTER(vdev, 1);
	ret = videobuf_poll_stream(file, q, wait);
	TRACE_EXIT(vdev, 1);

	return ret;
}

static void toybrick_vm_open(struct vm_area_struct *vma)
{
	struct toybrick_rtsp_device *vdev = vma->vm_private_data;

	v4l2_dbg(1, debug, vdev->vfd, "vm_open [vma=%08lx-%08lx]\n",
			vma->vm_start, vma->vm_end);
	vdev->mmap_count++;
}

static void toybrick_vm_close(struct vm_area_struct *vma)
{
	struct toybrick_rtsp_device *vdev = vma->vm_private_data;

	v4l2_dbg(1, debug, vdev->vfd, "vm_close [vma=%08lx-%08lx]\n",
			vma->vm_start, vma->vm_end);
        vdev->mmap_count--;
}

static const struct vm_operations_struct toybrick_vm_ops = {
	.open   = toybrick_vm_open,
	.close  = toybrick_vm_close,
};

static int toybrick_rtsp_mmap(struct file *file, struct vm_area_struct *vma)
{
	int i;
	void *pos;
	unsigned long start = vma->vm_start;
	unsigned long size = (vma->vm_end - vma->vm_start);
	struct toybrick_rtsp_device *vdev = file->private_data;
	struct videobuf_queue *q = &vdev->vbq;

	v4l2_dbg(1, debug, vdev->vfd,
			"%s pgoff=0x%lx, start=0x%lx, end=0x%lx\n", __func__,
			vma->vm_pgoff, vma->vm_start, vma->vm_end);

	for (i = 0; i < VIDEO_MAX_FRAME; i++) {
		if (NULL == q->bufs[i])
			continue;
		if (q->bufs[i]->boff == (vma->vm_pgoff << PAGE_SHIFT))
			break;
	}

	if (VIDEO_MAX_FRAME == i) {
		v4l2_err(vdev->vfd, "offset invalid [offset=0x%lx]\n",
				(vma->vm_pgoff << PAGE_SHIFT));
		return -EINVAL;
	}

	if (size > PAGE_ALIGN(vdev->pix.sizeimage)) {
		v4l2_err(vdev->vfd, "insufficient memory [%lu] [%u]\n",
				size, vdev->pix.sizeimage);
		return -ENOMEM;
	}

	q->bufs[i]->baddr = vma->vm_start;
	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
	vma->vm_ops = &toybrick_vm_ops;
	vma->vm_private_data = (void *)vdev;
	pos = (void *)vdev->buf_virt_addr[i];
	vma->vm_pgoff = virt_to_phys((void *)pos) >> PAGE_SHIFT;
	while (size > 0) {
		unsigned long pfn;
		pfn = virt_to_phys((void *) pos) >> PAGE_SHIFT;
		if (remap_pfn_range(vma, start, pfn, PAGE_SIZE, PAGE_SHARED))
			return -EAGAIN;
		start += PAGE_SIZE;
		pos += PAGE_SIZE;
		size -= PAGE_SIZE;
	}
	vdev->mmap_count++;
	return 0;
}

static int toybrick_rtsp_release(struct file *file)
{
	struct toybrick_rtsp_device *vdev = file->private_data;
	struct videobuf_queue *q = &vdev->vbq;

	TRACE_ENTER(vdev, 1);


	if(vdev->streaming) {
		vdev->streaming = false;
		videobuf_streamoff(q);
		videobuf_mmap_free(q);
	}

	if(vdev->mmap_count != 0)
		vdev->mmap_count = 0;

	vdev->opened -= 1;
	file->private_data = NULL;

	TRACE_EXIT(vdev, 1);
	return 0;
}

static int toybrick_rtsp_open(struct file *file)
{
	struct toybrick_rtsp_device *vdev = video_drvdata(file);

	TRACE_ENTER(vdev, 1);

	if(vdev->opened) {
		v4l2_err(vdev->vfd, "Device is opened\n");
		return -EBUSY;
	}

	vdev->opened += 1;

	file->private_data = vdev;
	videobuf_queue_dma_contig_init(&vdev->vbq, &toybrick_vbq_ops,
                        vdev->vbq.dev, &vdev->vbq_lock, vdev->type, V4L2_FIELD_NONE,
                        sizeof(struct videobuf_buffer), vdev, NULL);

	TRACE_EXIT(vdev, 1);
	return 0;
}

static int toybrick_vidioc_querycap(struct file *file, void *fh,
		struct v4l2_capability *cap)
{
	struct toybrick_rtsp_device *vdev = fh;

	TRACE_ENTER(vdev, 1);

	if(vdev->type == V4L2_BUF_TYPE_VIDEO_CAPTURE) {
		strlcpy(cap->driver, "uvcvideo", sizeof(cap->driver));
		strlcpy(cap->card, "front-0", sizeof(cap->card[0]));
	} else {
		strlcpy(cap->driver, RTSP_NAME, sizeof(cap->driver));
	}
        strlcpy(cap->card, vdev->vfd->name, sizeof(cap->card));
        cap->bus_info[0] = '\0';
        cap->device_caps = V4L2_CAP_STREAMING | vdev->cap.capabilities;
        cap->capabilities = cap->device_caps | V4L2_CAP_DEVICE_CAPS;

	TRACE_EXIT(vdev, 1);
	return 0;
}

static int toybrick_vidioc_enum_fmt_vid(struct file *file, void *fh,
		struct v4l2_fmtdesc *fmt)
{
	struct toybrick_rtsp_device *vdev = fh;

	TRACE_ENTER(vdev, 1);
	if(fmt->index >= ARRAY_SIZE(toybrick_formats))
		return -EINVAL;

        strlcpy(fmt->description, toybrick_formats[fmt->index].desc,
                        sizeof(fmt->description));
        fmt->pixelformat = toybrick_formats[fmt->index].format;

	TRACE_EXIT(vdev, 1);
	return 0;
}

static int toybrick_vidioc_g_fmt_vid(struct file *file, void *fh,
		struct v4l2_format *f)
{
	struct toybrick_rtsp_device *vdev = fh;

	TRACE_ENTER(vdev, 1);
	f->fmt.pix = vdev->pix;
	TRACE_EXIT(vdev, 1);
	
	return 0;
}

static int toybrick_vidioc_s_fmt_vid(struct file *file, void *fh,
		struct v4l2_format *f)
{
	int i, found = 0;
	struct toybrick_rtsp_device *vdev = fh;
	struct toybrick_rtsp *rtsp = vdev->rtsp;

	v4l2_dbg(1, debug, vdev->vfd, "%s, w %u, h %u, f %u\n",
		       	__func__, f->fmt.pix.width, f->fmt.pix.height, f->fmt.pix.pixelformat);

	if(!rtsp->fp) {
		v4l2_err(vdev->vfd, "RGA device is not ready\n");
		return -ENODEV;
	}

	for(i = 0; i < ARRAY_SIZE(toybrick_formats); i++){
		if(f->fmt.pix.pixelformat == toybrick_formats[i].format) {
			found = 1;
			break;
		}
	}

	if(!found)
		return -EINVAL;

	vdev->pix.width = f->fmt.pix.width;
	vdev->pix.height = f->fmt.pix.height;
	vdev->pix.pixelformat = f->fmt.pix.pixelformat;
	vdev->pix.bytesperline = (vdev->pix.width * toybrick_formats[0].depth) >> 3;
	vdev->pix.sizeimage = vdev->pix.height * vdev->pix.bytesperline;
	
	return 0;
}

static int toybrick_vidioc_try_fmt_vid(struct file *file, void *fh,
		struct v4l2_format *f)
{
	return toybrick_vidioc_s_fmt_vid(file, fh, f);
}

static int toybrick_vidioc_reqbufs(struct file *file, void *fh,
		struct v4l2_requestbuffers *req)
{
	int ret = 0;
	struct toybrick_rtsp_device *vdev = fh;

	struct videobuf_queue *q = &vdev->vbq;

	TRACE_ENTER(vdev, 1);

	/* if memory is not mmp or userptr return error */
	if (V4L2_MEMORY_MMAP != req->memory) {
		v4l2_err(vdev->vfd, "memory type(userptr) is unsupported\n");
		return -EINVAL;
	}

	/* Cannot be requested when streaming is on */
	if (vdev->streaming) {
		v4l2_err(vdev->vfd, "Stream is on\n");
		return -EBUSY;
	}

	ret = videobuf_reqbufs(q, req);

	TRACE_EXIT(vdev, 1);
	return ret;
}

static int toybrick_vidioc_querybuf(struct file *file, void *fh,
		struct v4l2_buffer *b)
{
	int ret;
	struct toybrick_rtsp_device *vdev = fh;

	TRACE_ENTER(vdev, 1);
	ret = videobuf_querybuf(&vdev->vbq, b);
	TRACE_EXIT(vdev, 1);

	return ret;
}

static int toybrick_vidioc_qbuf(struct file *file, void *fh,
		struct v4l2_buffer *b)
{
	int ret;
	struct toybrick_rtsp_device *vdev = fh;
	struct toybrick_rtsp *rtsp = vdev->rtsp;
	struct videobuf_queue *q = &vdev->vbq;
	struct videobuf_buffer *vb;
	u32 addr;
	unsigned long size;

	TRACE_ENTER(vdev, 2);
	vb = q->bufs[b->index];

	if(V4L2_MEMORY_USERPTR == b->memory) {
		v4l2_err(vdev->vfd, "memory type(userptr) is unsupported\n");
		return -EINVAL;
	}

	if(b->type != vdev->type) {
		v4l2_err(vdev->vfd, "Buffer type is unsupported\n");
		return -EINVAL;
	}

	if(b->index >= vdev->buffer_allocated) {
		v4l2_err(vdev->vfd, "Buffer index is greater than %u\n", vdev->buffer_allocated);
		return -EINVAL;
	}

	if(q->bufs[b->index]->memory != b->memory) {
		v4l2_err(vdev->vfd, "Wrong memory type\n");
		return -EINVAL;
	}

	if(vdev->type == V4L2_BUF_TYPE_VIDEO_CAPTURE) {
		rtsp->state[b->index].index = b->index;
		vb->priv = &rtsp->state[b->index];
	} else {
		addr = (unsigned long) vdev->buf_phys_addr[b->index];
        	size = (unsigned long) vb->size;
        	dma_unmap_single(rtsp->v4l2_dev.dev, addr,
                                size, DMA_TO_DEVICE);

		ret = toybrick_rga_convert(rtsp, rtsp->vout->buf_phys_addr[b->index],
						 rtsp->vcap->buf_phys_addr[b->index],
						 rtsp->vout->pix,
						 rtsp->vcap->pix);
		if(ret < 0)
			return -EINVAL;

		addr = (unsigned long) rtsp->vcap->buf_phys_addr[b->index];
        	size = (unsigned long) rtsp->vcap->pix.sizeimage;
        	dma_unmap_single(rtsp->v4l2_dev.dev, addr,
                                size, DMA_FROM_DEVICE);

		rtsp->state[b->index].index = b->index;
		rtsp->state[b->index].data_ready = true;
		vb->priv = &rtsp->state[b->index];
	}

	ret = videobuf_qbuf(q, b);

	TRACE_EXIT(vdev, 2);
	return ret;
}

static int toybrick_vidioc_dqbuf(struct file *file, void *fh,
		struct v4l2_buffer *b)
{
	struct toybrick_rtsp_device *vdev = fh;
	struct videobuf_queue *q = &vdev->vbq;
	struct videobuf_buffer *vb;
	int ret;

	TRACE_ENTER(vdev, 2);
	vb = q->bufs[b->index];

	if (!vdev->streaming) {
		v4l2_err(vdev->vfd, "Stream is off\n");
		return -EINVAL;
	}

	if (file->f_flags & O_NONBLOCK)
		/* Call videobuf_dqbuf for non blocking mode */
		ret = videobuf_dqbuf(q, (struct v4l2_buffer *)b, 1);
	else
		/* Call videobuf_dqbuf for  blocking mode */
		ret = videobuf_dqbuf(q, (struct v4l2_buffer *)b, 0);

	TRACE_EXIT(vdev, 2);
	return ret;
}

static int toybrick_vidioc_streamon(struct file *file, void *fh,
		enum v4l2_buf_type i)
{
	int ret = 0;
	struct toybrick_rtsp_device *vdev = fh;
	struct videobuf_queue *q = &vdev->vbq;

	TRACE_ENTER(vdev, 1);

	if(vdev->streaming) {
                v4l2_err(vdev->vfd, "Stream is in busy state\n");
		return -EBUSY;
		goto err_state;
	}

	ret = videobuf_streamon(q);
	if(ret < 0) {
		v4l2_err(vdev->vfd, "videobuf_streamon failed\n");
		goto err_streamon;
	}

	if (list_empty(&vdev->queue)) {
                v4l2_err(vdev->vfd, "dma_queue list empty\n");
		ret = -EIO;
		goto err_queue;
        }

	/* Get the next frame from the buffer queue */
	vdev->cur_frm = list_entry(vdev->queue.next,
			struct videobuf_buffer, queue);
	/* Remove buffer from the buffer queue */
	list_del(&vdev->cur_frm->queue);
	/* Mark state of the current frame to active */
	vdev->cur_frm->state = VIDEOBUF_ACTIVE;

	/* set flag here. Next QBUF will start */
	vdev->streaming = true;

err_queue:
	if(ret)
		ret = videobuf_streamoff(q);
err_streamon:
err_state:

	TRACE_EXIT(vdev, 1);
	return ret;
}

static int toybrick_vidioc_streamoff(struct file *file, void *fh,
		enum v4l2_buf_type i)
{
	int ret = 0;
	struct toybrick_rtsp_device *vdev = fh;
	struct toybrick_rtsp *rtsp = vdev->rtsp;
	struct videobuf_queue *q = &vdev->vbq;

	TRACE_ENTER(vdev, 1);

	if(!vdev->streaming) {
                v4l2_err(&rtsp->v4l2_dev, "Stream is off\n");
		return -EINVAL;
	}
	vdev->streaming = false;
	ret = videobuf_streamoff(q);
	if(ret < 0)
                v4l2_err(&rtsp->v4l2_dev, "videobuf_streamoff failed\n");
	TRACE_EXIT(vdev, 1);
	return ret;
}

static int toybrick_vidioc_enum_frameintervals(struct file *file, void *fh,
		struct v4l2_frmivalenum *fival)
{
	struct toybrick_rtsp_device *vdev = fh;
	int i;

	TRACE_ENTER(vdev, 2);
	for (i = 0; i < ARRAY_SIZE(toybrick_vcap_sizes); i++)
		if (fival->width == toybrick_vcap_sizes[i].width &&
				fival->height == toybrick_vcap_sizes[i].height)
			break;

        if (i == ARRAY_SIZE(toybrick_vcap_sizes))
                return -EINVAL;

        if (fival->index >= 2 * (ARRAY_SIZE(toybrick_vcap_sizes) - i))
                return -EINVAL;

	fival->type = V4L2_FRMIVAL_TYPE_DISCRETE;
	fival->discrete = toybrick_vcap_intervals[fival->index];

	TRACE_EXIT(vdev, 2);
	return 0;
}

static int toybrick_vidioc_enum_framesizes(struct file *file, void *fh,
                                         struct v4l2_frmsizeenum *fsize)
{
	struct toybrick_rtsp_device *vdev = fh;

	TRACE_ENTER(vdev, 2);
	if (fsize->index >= ARRAY_SIZE(toybrick_vcap_sizes))
		return -EINVAL;
	fsize->type = V4L2_FRMSIZE_TYPE_DISCRETE;
	fsize->discrete = toybrick_vcap_sizes[fsize->index];

	TRACE_EXIT(vdev, 2);
	return 0;
}

static int toybrick_vidioc_s_parm(struct file *file, void *fh,
		struct v4l2_streamparm *parm)
{
	return 0;
}

static const struct v4l2_ioctl_ops toybrick_ioctl_ops = {
	.vidioc_enum_fmt_vid_cap	= toybrick_vidioc_enum_fmt_vid,
	.vidioc_g_fmt_vid_cap		= toybrick_vidioc_g_fmt_vid,
	.vidioc_try_fmt_vid_cap		= toybrick_vidioc_try_fmt_vid,
	.vidioc_s_fmt_vid_cap		= toybrick_vidioc_s_fmt_vid,

	.vidioc_enum_fmt_vid_out	= toybrick_vidioc_enum_fmt_vid,
	.vidioc_g_fmt_vid_out		= toybrick_vidioc_g_fmt_vid,
	.vidioc_try_fmt_vid_out		= toybrick_vidioc_try_fmt_vid,
	.vidioc_s_fmt_vid_out		= toybrick_vidioc_s_fmt_vid,

	.vidioc_querycap		= toybrick_vidioc_querycap,
	.vidioc_reqbufs			= toybrick_vidioc_reqbufs,
	.vidioc_querybuf		= toybrick_vidioc_querybuf,
	.vidioc_qbuf			= toybrick_vidioc_qbuf,
	.vidioc_dqbuf			= toybrick_vidioc_dqbuf,
	.vidioc_streamon		= toybrick_vidioc_streamon,
	.vidioc_streamoff		= toybrick_vidioc_streamoff,

	.vidioc_enum_frameintervals	= toybrick_vidioc_enum_frameintervals,
	.vidioc_enum_framesizes		= toybrick_vidioc_enum_framesizes,

	.vidioc_s_parm			= toybrick_vidioc_s_parm,
};

static const struct v4l2_file_operations toybrick_rtsp_fops = {
	.owner          = THIS_MODULE,
	.unlocked_ioctl = video_ioctl2,
	.open           = toybrick_rtsp_open,
	.release        = toybrick_rtsp_release,
	.mmap		= toybrick_rtsp_mmap,
	.poll		= toybrick_rtsp_poll,
};

static void toybrick_rtsp_cleanup_device(struct toybrick_rtsp_device *vdev)
{
	toybrick_free_buffers(vdev);

	if(vdev->vfd){
		if (!video_is_registered(vdev->vfd)) {
			/*
			 * The device was never registered, so release the
			 * video_device struct directly.
			 */
			video_device_release(vdev->vfd);
		} else {
			/*
			 * The unregister function will release the video_device
			 * struct as well as unregistering it.
			 */
			video_unregister_device(vdev->vfd);
		}
	}

	kfree(vdev);
}

static struct toybrick_rtsp_device *toybrick_rtsp_setup_device(struct toybrick_rtsp *rtsp,
					     enum v4l2_buf_type type)
{
	int ret = 0;
	struct video_device *vfd = NULL;
	struct toybrick_rtsp_device *vdev = NULL;

	vdev = kzalloc(sizeof(struct toybrick_rtsp_device), GFP_KERNEL);
	if (!rtsp) {
		v4l2_err(&rtsp->v4l2_dev, "No memory for video device struct\n");
		return NULL;
	}

	vfd = video_device_alloc();
	if(!vfd) {
		v4l2_err(&rtsp->v4l2_dev, "Could not allocate video device\n");
		goto err_alloc;
	}

	vfd->release = video_device_release;
	vfd->ioctl_ops = &toybrick_ioctl_ops;
	vfd->fops = &toybrick_rtsp_fops;
	vfd->v4l2_dev = &rtsp->v4l2_dev;
	vfd->minor = -1;

	if(type == V4L2_BUF_TYPE_VIDEO_CAPTURE) {
		vdev->cap.capabilities = V4L2_CAP_VIDEO_CAPTURE;
		strlcpy(vfd->name, VCAP_NAME, sizeof(vfd->name));
		vfd->vfl_dir = VFL_DIR_RX;
	} else {
		vdev->cap.capabilities = V4L2_CAP_VIDEO_OUTPUT;
		strlcpy(vfd->name, VOUT_NAME, sizeof(vfd->name));
		vfd->vfl_dir = VFL_DIR_TX;
	}

	ret = video_register_device(vfd, VFL_TYPE_GRABBER, -1);
	if (ret < 0) {
		v4l2_err(&rtsp->v4l2_dev, "Could not register video for linux device\n");
		vfd->minor = -1;
		ret = -ENODEV;
		goto err_register;
	}

	video_set_drvdata(vfd, vdev);
	vdev->vfd = vfd;
	vdev->rtsp = rtsp;
	vdev->type = type;

	vdev->pix.width = RTSP_WIDTH;
	vdev->pix.height = RTSP_HEIGHT;
	vdev->pix.pixelformat = toybrick_formats[0].format;
	vdev->pix.field = V4L2_FIELD_NONE;
	vdev->pix.bytesperline = (vdev->pix.width * toybrick_formats[0].depth) >> 3;
	vdev->pix.sizeimage = vdev->pix.height * vdev->pix.bytesperline;
	vdev->pix.colorspace = V4L2_COLORSPACE_JPEG;
	vdev->pix.priv = 0;

	spin_lock_init(&vdev->vbq_lock);
	INIT_LIST_HEAD(&vdev->queue);

	toybrick_alloc_buffers(vdev);
	printk(KERN_INFO VCAP_NAME "registered and initialized %s video device %d\n", 
			(type == V4L2_BUF_TYPE_VIDEO_CAPTURE)? "capture": "output", vfd->minor);
	return vdev;

err_register:
	video_device_release(vfd);
err_alloc:
	kfree(vdev);
	return NULL;
}

static void toybrick_rtsp_handle(struct toybrick_rtsp_device *vdev)
{
	unsigned long flags = 0;
	struct timeval timevalue;
	struct buffer_state *state = NULL;
	
	spin_lock_irqsave(&vdev->vbq_lock, flags);
	if(!vdev->streaming) {
		toybrick_rtsp_cancel_buffers(vdev);
		goto unlock;
	}

	v4l2_get_timestamp(&timevalue);
	if(vdev->cur_frm) {
		state = (struct buffer_state *)vdev->cur_frm->priv;
		if(vdev->type == V4L2_BUF_TYPE_VIDEO_CAPTURE) {
			if(state->data_ready) {
				state->data_ready = false;
				vdev->cur_frm->ts = timevalue;
				vdev->cur_frm->state = VIDEOBUF_DONE;
				wake_up_interruptible(&vdev->cur_frm->done);
				vdev->cur_frm = NULL;
			}
		} else {
			vdev->cur_frm->ts = timevalue;
			vdev->cur_frm->state = VIDEOBUF_DONE;
			wake_up_interruptible(&vdev->cur_frm->done);
			vdev->cur_frm = NULL;
		}
	}
	if (!list_empty(&vdev->queue) && !vdev->cur_frm) {
		vdev->cur_frm = list_entry(vdev->queue.next,
                        	struct videobuf_buffer, queue);
        	list_del(&vdev->cur_frm->queue);
        	vdev->cur_frm->state = VIDEOBUF_ACTIVE;
	}
unlock:
	spin_unlock_irqrestore(&vdev->vbq_lock, flags);
}

static int toybrick_rtsp_thread(void *data)
{
	struct toybrick_rtsp *rtsp = data;
	struct toybrick_rtsp_device *vcap = rtsp->vcap;
	struct toybrick_rtsp_device *vout = rtsp->vout;

	v4l2_dbg(1, debug, &rtsp->v4l2_dev, "Entering %s\n", __func__);
	set_freezable();
	
	for (;;) {
		//msleep_interruptible(5);
		usleep_range(1000, 2000);
		if (kthread_should_stop())
			break;

		try_to_freeze();

		if(!rtsp->fp) {
			rtsp->fp = filp_open("/dev/rga", O_RDWR, 0);
			if(IS_ERR(rtsp->fp)) {
				//v4l2_dbg(1, debug, &rtsp->v4l2_dev, "Open /dev/rga failed\n");
				rtsp->fp = NULL;

			}
		}
		
		toybrick_rtsp_handle(vcap);
		toybrick_rtsp_handle(vout);
	}

	v4l2_dbg(1, debug, &rtsp->v4l2_dev, "Exit %s\n", __func__);
	return 0;
}


static int toybrick_rtsp_remove(struct platform_device *pdev)
{
	struct v4l2_device *v4l2_dev = platform_get_drvdata(pdev);
	struct toybrick_rtsp *rtsp = container_of(v4l2_dev, struct
                        toybrick_rtsp, v4l2_dev);

	kthread_stop(rtsp->kthread);
	if(rtsp->fp)
		filp_close(rtsp->fp, NULL);
	toybrick_rtsp_cleanup_device(rtsp->vout);
	toybrick_rtsp_cleanup_device(rtsp->vcap);
	v4l2_device_unregister(&rtsp->v4l2_dev);
	kfree(rtsp);

	return 0;
}

static int __init toybrick_rtsp_probe(struct platform_device *pdev)
{
	int ret = 0;
	struct toybrick_rtsp *rtsp = NULL;

	rtsp = kzalloc(sizeof(struct toybrick_rtsp), GFP_KERNEL);
	if (!rtsp) {
		dev_err(&pdev->dev, "No memory for rtsp struct\n");
		return -ENOMEM;
	}

	if (v4l2_device_register(&pdev->dev, &rtsp->v4l2_dev) < 0) {
		dev_err(&pdev->dev, "v4l2_device_register failed\n");
		ret = -ENODEV;
		goto err_v4l2_device_register;
	}

	rtsp->vcap = toybrick_rtsp_setup_device(rtsp, V4L2_BUF_TYPE_VIDEO_CAPTURE);
	if(!rtsp->vcap)
		goto err_setup_vcap;

	rtsp->vout = toybrick_rtsp_setup_device(rtsp, V4L2_BUF_TYPE_VIDEO_OUTPUT);
	if(ret < 0)
		goto err_setup_vout;

	rtsp->kthread = kthread_run(toybrick_rtsp_thread, rtsp, "toybrick_rtsp");
        if (IS_ERR(rtsp->kthread)) {
                dev_err(&pdev->dev, "kernel_thread(rtsp_vcap) failed\n");
                ret = PTR_ERR(rtsp->kthread);
		goto err_kthread;
        }

	rtsp->fp = NULL;

	return 0;

err_kthread:
	toybrick_rtsp_cleanup_device(rtsp->vout);
err_setup_vout:
	toybrick_rtsp_cleanup_device(rtsp->vcap);
err_setup_vcap:
	v4l2_device_unregister(&rtsp->v4l2_dev);
err_v4l2_device_register:
	kfree(rtsp);

	return ret;
}

static const struct of_device_id toybrick_rtsp_match[] = {
        {
                .compatible = "toybrick,v4l2-rtsp",
        },
	{},
};

static struct platform_driver toybrick_rtsp_driver = {
	.remove = toybrick_rtsp_remove,
	.probe = toybrick_rtsp_probe,
	.driver = {
		.name = RTSP_NAME,
		.of_match_table = toybrick_rtsp_match,
	},
};

module_platform_driver(toybrick_rtsp_driver);

MODULE_AUTHOR("Toybrick");
MODULE_DESCRIPTION("Toybrick V4L2-RTSP Virtual Driver");
MODULE_LICENSE("GPL");

