// SPDX-License-Identifier: GPL-2.0
/*
 * Rockchip Endpoint function driver
 *
 * Copyright (C) 2023 Rockchip Electronic Co,. Ltd.
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/string.h>
#include <linux/slab.h>
#include <linux/pci.h>
#include <linux/io.h>
#include <linux/delay.h>
#include <linux/miscdevice.h>
#include <linux/mutex.h>
#include <linux/ctype.h>
#include <linux/of.h>
#include <linux/interrupt.h>
#include <linux/iopoll.h>

#include <uapi/linux/rk-pcie-ep.h>

#include "../../pci/controller/rockchip-pcie-dma.h"
#include "../../pci/controller/dwc/pcie-dw-dmatest.h"
#if IS_MODULE(CONFIG_PCIE_FUNC_RKEP) && IS_ENABLED(CONFIG_PCIE_DW_DMATEST)
#include "../../pci/controller/dwc/pcie-dw-dmatest.c"
#endif

#define DRV_NAME "pcie-rkep"

#ifndef PCI_VENDOR_ID_ROCKCHIP
#define PCI_VENDOR_ID_ROCKCHIP          0x1d87U
#endif

#define MISC_DEV_NAME_MAX_LENGTH        0x80U

#define BAR_0_SZ                        SZ_4M
#define RKEP_NUM_IRQ_VECTORS            4U

#define PCIe_CLIENT_MSI_IRQ_OBJ         0U      /* rockchip ep object special irq */

#define PCIE_DMA_OFFSET                 0x0U

#define PCIE_DMA_CTRL_OFF               0x8U
#define PCIE_DMA_WR_ENB                 0xcU
#define PCIE_DMA_WR_CTRL_LO             0x200U
#define PCIE_DMA_WR_CTRL_HI             0x204U
#define PCIE_DMA_WR_XFERSIZE            0x208U
#define PCIE_DMA_WR_SAR_PTR_LO          0x20cU
#define PCIE_DMA_WR_SAR_PTR_HI          0x210U
#define PCIE_DMA_WR_DAR_PTR_LO          0x214U
#define PCIE_DMA_WR_DAR_PTR_HI          0x218U
#define PCIE_DMA_WR_LL_PTR_LO           0x21cU
#define PCIE_DMA_WR_LL_PTR_HI           0x220U
#define PCIE_DMA_WR_WEILO               0x18U
#define PCIE_DMA_WR_WEIHI               0x1cU
#define PCIE_DMA_WR_DOORBELL            0x10U
#define PCIE_DMA_WR_INT_STATUS          0x4cU
#define PCIE_DMA_WR_INT_MASK            0x54U
#define PCIE_DMA_WR_INT_CLEAR           0x58U
#define PCIE_DMA_WR_ERR_STATUS          0x5cU
#define PCIE_DMA_WR_LL_ERR_EN           0x90U

#define PCIE_DMA_RD_ENB                 0x2cU
#define PCIE_DMA_RD_CTRL_LO             0x300U
#define PCIE_DMA_RD_CTRL_HI             0x304U
#define PCIE_DMA_RD_XFERSIZE            0x308U
#define PCIE_DMA_RD_SAR_PTR_LO          0x30cU
#define PCIE_DMA_RD_SAR_PTR_HI          0x310U
#define PCIE_DMA_RD_DAR_PTR_LO          0x314U
#define PCIE_DMA_RD_DAR_PTR_HI          0x318U
#define PCIE_DMA_RD_LL_PTR_LO			0x31cU
#define PCIE_DMA_RD_LL_PTR_HI			0x320U
#define PCIE_DMA_RD_WEILO               0x38U
#define PCIE_DMA_RD_WEIHI               0x3cU
#define PCIE_DMA_RD_DOORBELL            0x30U
#define PCIE_DMA_RD_INT_STATUS          0xa0U
#define PCIE_DMA_RD_INT_MASK            0xa8U
#define PCIE_DMA_RD_INT_CLEAR           0xacU
#define PCIE_DMA_RD_ERR_STATUS_LOW      0xb8U
#define PCIE_DMA_RD_ERR_STATUS_HIGH     0xbcU
#define PCIE_DMA_RD_LL_ERR_EN           0xc4U

#define PCIE_DMA_CHANEL_MAX_NUM         2U

#define RKEP_USER_MEM_SIZE              SZ_64M

#define PCIE_CFG_ELBI_APP_OFFSET        0xe00U
#define PCIE_CFG_ELBI_USER_DATA_OFF     0x10U

#define PCIE_ELBI_REG_NUM               2U

#define RKEP_EP_ELBI_TIEMOUT_US         100000U

#define PCIE_RK3568_RC_DBI_BASE         0xf6000000U
#define PCIE_RK3588_RC_DBI_BASE         0xf5000000U
#define PCIE_DBI_SIZE                   0x400000U

struct pcie_rkep_irq_context {
	struct pci_dev *dev;
	u16 msg_id;
};

struct pcie_rkep {
	struct pci_dev *pdev;
	void __iomem *bar0;
	void __iomem *bar2;
	void __iomem *bar4;
	int cur_mmap_res;
	struct pcie_rkep_irq_context irq_ctx[RKEP_NUM_IRQ_VECTORS];
	int irq_valid;

	struct miscdevice dev;
	struct dma_trx_obj *dma_obj;
	struct pcie_ep_obj_info *obj_info;
	struct page *user_pages; /* Allocated physical memory for user space */
	struct mutex dev_lock_mutex; /* Sync resources in multi-process, such as vid and ELBI0 */
	DECLARE_BITMAP(virtual_id_bitmap, RKEP_EP_VIRTUAL_ID_MAX);
	DECLARE_BITMAP(virtual_id_irq_bitmap, RKEP_EP_VIRTUAL_ID_MAX);
	wait_queue_head_t wq_head;
};

struct pcie_file {
	struct mutex file_lock_mutex;
	struct pcie_rkep *pcie_rkep;
	DECLARE_BITMAP(child_vid_bitmap, RKEP_EP_VIRTUAL_ID_MAX); /* The virtual IDs applied for each task */
};

static bool pcie_rkep_wait_for_link_up(struct pci_dev *pdev)
{
	int timeout = 1000;
	bool ret;
	u16 lnk_status;
	struct pci_dev *bridge;
	int result;

	bridge = pci_upstream_bridge(pdev);

	/*
	 * PCIe r4.0 sec 6.6.1, a component must enter LTSSM Detect within 20ms,
	 * after which we should expect an link active if the reset was
	 * successful. If so, software must wait a minimum 100ms before sending
	 * configuration requests to devices downstream this port.
	 *
	 * If the link fails to activate, either the device was physically
	 * removed or the link is permanently failed.
	 */
	msleep(20);
	for (;;) {
		result = pcie_capability_read_word(bridge, PCI_EXP_LNKSTA, &lnk_status);
		if (result < 0) {
			dev_warn(&pdev->dev, "read word failed\n");
		}
		if ((lnk_status & (u16)PCI_EXP_LNKSTA_DLLLA) > 0U) {
			ret = (bool)true;
		} else {
			ret = (bool)false;
		}
		if (ret == (bool)true) {
			break;
		}
		if (timeout <= 0) {
			break;
		}
		msleep(20);
		timeout -= 20;
	}

	return ret;
}

static bool pcie_rkep_is_link_lost(struct pci_dev *pdev)
{
	u32 bar0, bar4;
	int ret;

	ret = pcie_capability_read_dword(pdev, PCI_BASE_ADDRESS_0, &bar0);
	if (ret < 0) {
		dev_warn(&pdev->dev, "%s read dword failed\n", __func__);
	}
	ret = pcie_capability_read_dword(pdev, PCI_BASE_ADDRESS_4, &bar4);
	if (ret < 0) {
		dev_warn(&pdev->dev, "%s read dword failed\n", __func__);
	}
	if (((bar0 == 0xffffffffU) || (bar0 == 0U)) &&
	    ((bar4 == 0xffffffffU) || (bar4 == 0U))) {
		return (bool)true;
	} else {
		return (bool)false;
	}
}

static int rkep_ep_dma_xfer(struct pcie_rkep *pcie_rkep,
			    struct pcie_ep_dma_block_req *dma)
{
	int ret;

	if (dma->wr != 0U) {
		ret = pcie_dw_wired_dma_tobus_block(pcie_rkep->dma_obj, dma->chn,
						    dma->block.bus_paddr,
						    dma->block.local_paddr,
						    dma->block.size);
	} else {
		ret = pcie_dw_wired_dma_frombus_block(pcie_rkep->dma_obj, dma->chn,
						      dma->block.local_paddr,
						      dma->block.bus_paddr,
						      dma->block.size);
	}

	return ret;
}

static int rkep_ep_request_virtual_id(struct pcie_file *pcie_file)
{
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	int index;

	mutex_lock(&pcie_rkep->dev_lock_mutex);
	index = find_first_zero_bit(pcie_rkep->virtual_id_bitmap,
				    RKEP_EP_VIRTUAL_ID_MAX);
	if (index >= (int)RKEP_EP_VIRTUAL_ID_MAX) {
		dev_err(&pcie_rkep->pdev->dev,
			"request virtual id %d is invalid\n", index);
		mutex_unlock(&pcie_rkep->dev_lock_mutex);
		return -EINVAL;
	}
	set_bit(index, pcie_rkep->virtual_id_bitmap);
	mutex_unlock(&pcie_rkep->dev_lock_mutex);

	mutex_lock(&pcie_file->file_lock_mutex);
	set_bit(index, pcie_file->child_vid_bitmap);
	mutex_unlock(&pcie_file->file_lock_mutex);

	dev_dbg(&pcie_rkep->pdev->dev, "request virtual id %d\n", index);

	return index;
}

static int rkep_ep_release_virtual_id(struct pcie_file *pcie_file, int index)
{
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;

	if (index >= (int)RKEP_EP_VIRTUAL_ID_MAX) {
		dev_err(&pcie_rkep->pdev->dev,
			"release virtual id %d out of range\n", index);
		return -EINVAL;
	}

	if (test_bit(index, pcie_rkep->virtual_id_bitmap) == 0U) {
		dev_err(&pcie_rkep->pdev->dev,
			"release virtual id %d is already free\n", index);
	}

	mutex_lock(&pcie_file->file_lock_mutex);
	__clear_bit(index, pcie_file->child_vid_bitmap);
	mutex_unlock(&pcie_file->file_lock_mutex);

	mutex_lock(&pcie_rkep->dev_lock_mutex);
	__clear_bit(index, pcie_rkep->virtual_id_bitmap);
	mutex_unlock(&pcie_rkep->dev_lock_mutex);

	dev_dbg(&pcie_rkep->pdev->dev, "release virtual id %d\n", index);

	return 0;
}

static int rkep_ep_raise_elbi_irq(struct pcie_file *pcie_file, u32 interrupt_num)
{
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	u32 index, off;
	unsigned long i, gap_us = 100;
	u32 val;
	int ret;
	int where;

	if (interrupt_num >= ((u32)PCIE_ELBI_REG_NUM * 16U)) {
		dev_err(&pcie_rkep->pdev->dev,
			"elbi int num out of max count\n");
		return -EINVAL;
	}

	index = interrupt_num / 16U;
	off   = interrupt_num % 16U;

	for (i = 0UL; i < (unsigned long)RKEP_EP_ELBI_TIEMOUT_US; i += gap_us) {
		where = (int)PCIE_CFG_ELBI_APP_OFFSET + 4 * (int)index;
		ret = pci_read_config_dword(pcie_rkep->pdev,
					    where,
					    &val);
		if (ret < 0) {
			dev_warn(&pcie_rkep->pdev->dev, "%s read config failed\n", __func__);
		}
		if ((val & ((u32)1U << off)) != 0U) {
			usleep_range(gap_us, gap_us + 10UL);
		} else {
			break;
		}
	}

	if (i >= gap_us) {
		dev_err(&pcie_rkep->pdev->dev,
			"elbi int is not clear, status=%x\n", val);
	}

	val = ((u32)1U << (off + 16U)) | ((u32)1U << off);
	ret = pci_write_config_dword(pcie_rkep->pdev,
				     where,
				     val);

	return ret;
}

static int rkep_ep_raise_irq_user_obj(struct pcie_file *pcie_file, u32 index)
{
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	int ret;

	if (index >= (u32)RKEP_EP_VIRTUAL_ID_MAX) {
		dev_err(&pcie_rkep->pdev->dev,
			"raise irq_user, virtual id %d out of range\n", index);
		return -EINVAL;
	}

	pcie_rkep->obj_info->irq_type_ep      = (u32)OBJ_IRQ_USER;
	pcie_rkep->obj_info->irq_user_data_ep = index;
	mutex_lock(&pcie_rkep->dev_lock_mutex);
	ret = rkep_ep_raise_elbi_irq(pcie_file, 0U);
	mutex_unlock(&pcie_rkep->dev_lock_mutex);

	return ret;
}

static int rkep_ep_poll_irq_user(struct pcie_file *pcie_file,
				 struct pcie_ep_obj_poll_virtual_id_cfg *cfg)
{
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	u32 index = cfg->virtual_id;

	if (index >= (u32)RKEP_EP_VIRTUAL_ID_MAX) {
		dev_err(&pcie_rkep->pdev->dev,
			"poll irq_user, virtual id %d out of range\n", index);
		return -EINVAL;
	}

	cfg->poll_status = NSIGPOLL;
	if (cfg->sync != 0U) {
		wait_event_interruptible(pcie_rkep->wq_head,
					 test_bit(index,
						  pcie_rkep->virtual_id_irq_bitmap));
	} else {
		wait_event_interruptible_timeout(pcie_rkep->wq_head,
						 test_bit(index,
							  pcie_rkep->virtual_id_irq_bitmap),
						 (int)cfg->timeout_ms);
	}
	if (test_and_clear_bit(index, pcie_rkep->virtual_id_irq_bitmap) != 0U) {
		cfg->poll_status = POLL_IN;
	}

	dev_dbg(&pcie_rkep->pdev->dev, "poll virtual id %d, ret=%d\n",
		index, cfg->poll_status);

	return 0;
}

static int pcie_rkep_open(struct inode *inode, struct file *file)
{
	struct miscdevice *miscdev = file->private_data;
	struct pcie_rkep *pcie_rkep = container_of(miscdev, struct pcie_rkep, dev);
	struct pcie_file *pcie_file;

	pcie_file = devm_kzalloc(&pcie_rkep->pdev->dev, sizeof(struct pcie_file),
				 GFP_KERNEL);
	if (!pcie_file) {
		return -ENOMEM;
	}

	pcie_file->pcie_rkep = pcie_rkep;

	mutex_init(&pcie_file->file_lock_mutex);

	file->private_data = pcie_file;

	return 0;
}

static int pcie_rkep_release(struct inode *inode, struct file *file)
{
	struct pcie_file *pcie_file = file->private_data;
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	int index;

	for (;;) {
		mutex_lock(&pcie_file->file_lock_mutex);
		index = find_first_bit(pcie_file->child_vid_bitmap,
				       RKEP_EP_VIRTUAL_ID_MAX);

		if (index >= (int)RKEP_EP_VIRTUAL_ID_MAX) {
			mutex_unlock(&pcie_file->file_lock_mutex);
			break;
		}

		__clear_bit(index, pcie_file->child_vid_bitmap);
		mutex_unlock(&pcie_file->file_lock_mutex);

		mutex_lock(&pcie_rkep->dev_lock_mutex);
		__clear_bit(index, pcie_rkep->virtual_id_bitmap);
		mutex_unlock(&pcie_rkep->dev_lock_mutex);

		dev_dbg(&pcie_rkep->pdev->dev, "release virtual id %d\n", index);
	}

	devm_kfree(&pcie_rkep->pdev->dev, pcie_file);

	return 0;
}

static ssize_t pcie_rkep_write(struct file *file, const char __user *buf,
			       size_t count, loff_t *ppos)
{
	struct pcie_file *pcie_file = file->private_data;
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	struct pci_dev *dev = pcie_rkep->pdev;
	unsigned int size = (u32)count;
	u32 init_off = (u32)(*ppos), off = (u32)(*ppos);
	u8 *data;
	int ret;

	data = kzalloc(PCI_CFG_SPACE_EXP_SIZE, GFP_KERNEL);
	if (!data) {
		return -ENOMEM;
	}

	if (off > (u32)dev->cfg_size) {
		kfree(data);
		return 0;
	}
	if (off + (u32)count > (u32)dev->cfg_size) {
		size = (u32)dev->cfg_size - off;
		count = size;
	}

	if (copy_from_user(data, buf, count) != 0UL) {
		kfree(data);
		return -EFAULT;
	}

	if ((off & 1U) != 0U && size > 0U) {
		ret = pci_write_config_byte(dev, (int)off, data[off - init_off]);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
		off++;
		size--;
	}

	if ((off & 3U) != 0U && size > 2U) {
		u16 val = data[off - init_off];

		val |= (u16)data[off - init_off + 1U] << (u16)8;
		ret = pci_write_config_word(dev, (int)off, val);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
		off += 2U;
		size -= 2U;
	}

	while (size > 3U) {
		u32 val = data[off - init_off];

		val |= (u32)data[off - init_off + 1U] << (u32)8;
		val |= (u32)data[off - init_off + 2U] << (u32)16;
		val |= (u32)data[off - init_off + 3U] << (u32)24;
		ret = pci_write_config_dword(dev, (int)off, val);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
		off += 4U;
		size -= 4U;
	}

	if (size >= 2U) {
		u16 val = data[off - init_off];

		val |= (u16)data[off - init_off + 1U] << (u16)8;
		ret = pci_write_config_word(dev, (int)off, val);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
		off += 2U;
		size -= 2U;
	}

	if (size > 0U) {
		ret = pci_write_config_byte(dev, (int)off, data[off - init_off]);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
	}

	kfree(data);

	return (ssize_t)count;
}

static ssize_t pcie_rkep_read(struct file *file, char __user *buf,
			      size_t count, loff_t *ppos)
{
	struct pcie_file *pcie_file = file->private_data;
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	struct pci_dev *dev = pcie_rkep->pdev;
	unsigned int size = (u32)count;
	u32 init_off = (u32)(*ppos), off = (u32)(*ppos);
	u8 *data;
	int ret;

	data = kzalloc(PCI_CFG_SPACE_EXP_SIZE, GFP_KERNEL);
	if (!data) {
		return -ENOMEM;
	}

	if (off > (u32)dev->cfg_size) {
		kfree(data);
		return 0;
	}
	if (off + (u32)count > (u32)dev->cfg_size) {
		size = (u32)dev->cfg_size - off;
		count = (size_t)size;
	}

	if ((off & 1U) != 0U && size > 0U) {
		u8 val;

		ret = pci_read_config_byte(dev, (int)off, &val);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s read config failed\n", __func__);
		}
		data[off - init_off] = val;
		off++;
		size--;
	}

	if ((off & 3U) != 0U && size > 2U) {
		u16 val;

		ret = pci_read_config_word(dev, (int)off, &val);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
		data[off - init_off] = (u8)val & 0xffU;
		data[off - init_off + 1U] = (u8)((val >> (u16)8) & 0xffU);
		off += 2U;
		size -= 2U;
	}

	while (size > 3U) {
		u32 val;

		ret = pci_read_config_dword(dev, (int)off, &val);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
		data[off - init_off] = (u8)(val & 0xffU);
		data[off - init_off + 1U] = (u8)((val >> (u32)8U) & 0xffU);
		data[off - init_off + 2U] = (u8)((val >> (u32)16U) & 0xffU);
		data[off - init_off + 3U] = (u8)((val >> (u32)24U) & 0xffU);
		off += 4U;
		size -= 4U;
	}

	if (size >= 2U) {
		u16 val;

		ret = pci_read_config_word(dev, (int)off, &val);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
		data[off - init_off] = (u8)(val & 0xffU);
		data[off - init_off + 1U] = (u8)((val >> (u16)8U) & 0xffU);
		off += 2U;
		size -= 2U;
	}

	if (size > 0U) {
		u8 val;

		ret = pci_read_config_byte(dev, (int)off, &val);
		if (ret < 0) {
			dev_warn(&dev->dev, "%s write config failed\n", __func__);
		}
		data[off - init_off] = val;
	}

	if (copy_to_user(buf, data, count) != 0UL) {
		kfree(data);
		return -EFAULT;
	}

	kfree(data);

	return (ssize_t)count;
}

static int pcie_rkep_mmap(struct file *file, struct vm_area_struct *vma)
{
	u64 addr;
	struct pcie_file *pcie_file = file->private_data;
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	struct pci_dev *dev = pcie_rkep->pdev;
	size_t size = vma->vm_end - vma->vm_start;
	resource_size_t bar_size;
	int err = 0;

	switch (pcie_rkep->cur_mmap_res) {
	case PCIE_EP_MMAP_RESOURCE_RK3568_RC_DBI:
		if (size > PCIE_DBI_SIZE) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "dbi mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = PCIE_RK3568_RC_DBI_BASE;
		break;

	case PCIE_EP_MMAP_RESOURCE_RK3588_RC_DBI:
		if (size > PCIE_DBI_SIZE) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "dbi mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = PCIE_RK3588_RC_DBI_BASE;
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR0:
		bar_size = pci_resource_len(dev, 0);
		if (size > bar_size) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "bar0 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = pci_resource_start(dev, 0);
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR1:
		bar_size = pci_resource_len(dev, 1);
		if (size > bar_size) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "bar1 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = pci_resource_start(dev, 1);
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR2:
		bar_size = pci_resource_len(dev, 2);
		if (size > bar_size) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "bar2 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = pci_resource_start(dev, 2);
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR4:
		bar_size = pci_resource_len(dev, 4);
		if (size > bar_size) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "bar4 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = pci_resource_start(dev, 4);
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR5:
		bar_size = pci_resource_len(dev, 5);
		if (size > bar_size) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "bar5 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = pci_resource_start(dev, 5);
		break;

	case PCIE_EP_MMAP_RESOURCE_USER_MEM:
		if (size > (size_t)RKEP_USER_MEM_SIZE) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "mmap size is out of limitation\n");
			return -EINVAL;
		}

		if (pcie_rkep->user_pages == NULL) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "user_pages has not been allocated yet\n");
			return -EINVAL;
		}
		addr = page_to_phys(pcie_rkep->user_pages);
		break;

	default:
		dev_err(&pcie_rkep->pdev->dev,
			"cur mmap_res %d is unsurreport\n",
			pcie_rkep->cur_mmap_res);
		err = -EINVAL;
		break;
	}
	if (err < 0) {
		return err;
	}

	if ((pcie_rkep->cur_mmap_res == (int)PCIE_EP_MMAP_RESOURCE_BAR2) ||
	    (pcie_rkep->cur_mmap_res == (int)PCIE_EP_MMAP_RESOURCE_USER_MEM)) {
		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
	} else {
		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
	}

	err = remap_pfn_range(vma, vma->vm_start,
			      __phys_to_pfn(addr),
			      size, vma->vm_page_prot);
	if (err != 0) {
		return -EAGAIN;
	}

	return 0;
}

static long pcie_rkep_ioctl(struct file *file, unsigned int cmd, unsigned long args)
{
	void __user *argp;
	struct pcie_file *pcie_file = file->private_data;
	struct pcie_rkep *pcie_rkep = pcie_file->pcie_rkep;
	struct pcie_ep_dma_cache_cfg cfg;
	struct pcie_ep_dma_block_req dma;
	void __user *uarg = (void __user *)args;
	struct pcie_ep_obj_poll_virtual_id_cfg poll_cfg;
	int mmap_res;
	int ret;
	int index;
	u64 addr;

	argp = (void __user *)args;

	switch (cmd) {
	case 0x4:
		/* get mapped physical address */
		if (pcie_rkep->user_pages == NULL) {
			dev_warn(&pcie_rkep->pdev->dev,
				 "user_pages has not been allocated yet\n");
			return -EINVAL;
		}
		addr = page_to_phys(pcie_rkep->user_pages);
		if (copy_to_user(argp, &addr, sizeof(addr)) != 0UL) {
			return -EFAULT;
		}
		break;

	case PCIE_DMA_CACHE_INVALIDE:
		ret = (int)copy_from_user(&cfg, uarg, sizeof(cfg));
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to get invalid cfg copy from userspace\n");
			return -EFAULT;
		}
		dma_sync_single_for_cpu(&pcie_rkep->pdev->dev, cfg.addr,
					cfg.size, DMA_FROM_DEVICE);
		break;

	case PCIE_DMA_CACHE_FLUSH:
		ret = (int)copy_from_user(&cfg, uarg, sizeof(cfg));
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to get flush cfg copy from userspace\n");
			return -EFAULT;
		}
		dma_sync_single_for_device(&pcie_rkep->pdev->dev, cfg.addr,
					   cfg.size, DMA_TO_DEVICE);
		break;

	case PCIE_EP_DMA_XFER_BLOCK:
		ret = (int)copy_from_user(&dma, uarg, sizeof(dma));
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to get dma_data copy from userspace\n");
			return -EFAULT;
		}
		ret = rkep_ep_dma_xfer(pcie_rkep, &dma);
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to transfer dma, ret=%d\n", ret);
			return -EFAULT;
		}
		break;

	case PCIE_EP_REQUEST_VIRTUAL_ID:
		index = rkep_ep_request_virtual_id(pcie_file);
		if (index < 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"request virtual id failed, ret=%d\n", index);
			return -EFAULT;
		}
		if (copy_to_user(argp, &index, sizeof(index)) != 0UL) {
			return -EFAULT;
		}
		break;

	case PCIE_EP_RELEASE_VIRTUAL_ID:
		ret = (int)copy_from_user(&index, uarg, sizeof(index));
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to get release data copy from userspace\n");
			return -EFAULT;
		}
		ret = rkep_ep_release_virtual_id(pcie_file, index);
		if (ret < 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"release virtual id %d failed, ret=%d\n",
				index, ret);
			return -EFAULT;
		}
		break;

	case PCIE_EP_RAISE_IRQ_USER:
		ret = (int)copy_from_user(&index, uarg, sizeof(index));
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to get raise irq data copy from userspace\n");
			return -EFAULT;
		}

		ret = rkep_ep_raise_irq_user_obj(pcie_file, (u32)index);
		if (ret < 0) {
			return -EFAULT;
		}
		break;

	case PCIE_EP_POLL_IRQ_USER:
		ret = (int)copy_from_user(&poll_cfg, uarg, sizeof(poll_cfg));
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to get poll irq data copy from userspace\n");
			return -EFAULT;
		}

		ret = rkep_ep_poll_irq_user(pcie_file, &poll_cfg);
		if (ret < 0) {
			return -EFAULT;
		}

		if (copy_to_user(argp, &poll_cfg, sizeof(poll_cfg)) != 0UL) {
			return -EFAULT;
		}
		break;

	case PCIE_EP_RAISE_ELBI:
		ret = (int)copy_from_user(&index, uarg, sizeof(index));
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to get raise elbi data copy from userspace\n");
			return -EFAULT;
		}
		ret = rkep_ep_raise_elbi_irq(pcie_file, (u32)index);
		if (ret < 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"raise elbi %d failed, ret=%d\n", index, ret);
			return -EFAULT;
		}
		break;

	case PCIE_EP_SET_MMAP_RESOURCE:
		ret = (int)copy_from_user(&mmap_res, uarg, sizeof(mmap_res));
		if (ret != 0) {
			dev_err(&pcie_rkep->pdev->dev,
				"failed to get copy from\n");
			return -EFAULT;
		}

		if (((int)mmap_res >= (int)PCIE_EP_MMAP_RESOURCE_MAX) || ((int)mmap_res < 0)) {
			dev_err(&pcie_rkep->pdev->dev,
				"mmap index %d is out of number\n", mmap_res);
			return -EINVAL;
		}

		pcie_rkep->cur_mmap_res = mmap_res;
		break;

	default:
		dev_err(&pcie_rkep->pdev->dev,
			"unknown ioctl cmd 0x%x\n", cmd);
		break;
	}

	return 0;
}

static const struct file_operations pcie_rkep_fops = {
	.owner          = THIS_MODULE,
	.open           = pcie_rkep_open,
	.write          = pcie_rkep_write,
	.read           = pcie_rkep_read,
	.unlocked_ioctl = pcie_rkep_ioctl,
	.mmap           = pcie_rkep_mmap,
	.release        = pcie_rkep_release,
	.llseek         = default_llseek,
};

static inline void pcie_rkep_writel_dbi(struct pcie_rkep *pcie_rkep, u32 reg, u32 val)
{
	writel(val, pcie_rkep->bar4 + reg);
}

static inline u32 pcie_rkep_readl_dbi(struct pcie_rkep *pcie_rkep, u32 reg)
{
	return readl(pcie_rkep->bar4 + reg);
}

static void pcie_rkep_dma_debug(struct dma_trx_obj *obj, struct dma_table *table)
{
	struct pci_dev *pdev = container_of(obj->dev, struct pci_dev, dev);
	struct pcie_rkep *pcie_rkep = pci_get_drvdata(pdev);
	unsigned int ctr_off = PCIE_DMA_OFFSET + (u32)table->chn * 0x200U;

	dev_err(&pdev->dev, "chnl=%x\n", table->start.chnl);
	dev_err(&pdev->dev, "%d\n", table->dir);
	if (table->dma_mode == (u32)RK_PCIE_DMA_BLOCK) {
		dev_err(&pdev->dev, "src=0x%x %x\n",
			table->ctx_reg.sarptrhi, table->ctx_reg.sarptrlo);
		dev_err(&pdev->dev, "dst=0x%x %x\n",
			table->ctx_reg.darptrhi, table->ctx_reg.darptrlo);
	} else {
		dev_err(&pdev->dev, "phys_descs=0x%llx\n", table->phys_descs);
	}
	dev_err(&pdev->dev, "xfersize=%x\n", table->ctx_reg.xfersize);

	if (table->dir == (u32)DMA_FROM_BUS) {
		if (table->dma_mode == (u32)RK_PCIE_DMA_BLOCK) {
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_INT_MASK = %x\n",
				PCIE_DMA_RD_INT_MASK,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_INT_MASK));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_ENB = %x\n",
				PCIE_DMA_RD_ENB,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_ENB));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_CTRL_LO = %x\n",
				ctr_off + PCIE_DMA_RD_CTRL_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_CTRL_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_CTRL_HI = %x\n",
				ctr_off + PCIE_DMA_RD_CTRL_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_CTRL_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_XFERSIZE = %x\n",
				ctr_off + PCIE_DMA_RD_XFERSIZE,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_XFERSIZE));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_SAR_PTR_LO = %x\n",
				ctr_off + PCIE_DMA_RD_SAR_PTR_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_SAR_PTR_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_SAR_PTR_HI = %x\n",
				ctr_off + PCIE_DMA_RD_SAR_PTR_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_SAR_PTR_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_DAR_PTR_LO = %x\n",
				ctr_off + PCIE_DMA_RD_DAR_PTR_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_DAR_PTR_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_DAR_PTR_HI = %x\n",
				ctr_off + PCIE_DMA_RD_DAR_PTR_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_DAR_PTR_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_DOORBELL = %x\n",
				PCIE_DMA_RD_DOORBELL,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_DOORBELL));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_INT_STATUS = %x\n",
				PCIE_DMA_RD_INT_STATUS,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_INT_STATUS));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_ERR_STATUS_LOW = %x\n",
				PCIE_DMA_RD_ERR_STATUS_LOW,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_ERR_STATUS_LOW));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_ERR_STATUS_HIGH = %x\n",
				PCIE_DMA_RD_ERR_STATUS_HIGH,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_ERR_STATUS_HIGH));
		} else {
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_INT_MASK = %x\n",
				PCIE_DMA_RD_INT_MASK,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_INT_MASK));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_ENB = %x\n",
				PCIE_DMA_RD_ENB,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_ENB));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_CTRL_LO = %x\n",
				ctr_off + PCIE_DMA_RD_CTRL_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_CTRL_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_CTRL_HI = %x\n",
				ctr_off + PCIE_DMA_RD_CTRL_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_CTRL_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_LL_PTR_LO = %x\n",
				ctr_off + PCIE_DMA_RD_LL_PTR_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_LL_PTR_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_LL_PTR_HI = %x\n",
				ctr_off + PCIE_DMA_RD_LL_PTR_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_RD_LL_PTR_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_DOORBELL = %x\n",
				PCIE_DMA_RD_DOORBELL,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_DOORBELL));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_ERR_STATUS_LOW = %x\n",
				PCIE_DMA_RD_ERR_STATUS_LOW,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_ERR_STATUS_LOW));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_RD_ERR_STATUS_HIGH = %x\n",
				PCIE_DMA_RD_ERR_STATUS_HIGH,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_RD_ERR_STATUS_HIGH));
		}
	} else {
		if (table->dma_mode == (u32)RK_PCIE_DMA_BLOCK) {
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_INT_MASK = %x\n",
				PCIE_DMA_WR_INT_MASK,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_INT_MASK));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_ENB = %x\n",
				PCIE_DMA_WR_ENB,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_ENB));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_CTRL_LO = %x\n",
				ctr_off + PCIE_DMA_WR_CTRL_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_CTRL_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_CTRL_HI = %x\n",
				ctr_off + PCIE_DMA_WR_CTRL_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_CTRL_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_XFERSIZE = %x\n",
				ctr_off + PCIE_DMA_WR_XFERSIZE,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_XFERSIZE));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_SAR_PTR_LO = %x\n",
				ctr_off + PCIE_DMA_WR_SAR_PTR_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_SAR_PTR_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_SAR_PTR_HI = %x\n",
				ctr_off + PCIE_DMA_WR_SAR_PTR_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_SAR_PTR_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_DAR_PTR_LO = %x\n",
				ctr_off + PCIE_DMA_WR_DAR_PTR_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_DAR_PTR_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_DAR_PTR_HI = %x\n",
				ctr_off + PCIE_DMA_WR_DAR_PTR_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_DAR_PTR_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_DOORBELL = %x\n",
				PCIE_DMA_WR_DOORBELL,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_DOORBELL));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_INT_STATUS = %x\n",
				PCIE_DMA_WR_INT_STATUS,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_INT_STATUS));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_ERR_STATUS = %x\n",
				PCIE_DMA_WR_ERR_STATUS,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_ERR_STATUS));
		} else {
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_INT_MASK = %x\n",
				PCIE_DMA_WR_INT_MASK,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_INT_MASK));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_ENB = %x\n",
				PCIE_DMA_WR_ENB,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_ENB));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_CTRL_LO = %x\n",
				ctr_off + PCIE_DMA_WR_CTRL_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_CTRL_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_CTRL_HI = %x\n",
				ctr_off + PCIE_DMA_WR_CTRL_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_CTRL_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_LL_PTR_LO = %x\n",
				ctr_off + PCIE_DMA_WR_LL_PTR_LO,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_LL_PTR_LO));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_LL_PTR_HI = %x\n",
				ctr_off + PCIE_DMA_WR_LL_PTR_HI,
				pcie_rkep_readl_dbi(pcie_rkep,
						    ctr_off +
						    PCIE_DMA_WR_LL_PTR_HI));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_DOORBELL = %x\n",
				PCIE_DMA_WR_DOORBELL,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_DOORBELL));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_INT_STATUS = %x\n",
				PCIE_DMA_WR_INT_STATUS,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_INT_STATUS));
			dev_err(&pdev->dev, "reg[0x%x] PCIE_DMA_WR_ERR_STATUS = %x\n",
				PCIE_DMA_WR_ERR_STATUS,
				pcie_rkep_readl_dbi(pcie_rkep,
						    PCIE_DMA_OFFSET +
						    PCIE_DMA_WR_ERR_STATUS));
		}
	}
}

static void pcie_rkep_start_dma_rd(struct dma_trx_obj *obj,
				   struct dma_table *cur, int ctr_off)
{
	struct pci_dev *pdev = container_of(obj->dev, struct pci_dev, dev);
	struct pcie_rkep *pcie_rkep = pci_get_drvdata(pdev);

	if (cur->dma_mode == (u32)RK_PCIE_DMA_BLOCK) {
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET + PCIE_DMA_RD_ENB,
				     cur->enb.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_CTRL_LO,
				     cur->ctx_reg.ctrllo.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_CTRL_HI,
				     cur->ctx_reg.ctrlhi.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_XFERSIZE,
				     cur->ctx_reg.xfersize);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_SAR_PTR_LO,
				     cur->ctx_reg.sarptrlo);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_SAR_PTR_HI,
				     cur->ctx_reg.sarptrhi);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_DAR_PTR_LO,
				     cur->ctx_reg.darptrlo);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_DAR_PTR_HI,
				     cur->ctx_reg.darptrhi);
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET + PCIE_DMA_RD_DOORBELL,
				     cur->start.asdword);
	} else {
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET + PCIE_DMA_RD_ENB,
				     cur->enb.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_CTRL_LO,
				     cur->ctx_reg.ctrllo.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_CTRL_HI,
				     cur->ctx_reg.ctrlhi.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_LL_PTR_LO,
				     lower_32_bits(cur->phys_descs));
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_RD_LL_PTR_HI,
				     upper_32_bits(cur->phys_descs));
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET + PCIE_DMA_RD_DOORBELL,
				     cur->start.asdword);
	}
	/* pcie_rkep_dma_debug(obj, cur); */
}

static void pcie_rkep_start_dma_wr(struct dma_trx_obj *obj,
				   struct dma_table *cur, int ctr_off)
{
	struct pci_dev *pdev = container_of(obj->dev, struct pci_dev, dev);
	struct pcie_rkep *pcie_rkep = pci_get_drvdata(pdev);

	if (cur->dma_mode == (u32)RK_PCIE_DMA_BLOCK) {
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET + PCIE_DMA_WR_ENB,
				     cur->enb.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_CTRL_LO,
				     cur->ctx_reg.ctrllo.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_CTRL_HI,
				     cur->ctx_reg.ctrlhi.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_XFERSIZE,
				     cur->ctx_reg.xfersize);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_SAR_PTR_LO,
				     cur->ctx_reg.sarptrlo);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_SAR_PTR_HI,
				     cur->ctx_reg.sarptrhi);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_DAR_PTR_LO,
				     cur->ctx_reg.darptrlo);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_DAR_PTR_HI,
				     cur->ctx_reg.darptrhi);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_WEILO,
				     cur->weilo.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET + PCIE_DMA_WR_DOORBELL,
				     cur->start.asdword);
	} else {
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET + PCIE_DMA_WR_ENB,
				     cur->enb.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_CTRL_LO,
				     cur->ctx_reg.ctrllo.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_CTRL_HI,
				     cur->ctx_reg.ctrlhi.asdword);
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_LL_PTR_LO,
				     lower_32_bits(cur->phys_descs));
		pcie_rkep_writel_dbi(pcie_rkep,
				     (u32)ctr_off + PCIE_DMA_WR_LL_PTR_HI,
				     upper_32_bits(cur->phys_descs));
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET + PCIE_DMA_WR_DOORBELL,
				     cur->start.asdword);
	}
	/* pcie_rkep_dma_debug(obj, cur); */
}

static void pcie_rkep_start_dma_dwc(struct dma_trx_obj *obj,
				    struct dma_table *table)
{
	u32 dir = table->dir;
	int chn = table->chn;

	int ctr_off = (int)PCIE_DMA_OFFSET + chn * 0x200;

	if (dir == (u32)DMA_FROM_BUS) {
		pcie_rkep_start_dma_rd(obj, table, ctr_off);
	} else {
		pcie_rkep_start_dma_wr(obj, table, ctr_off);
	}
}

static void pcie_rkep_config_dma_dwc(struct dma_table *table)
{
	if (table->dma_mode == (u32)RK_PCIE_DMA_BLOCK) {
		table->enb.enb           = 0x1U;
		table->ctx_reg.ctrllo.lie = 0x1U;
		table->ctx_reg.ctrllo.rie = 0x0U;
		table->ctx_reg.ctrllo.td  = 0x1U;
		table->ctx_reg.ctrlhi.asdword = 0x0U;
		table->ctx_reg.xfersize  = (u32)table->buf_size;
		if (table->dir == (u32)DMA_FROM_BUS) {
			table->ctx_reg.sarptrlo =
				(u32)(table->bus & 0xffffffffULL);
			table->ctx_reg.sarptrhi =
				(u32)(table->bus >> 32);
			table->ctx_reg.darptrlo =
				(u32)(table->local & 0xffffffffULL);
			table->ctx_reg.darptrhi =
				(u32)(table->local >> 32);
		} else {
			table->ctx_reg.sarptrlo =
				(u32)(table->local & 0xffffffffULL);
			table->ctx_reg.sarptrhi =
				(u32)(table->local >> 32);
			table->ctx_reg.darptrlo =
				(u32)(table->bus & 0xffffffffULL);
			table->ctx_reg.darptrhi =
				(u32)(table->bus >> 32);
		}
		table->weilo.weight0     = 0x0U;
		table->start.stop        = 0x0U;
		table->start.chnl        = (u8)table->chn;
	} else {
		table->enb.enb           = 0x1U;
		table->ctx_reg.ctrllo.lie = 0x1U;
		table->ctx_reg.ctrllo.rie = 0x0U;
		table->ctx_reg.ctrllo.ccs = 0x1U;
		table->ctx_reg.ctrllo.llen = 0x1U;
		table->ctx_reg.ctrlhi.asdword = 0x0U;
		table->start.chnl        = (u8)table->chn;
	}
}

static int pcie_rkep_get_dma_status(struct dma_trx_obj *obj, u8 chn,
				    enum dma_dir dir)
{
	struct pci_dev *pdev = container_of(obj->dev, struct pci_dev, dev);
	struct pcie_rkep *pcie_rkep = pci_get_drvdata(pdev);
	union int_status status;
	union int_clear clears;
	int ret = 0;

	dev_dbg(&pdev->dev, "%s %x %x\n", __func__,
		pcie_rkep_readl_dbi(pcie_rkep,
				    PCIE_DMA_OFFSET + PCIE_DMA_WR_INT_STATUS),
		pcie_rkep_readl_dbi(pcie_rkep,
				    PCIE_DMA_OFFSET + PCIE_DMA_RD_INT_STATUS));

	if ((u32)dir == (u32)DMA_TO_BUS) {
		status.asdword =
			pcie_rkep_readl_dbi(pcie_rkep,
					    PCIE_DMA_OFFSET +
					    PCIE_DMA_WR_INT_STATUS);
		if ((status.donesta & (1U << chn)) != 0U) {
			clears.doneclr = (1U << chn);
			pcie_rkep_writel_dbi(pcie_rkep,
					     PCIE_DMA_OFFSET +
					     PCIE_DMA_WR_INT_CLEAR,
					     clears.asdword);
			ret = 1;
		}

		if ((status.abortsta & (1U << chn)) != 0U) {
			dev_err(&pdev->dev, "%s, write abort %x\n",
				__func__, status.asdword);
			clears.abortclr = (1U << chn);
			pcie_rkep_writel_dbi(pcie_rkep,
					     PCIE_DMA_OFFSET +
					     PCIE_DMA_WR_INT_CLEAR,
					     clears.asdword);
			ret = -1;
		}
	} else {
		status.asdword =
			pcie_rkep_readl_dbi(pcie_rkep,
					    PCIE_DMA_OFFSET +
					    PCIE_DMA_RD_INT_STATUS);

		if ((status.donesta & (1U << chn)) != 0U) {
			clears.doneclr = (1U << chn);
			pcie_rkep_writel_dbi(pcie_rkep,
					     PCIE_DMA_OFFSET +
					     PCIE_DMA_RD_INT_CLEAR,
					     clears.asdword);
			ret = 1;
		}

		if ((status.abortsta & (1U << chn)) != 0U) {
			dev_err(&pdev->dev, "%s, read abort %x\n",
				__func__, status.asdword);
			clears.abortclr = (1U << chn);
			pcie_rkep_writel_dbi(pcie_rkep,
					     PCIE_DMA_OFFSET +
					     PCIE_DMA_RD_INT_CLEAR,
					     clears.asdword);
			ret = -1;
		}
	}

	return ret;
}

static int pcie_rkep_obj_handler(struct pcie_rkep *pcie_rkep,
				 struct pci_dev *pdev)
{
	union int_status wr_status, rd_status;
	u32 irq_type;
	u32 chn;
	union int_clear clears;
	u32 reg;

	irq_type = pcie_rkep->obj_info->irq_type_rc;
	if (irq_type == (u32)OBJ_IRQ_DMA) {
		/* DMA helper */
		wr_status.asdword = pcie_rkep->obj_info->dma_status_rc.wr;
		rd_status.asdword = pcie_rkep->obj_info->dma_status_rc.rd;

		for (chn = 0U; chn < (u32)PCIE_DMA_CHANEL_MAX_NUM; chn++) {
			if ((wr_status.donesta & (1U << chn)) != 0U) {
				if ((pcie_rkep->dma_obj != NULL) &&
				    (pcie_rkep->dma_obj->cb != NULL)) {
					pcie_rkep->dma_obj->cb(pcie_rkep->dma_obj,
							       chn, DMA_TO_BUS);
					clears.doneclr = 1U << chn;
					pcie_rkep->obj_info->dma_status_rc.wr &=
						~(u32)clears.doneclr;
				}
			}

			if ((wr_status.abortsta & (1U << chn)) != 0U) {
				dev_err(&pdev->dev, "%s, abort\n", __func__);
				if ((pcie_rkep->dma_obj != NULL) &&
				    (pcie_rkep->dma_obj->cb != NULL)) {
					clears.abortclr = 1U << chn;
					pcie_rkep->obj_info->dma_status_rc.wr &=
						~(u32)clears.abortclr;
				}
			}
		}

		for (chn = 0U; chn < (u32)PCIE_DMA_CHANEL_MAX_NUM; chn++) {
			if ((rd_status.donesta & (1U << chn)) != 0U) {
				if ((pcie_rkep->dma_obj != NULL) &&
				    (pcie_rkep->dma_obj->cb != NULL)) {
					pcie_rkep->dma_obj->cb(pcie_rkep->dma_obj,
							       chn,
							       DMA_FROM_BUS);
					clears.doneclr = 1U << chn;
					pcie_rkep->obj_info->dma_status_rc.rd &=
						~(u32)clears.doneclr;
				}
			}

			if ((rd_status.abortsta & (1U << chn)) != 0U) {
				dev_err(&pdev->dev, "%s, abort\n", __func__);
				if ((pcie_rkep->dma_obj != NULL) &&
				    (pcie_rkep->dma_obj->cb != NULL)) {
					clears.abortclr = 1U << chn;
					pcie_rkep->obj_info->dma_status_rc.rd &=
						~(u32)clears.abortclr;
				}
			}
		}
	} else if (irq_type == (u32)OBJ_IRQ_USER) {
		reg = pcie_rkep->obj_info->irq_user_data_rc;
		if (reg < (u32)RKEP_EP_VIRTUAL_ID_MAX) {
			set_bit(reg, pcie_rkep->virtual_id_irq_bitmap);
			wake_up_interruptible(&pcie_rkep->wq_head);
		}
	} else {
		dev_err(&pdev->dev, "%s unkown\n", __func__);
	}

	return 0;
}

static irqreturn_t pcie_rkep_pcie_interrupt(int irq, void *context)
{
	struct pcie_rkep_irq_context *ctx = context;
	struct pci_dev *pdev = ctx->dev;
	struct pcie_rkep *pcie_rkep = pci_get_drvdata(pdev);
	int ret;

	if (pcie_rkep == NULL) {
		return IRQ_HANDLED;
	}

	/*
	 * The irq 0 is the dedicated interrupt for obj to issue remote rc device.
	 */
	if (irq == pci_irq_vector(pcie_rkep->pdev, PCIe_CLIENT_MSI_IRQ_OBJ)) {
		ret = pcie_rkep_obj_handler(pcie_rkep, pdev);
		if (ret < 0) {
			dev_err(&pdev->dev, "%s failed\n", __func__);
		}
	}

	return IRQ_HANDLED;
}

static void pcie_rkep_release_irq(struct pcie_rkep *pcie_rkep)
{
	u32 i;

	if (pcie_rkep->irq_valid != 0) {
		for (i = 0U; i < (u32)pcie_rkep->irq_valid; i++) {
			if (i >= RKEP_NUM_IRQ_VECTORS) {
				return;
			}
			pci_free_irq(pcie_rkep->pdev, i,
				     &pcie_rkep->irq_ctx[i]);
		}

		pci_free_irq_vectors(pcie_rkep->pdev);
	}
	pcie_rkep->irq_valid = 0;
}

static int pcie_rkep_request_irq(struct pcie_rkep *pcie_rkep, int irq_type)
{
	int nvec, ret = -EINVAL;
	u32 i;

	/* Using msi as default */
	nvec = pci_alloc_irq_vectors(pcie_rkep->pdev, 1, RKEP_NUM_IRQ_VECTORS,
				     (u32)irq_type);
	if (nvec < 0) {
		return nvec;
	}

	if (nvec != (int)RKEP_NUM_IRQ_VECTORS) {
		dev_err(&pcie_rkep->pdev->dev,
			"only allocate %d irq interrupt, irq_type=%d\n",
			nvec, irq_type);
	}

	pcie_rkep->irq_valid = 0;

	if (nvec > (int)RKEP_NUM_IRQ_VECTORS) {
		nvec = (int)RKEP_NUM_IRQ_VECTORS;
	}
	for (i = 0U; i < (u32)nvec; i++) {
		pcie_rkep->irq_ctx[i].dev    = pcie_rkep->pdev;
		pcie_rkep->irq_ctx[i].msg_id = (u16)i;
		ret = pci_request_irq(pcie_rkep->pdev, i,
				      pcie_rkep_pcie_interrupt, NULL,
				      &pcie_rkep->irq_ctx[i],
				      "%s-%d", pcie_rkep->dev.name, i);
		if (ret != 0) {
			break;
		}
		pcie_rkep->irq_valid++;
	}

	if (ret != 0) {
		pcie_rkep_release_irq(pcie_rkep);
		dev_err(&pcie_rkep->pdev->dev,
			"fail to allocate msi interrupt\n");
	} else {
		dev_err(&pcie_rkep->pdev->dev,
			"success to request msi irq\n");
	}

	return ret;
}

static int rkep_loadfile(struct device *dev, const char *path, void __iomem *bar, int pos)
{
	struct file *p_file;
	size_t size;
	loff_t offset;
	ssize_t result;
	int ret;

	p_file = filp_open(path, O_RDONLY | O_LARGEFILE, 0);
	if (IS_ERR(p_file) || (p_file == NULL)) {
		dev_err(dev, "unable to open file: %s\n", path);
		return -ENODEV;
	}

	size = (size_t)i_size_read(file_inode(p_file));
	dev_info(dev, "%s file %s size %lld to %p\n",
		 __func__, path, size, bar + pos);

	offset = 0;
	result = kernel_read(p_file, (void *)bar + pos, size, &offset);
	if (result < 0) {
		return -EINVAL;
	}

	dev_info(dev, "kernel_read size %lld from %s to %p\n",
		 size, path, bar + pos);

	ret = filp_close(p_file, NULL);
	if (ret < 0) {
		return ret;
	}

	return 0;
}

#define RKEP_CMD_LOADER_RUN     0x524b4501U
static ssize_t rkep_store(struct device *dev,
			  struct device_attribute *attr,
			  const char *buf, size_t count)
{
	struct pcie_rkep *pcie_rkep = dev_get_drvdata(dev);
	u32 val;
	int ret;

	ret = kstrtou32(buf, 0, &val);
	if (ret != 0) {
		return -EINVAL;
	}

	dev_info(dev, "%s val %u\n", __func__, val);
	if (val == 1U) {
		ret = rkep_loadfile(dev, "/data/uboot.img", pcie_rkep->bar2, 0);
		if (ret < 0) {
			return ret;
		}
	} else if (val == 2U) {
		ret = rkep_loadfile(dev, "/data/boot.img", pcie_rkep->bar2, 0x400000);
		if (ret < 0) {
			return ret;
		}
	} else if (val == 3U) {
		writel(RKEP_CMD_LOADER_RUN, pcie_rkep->bar0 + 0x400U);
	} else {
		dev_err(dev, "%s unkown cmd\n", __func__);
	}

	dev_info(dev, "%s done\n", __func__);

	return (ssize_t)count;
}
static DEVICE_ATTR_WO(rkep);

static int pcie_rkep_probe(struct pci_dev *pdev, const struct pci_device_id *id)
{
	int ret;
	struct pcie_rkep *pcie_rkep;
	u8 *name;
	u16 val;

	pcie_rkep = devm_kzalloc(&pdev->dev, sizeof(*pcie_rkep), GFP_KERNEL);
	if (!pcie_rkep) {
		return -ENOMEM;
	}

	name = devm_kzalloc(&pdev->dev, MISC_DEV_NAME_MAX_LENGTH, GFP_KERNEL);
	if (!name) {
		return -ENOMEM;
	}

	set_bit(0, pcie_rkep->virtual_id_bitmap);

	ret = pci_enable_device(pdev);
	if (ret != 0) {
		dev_err(&pdev->dev, "pci_enable_device failed %d\n", ret);
		goto err_pci_enable_dev;
	}

	ret = pci_request_regions(pdev, DRV_NAME);
	if (ret != 0) {
		dev_err(&pdev->dev, "pci_request_regions failed %d\n", ret);
		goto err_req_regions;
	}

	pcie_rkep->bar0 = pci_iomap(pdev, 0, 0);
	if (pcie_rkep->bar0 == NULL) {
		dev_err(&pdev->dev, "pci_iomap bar0 failed\n");
		ret = -ENOMEM;
		goto err_pci_iomap;
	}
	pcie_rkep->obj_info = (struct pcie_ep_obj_info *)pcie_rkep->bar0;
	dev_dbg(&pdev->dev, "get bar0 address is %p\n", pcie_rkep->bar0);

	pcie_rkep->bar2 = pci_iomap(pdev, 2, 0);
	if (pcie_rkep->bar2 == NULL) {
		dev_err(&pdev->dev, "pci_iomap bar2 failed");
		ret = -ENOMEM;
		goto err_pci_iomap;
	}
	dev_dbg(&pdev->dev, "get bar2 address is %p\n", pcie_rkep->bar2);

	pcie_rkep->bar4 = pci_iomap(pdev, 4, 0);
	if (pcie_rkep->bar4 == NULL) {
		dev_err(&pdev->dev, "pci_iomap bar4 failed\n");
		ret = -ENOMEM;
		goto err_pci_iomap;
	}

	dev_dbg(&pdev->dev, "get bar4 address is %p\n", pcie_rkep->bar4);

	ret = snprintf(name, MISC_DEV_NAME_MAX_LENGTH, "%s-%s",
		       DRV_NAME, dev_name(&pdev->dev));
	if (ret < 0) {
		dev_err(&pdev->dev, "%s snprintf failed\n", __func__);
	}
	pcie_rkep->dev.minor  = MISC_DYNAMIC_MINOR;
	pcie_rkep->dev.name   = name;
	pcie_rkep->dev.fops   = &pcie_rkep_fops;
	pcie_rkep->dev.parent = NULL;

	mutex_init(&pcie_rkep->dev_lock_mutex);

	ret = misc_register(&pcie_rkep->dev);
	if (ret != 0) {
		dev_err(&pdev->dev, "failed to register misc device.\n");
		goto err_pci_iomap;
	}

	pcie_rkep->pdev = pdev; /* Save pci device struct */

	pci_set_drvdata(pdev, pcie_rkep);

	init_waitqueue_head(&pcie_rkep->wq_head);
	ret = pcie_rkep_request_irq(pcie_rkep, PCI_IRQ_MSI);
	if (ret != 0) {
		goto err_register_irq;
	}

	pcie_rkep->dma_obj = pcie_dw_dmatest_register(&pdev->dev, false);
	if (IS_ERR(pcie_rkep->dma_obj)) {
		dev_err(&pcie_rkep->pdev->dev, "failed to prepare dmatest\n");
		ret = -EINVAL;
		goto err_register_obj;
	}

	if (pcie_rkep->dma_obj != NULL) {
		ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
		if (ret < 0) {
			goto err_register_obj;
		}
		pcie_rkep->dma_obj->start_dma_func = pcie_rkep_start_dma_dwc;
		pcie_rkep->dma_obj->config_dma_func = pcie_rkep_config_dma_dwc;
		pcie_rkep->dma_obj->get_dma_status = pcie_rkep_get_dma_status;
		pcie_rkep->dma_obj->dma_debug = pcie_rkep_dma_debug;
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET +
				     PCIE_DMA_WR_INT_MASK,
				     0xffffffffU);
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET +
				     PCIE_DMA_RD_INT_MASK,
				     0xffffffffU);

		/* Enable linked list err en */
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET +
				     PCIE_DMA_WR_LL_ERR_EN,
				     0xffffffffU);
		pcie_rkep_writel_dbi(pcie_rkep,
				     PCIE_DMA_OFFSET +
				     PCIE_DMA_RD_LL_ERR_EN,
				     0xffffffffU);
	}

#if IS_ENABLED(CONFIG_PCIE_FUNC_RKEP_USERPAGES)
	pcie_rkep->user_pages =
		alloc_contig_pages(RKEP_USER_MEM_SIZE >> PAGE_SHIFT,
				   GFP_KERNEL, 0, NULL);
	if (pcie_rkep->user_pages == NULL) {
		dev_err(&pcie_rkep->pdev->dev,
			"failed to allocate contiguous pages\n");
		ret = -EINVAL;
		if (pcie_rkep->dma_obj != NULL) {
			pcie_dw_dmatest_unregister(pcie_rkep->dma_obj);
		}
		goto err_register_obj;
	}
	pcie_rkep->cur_mmap_res = PCIE_EP_MMAP_RESOURCE_USER_MEM;
	dev_info(&pdev->dev,
		 "successfully allocate continuous buffer for userspace\n");
#endif

	ret = pci_read_config_word(pcie_rkep->pdev, (int)PCI_VENDOR_ID, &val);
	if (ret > 0) {
		dev_err(&pdev->dev, "%s read config failed\n", __func__);
	}
	dev_info(&pdev->dev, "vid=%x\n", val);
	ret = pci_read_config_word(pcie_rkep->pdev, (int)PCI_DEVICE_ID, &val);
	if (ret > 0) {
		dev_err(&pdev->dev, "%s read config failed\n", __func__);
	}
	dev_info(&pdev->dev, "did=%x\n", val);
	dev_info(&pdev->dev, "obj_info magic=%x, ver=%x\n",
		 pcie_rkep->obj_info->magic,
		 pcie_rkep->obj_info->version);

	ret = pci_save_state(pdev);
	if (ret > 0) {
		dev_err(&pdev->dev, "%s save state failed\n", __func__);
	}

	ret = device_create_file(&pdev->dev, &dev_attr_rkep);
	if (ret > 0) {
		dev_err(&pdev->dev, "%s create file failed\n", __func__);
	}

	return 0;

err_register_obj:
	pcie_rkep_release_irq(pcie_rkep);
err_register_irq:
	misc_deregister(&pcie_rkep->dev);
err_pci_iomap:
	if (pcie_rkep->bar0 != NULL) {
		pci_iounmap(pdev, pcie_rkep->bar0);
	}
	if (pcie_rkep->bar2 != NULL) {
		pci_iounmap(pdev, pcie_rkep->bar2);
	}
	if (pcie_rkep->bar4 != NULL) {
		pci_iounmap(pdev, pcie_rkep->bar4);
	}
	pci_release_regions(pdev);
err_req_regions:
	pci_disable_device(pdev);
err_pci_enable_dev:

	return ret;
}

static void pcie_rkep_remove(struct pci_dev *pdev)
{
	struct pcie_rkep *pcie_rkep = pci_get_drvdata(pdev);

	if (pcie_rkep->dma_obj != NULL) {
		pcie_dw_dmatest_unregister(pcie_rkep->dma_obj);
	}

	device_remove_file(&pdev->dev, &dev_attr_rkep);
#if IS_ENABLED(CONFIG_PCIE_FUNC_RKEP_USERPAGES)
	free_contig_range(page_to_pfn(pcie_rkep->user_pages),
			  RKEP_USER_MEM_SIZE >> PAGE_SHIFT);
#endif
	pcie_rkep_release_irq(pcie_rkep);

	if (pcie_rkep->bar0 != NULL) {
		pci_iounmap(pdev, pcie_rkep->bar0);
	}
	if (pcie_rkep->bar2 != NULL) {
		pci_iounmap(pdev, pcie_rkep->bar2);
	}
	if (pcie_rkep->bar4 != NULL) {
		pci_iounmap(pdev, pcie_rkep->bar4);
	}
	pci_release_regions(pdev);
	pci_disable_device(pdev);
	misc_deregister(&pcie_rkep->dev);
}

static enum pci_ers_result pcie_rkep_error_detected(struct pci_dev *pdev,
						 pci_channel_state_t state)
{
	enum pci_ers_result ret;

	dev_warn(&pdev->dev, "error detected, state=%d link=%d\n",
		 state, pcie_rkep_is_link_lost(pdev));

	switch (state) {
	case pci_channel_io_normal:
		if (pcie_rkep_is_link_lost(pdev) != (bool)false) {
			ret = PCI_ERS_RESULT_NEED_RESET;
		} else {
			ret = PCI_ERS_RESULT_CAN_RECOVER;
		}
		break;
	case pci_channel_io_frozen:
		dev_warn(&pdev->dev,
			 "frozen state error detected, reset controller\n");
		ret = PCI_ERS_RESULT_NEED_RESET;
		break;
	case pci_channel_io_perm_failure:
		dev_warn(&pdev->dev,
			 "failure state error detected, request disconnect\n");
		ret = PCI_ERS_RESULT_DISCONNECT;
		break;
	default:
		dev_err(&pdev->dev, "%s unkown state\n", __func__);
		ret = PCI_ERS_RESULT_NEED_RESET;
		break;
	}

	return ret;
}

static enum pci_ers_result pcie_rkep_slot_reset(struct pci_dev *pdev)
{
	dev_info(&pdev->dev, "restart after slot reset\n");

	if (pcie_rkep_wait_for_link_up(pdev) != (bool)false) {
		pci_restore_state(pdev);
		return PCI_ERS_RESULT_RECOVERED;
	} else {
		return PCI_ERS_RESULT_DISCONNECT;
	}
}

static const struct pci_error_handlers pcie_rkep_err_handler = {
	.error_detected = pcie_rkep_error_detected,
	.slot_reset     = pcie_rkep_slot_reset,
};

static const struct pci_device_id pcie_rkep_pcidev_id[] = {
	{ PCI_VDEVICE(ROCKCHIP, 0x356a), 1,  },
	{ }
};
MODULE_DEVICE_TABLE(pcie, pcie_rkep_pcidev_id);

static struct pci_driver pcie_rkep_driver = {
	.name        = DRV_NAME,
	.id_table    = pcie_rkep_pcidev_id,
	.probe       = pcie_rkep_probe,
	.remove      = pcie_rkep_remove,
	.err_handler = &pcie_rkep_err_handler,
};

module_pci_driver(pcie_rkep_driver);

MODULE_DESCRIPTION("Rockchip PCIe RKEP endpoint function driver");
MODULE_LICENSE("GPL");
MODULE_IMPORT_NS(VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver);
