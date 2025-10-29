// SPDX-License-Identifier: (GPL-2.0+ OR MIT)
/*
 * Copyright (c) 2021 Rockchip Electronics Co., Ltd.
 * Author: Sandy Huang <hjc@rock-chips.com>
 */

#include "linux/types.h"
#include "linux/vt_kern.h"
#include <drm/drm_atomic_uapi.h>
#include <drm/drm_drv.h>
#include <drm/drm_file.h>
#include <drm/drm_gem_cma_helper.h>
#include <drm/drm_of.h>
#include <drm/drm_probe_helper.h>

#include <linux/file.h>

#include "rockchip_drm_drv.h"
#include "rockchip_drm_debugfs.h"
#include "rockchip_drm_fb.h"

#define DUMP_BUF_PATH		"/data"
#define AFBC_HEADER_SIZE		16
#define AFBC_HDR_ALIGN			64
#define AFBC_SUPERBLK_PIXELS		256
#define AFBC_SUPERBLK_ALIGNMENT		128

#define to_rockchip_crtc(x) container_of(x, struct rockchip_crtc, crtc)

#if defined(CONFIG_NO_GKI)
/**
 * struct vop_dump_info - vop dump plane info structure
 *
 * Store plane info used to write display data to /data/vop_buf/
 *
 */
struct vop_dump_info {
	/* @win_name human readable vop win name */
	const char *win_name;
	/* @fb: DRM frame buffer */
	struct drm_framebuffer *fb;
	/* @src: source coordinates of the plane (in 16.16)*/
	struct drm_rect *src;
};

static int temp_pow(int sum, int n)
{
	int i;
	int temp = sum;

	if (n < 1) {
		return 1;
	}
	for (i = 1; i < n ; i++) {
		sum *= temp;
	}
	return sum;
}

static int rockchip_drm_dump_plane_buffer(struct vop_dump_info *dump_info, int frame_count)
{
	int flags;
	const char *ptr;
	char file_name[128];
	void *kvaddr, *kvaddr_origin;
	struct file *file;
	loff_t pos = 0;
	struct drm_format_name_buf format_name;
	char format[8];
	struct drm_gem_object *obj = dump_info->fb->obj[0];
	struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);

	(void)drm_get_format_name(dump_info->fb->format->format, &format_name);
	(void)strscpy(format, format_name.str, 5);

	flags = (int)(O_RDWR | O_CREAT);
	(void)snprintf(file_name, 100, "%s/%s_fb-%dx%d_stride-%d_offset-%dx%d_act-%dx%d_%s%s_%d.bin",
		 DUMP_BUF_PATH, dump_info->win_name, dump_info->fb->width, dump_info->fb->height,
		 dump_info->fb->pitches[0], (u32)dump_info->src->x1 >> 16U, (u32)dump_info->src->y1 >> 16U,
		 (u32)drm_rect_width(dump_info->src) >> 16U, (u32)drm_rect_height(dump_info->src) >> 16U,
		 format, rockchip_drm_modifier_to_string(dump_info->fb->modifier), frame_count);

	kvaddr = vmap(rk_obj->pages, (unsigned int)rk_obj->num_pages, VM_MAP,
		      pgprot_writecombine(PAGE_KERNEL));
	kvaddr_origin = kvaddr;
	if (!kvaddr) {
		DRM_ERROR("failed to vmap() buffer\n");
	}

	ptr = file_name;
	file = filp_open(ptr, flags, 420); /* 0644 */
	if (!IS_ERR(file)) {
		(void)kernel_write(file, kvaddr, rk_obj->size, &pos);
		(void)DRM_INFO("dump file name is:%s\n", file_name);
		fput(file);
	} else {
		(void)DRM_INFO("open %s failed\n", ptr);
	}
	vunmap(kvaddr_origin);

	return 0;
}

int rockchip_drm_crtc_dump_plane_buffer(struct drm_crtc *crtc)
{
	struct rockchip_crtc *rockchip_crtc = container_of(crtc, struct rockchip_crtc, crtc);
	struct drm_plane *plane;
	struct drm_plane_state *pstate;
	struct drm_framebuffer *fb;
	struct vop_dump_info dump_info;

	drm_atomic_crtc_for_each_plane(plane, crtc) {
		pstate = plane->state;
		fb = pstate->fb;
		if (!fb) {
			continue;
		}

		dump_info.win_name = plane->name;
		dump_info.fb = fb;
		dump_info.src = &pstate->src;

		(void)rockchip_drm_dump_plane_buffer(&dump_info, rockchip_crtc->vop_dump_frame_count);
	}
	rockchip_crtc->vop_dump_frame_count++;

	return 0;
}

static int rockchip_drm_dump_buffer_show(struct seq_file *m, void *data)
{
	seq_puts(m, "VOP dump buffer version: v2.0.0\n");
	seq_puts(m, "  echo dump    > dump to dump one frame\n");
	seq_puts(m, "  echo dumpon  > dump to start vop keep dumping\n");
	seq_puts(m, "  echo dumpoff > dump to stop keep dumping\n");
	seq_puts(m, "  echo dumpn   > dump n is the number of dump times\n");
	seq_puts(m, "  dump path is /data\n");

	return 0;
}

static int rockchip_drm_dump_buffer_open(struct inode *inode, struct file *file)
{
	struct drm_crtc *crtc = inode->i_private;

	return single_open(file, rockchip_drm_dump_buffer_show, crtc);
}

static ssize_t
rockchip_drm_dump_buffer_write(struct file *file, const char __user *ubuf,
			       size_t len, loff_t *offp)
{
	struct seq_file *m = file->private_data;
	struct drm_crtc *crtc = m->private;
	char buf[14] = {};
	int dump_times = 0;
	int i;
	struct rockchip_crtc *rockchip_crtc = to_rockchip_crtc(crtc);

	if (len > (size_t)sizeof(buf) - (size_t)1U) {
		return -EINVAL;
	}
	if (copy_from_user(buf, ubuf, len) != 0UL) {
		return -EFAULT;
	}
	buf[len - 1UL] = '\0';
	if (strncmp(buf, "dumpon", 6) == 0) {
		rockchip_crtc->vop_dump_status = DUMP_KEEP;
		(void)DRM_INFO("keep dumping\n");
	} else if (strncmp(buf, "dumpoff", 7) == 0) {
		rockchip_crtc->vop_dump_status = DUMP_DISABLE;
		(void)DRM_INFO("close keep dumping\n");
	} else if (strncmp(buf, "dump", 4) == 0) {
		if (isdigit((int)buf[4]) != 0) {
			for (i = 4; (unsigned long)i < strlen(buf) &&
			     (unsigned long)i < sizeof(buf); i++) {
				dump_times += temp_pow(10, ((int)strlen(buf)
						       - i - 1))
						       * (buf[i] - '0');
			}
			rockchip_crtc->vop_dump_times = dump_times;
		} else {
			drm_modeset_lock_all(crtc->dev);
			(void)rockchip_drm_crtc_dump_plane_buffer(crtc);
			drm_modeset_unlock_all(crtc->dev);
		}
	} else {
		return -EINVAL;
	}

	return (ssize_t)len;
}

static const struct file_operations rockchip_drm_dump_buffer_fops = {
	.owner = THIS_MODULE,
	.open = rockchip_drm_dump_buffer_open,
	.read = seq_read,
	.llseek = seq_lseek,
	.release = single_release,
	.write = rockchip_drm_dump_buffer_write,
};

int rockchip_drm_add_dump_buffer(struct drm_crtc *crtc, struct dentry *root)
{
	struct dentry *vop_dump_root;
	struct dentry *ent;
	struct rockchip_crtc *rockchip_crtc = to_rockchip_crtc(crtc);

	vop_dump_root = debugfs_create_dir("vop_dump", root);
	rockchip_crtc->vop_dump_status = DUMP_DISABLE;
	rockchip_crtc->vop_dump_times = 0;
	rockchip_crtc->vop_dump_frame_count = 0;
	ent = debugfs_create_file("dump", 420, vop_dump_root, /* 0644 */
				  crtc, &rockchip_drm_dump_buffer_fops);
	if (!ent) {
		DRM_ERROR("create vop_plane_dump err\n");
		debugfs_remove_recursive(vop_dump_root);
	}

	return 0;
}
#endif

static int rockchip_drm_debugfs_color_bar_show(struct seq_file *s, void *data)
{
	seq_puts(s, "  Enable horizontal color bar:\n");
	seq_puts(s, "      echo 1 > /sys/kernel/debug/dri/0/video_port0/color_bar\n");
	seq_puts(s, "  Enable vertical color bar:\n");
	seq_puts(s, "      echo 2 > /sys/kernel/debug/dri/0/video_port0/color_bar\n");
	seq_puts(s, "  Disable color bar:\n");
	seq_puts(s, "      echo 0 > /sys/kernel/debug/dri/0/video_port0/color_bar\n");

	return 0;
}

static int rockchip_drm_debugfs_color_bar_open(struct inode *inode, struct file *file)
{
	struct drm_crtc *crtc = inode->i_private;

	return single_open(file, rockchip_drm_debugfs_color_bar_show, crtc);
}

static ssize_t rockchip_drm_debugfs_color_bar_write(struct file *file, const char __user *ubuf,
						    size_t len, loff_t *offp)
{
	struct seq_file *s = file->private_data;
	struct drm_crtc *crtc = s->private;
	struct rockchip_drm_private *priv = crtc->dev->dev_private;
	unsigned int pipe = drm_crtc_index(crtc);
	enum rockchip_color_bar_mode mode;

	if ((int)len != 2) {
		(void)DRM_INFO("Unsupported color bar mode\n");
		return -EINVAL;
	}

	if (kstrtou8_from_user(ubuf, len, 0, (u8 *)&mode) != 0) {
		return -EFAULT;
	}

	if (pipe >= (unsigned int)ROCKCHIP_MAX_CRTC) {
		return -EFAULT;
	}

	if (priv->crtc_funcs[pipe]->crtc_set_color_bar != NULL) {
		if (priv->crtc_funcs[pipe]->crtc_set_color_bar(crtc, mode) != 0) {
			return -EINVAL;
		}
	}

	return (ssize_t)len;
}

static const struct file_operations rockchip_drm_debugfs_color_bar_fops = {
	.owner = THIS_MODULE,
	.open = rockchip_drm_debugfs_color_bar_open,
	.read = seq_read,
	.llseek = seq_lseek,
	.release = single_release,
	.write = rockchip_drm_debugfs_color_bar_write,
};

int rockchip_drm_debugfs_add_color_bar(struct drm_crtc *crtc, struct dentry *root)
{
	struct dentry *ent;

	ent = debugfs_create_file("color_bar", 420, root, crtc, /* 0644 */
				  &rockchip_drm_debugfs_color_bar_fops);
	if (!ent) {
		DRM_ERROR("Failed to add color_bar for debugfs\n");
	}

	return 0;
}

static int rockchip_drm_debugfs_regs_write_show(struct seq_file *s, void *data)
{
	seq_puts(s, "  Write VOP regs:\n");
	seq_puts(s, "    echo address val > /sys/kernel/debug/dri/0/video_portx/regs_write\n\n");
	seq_puts(s, "    video_portx is depend on hardware config, you can get this info from the cmd:\n");
	seq_puts(s, "    cat /sys/kernel/debug/dri/0/summary\n\n");
	seq_puts(s, "    Example:\n");
	seq_puts(s, "    echo 0x27d00000 0x1 > /sys/kernel/debug/dri/0/video_portx/regs_write\n\n");

	return 0;
}

static int rockchip_drm_debugfs_regs_write_open(struct inode *inode, struct file *file)
{
	struct drm_crtc *crtc = inode->i_private;

	return single_open(file, rockchip_drm_debugfs_regs_write_show, crtc);
}

static ssize_t rockchip_drm_debugfs_regs_write(struct file *file, const char __user *ubuf,
					       size_t len, loff_t *offp)
{
	struct seq_file *s = file->private_data;
	struct drm_crtc *crtc = s->private;
	struct rockchip_drm_private *priv = crtc->dev->dev_private;
	int ret;
	unsigned int pipe = drm_crtc_index(crtc);
	unsigned long address = 0;
	u32 val = 0;
	char kbuf[32];
	int (*sscanf_p)(const char *buf, const char *fmt, ...) = sscanf;

	len = len < (sizeof(kbuf) - 1UL) ? len : (unsigned long)(sizeof(kbuf) - 1UL);
	if (copy_from_user(kbuf, ubuf, len) != 0UL) {
		return -EINVAL;
	}

	kbuf[len] = (char)0;
	ret = kstrtoul(kbuf, 16, &address);
	if (ret != 0) {
		return -EFAULT;
	}

	if (sscanf_p(kbuf, "%lx %x", &address, &val) == -1) {
		return -EFAULT;
	}

	if (pipe >= (unsigned int)ROCKCHIP_MAX_CRTC) {
		return -EFAULT;
	}

	if (priv->crtc_funcs[pipe]->regs_write != NULL) {
		ret = priv->crtc_funcs[pipe]->regs_write(crtc, address, val);
	}
	if (ret != 0) {
		return ret;
	}

	return (ssize_t)len;
}

static const struct file_operations rockchip_drm_debugfs_regs_write_ops = {
	.owner = THIS_MODULE,
	.open = rockchip_drm_debugfs_regs_write_open,
	.read = seq_read,
	.llseek = seq_lseek,
	.release = single_release,
	.write = rockchip_drm_debugfs_regs_write,
};

int rockchip_drm_debugfs_add_regs_write(struct drm_crtc *crtc, struct dentry *root)
{
	struct dentry *ent;

	ent = debugfs_create_file("regs_write", 420, root, crtc, /* 0644 */
				  &rockchip_drm_debugfs_regs_write_ops);
	if (!ent) {
		DRM_ERROR("Failed to add regs_write for debugfs\n");
	}

	return 0;
}
