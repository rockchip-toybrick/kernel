// SPDX-License-Identifier: GPL-2.0
/*
 * PCIe EP controller driver for Rockchip SoCs
 *
 * Copyright (C) 2021 Rockchip Electronics Co., Ltd.
 *		http://www.rock-chips.com
 *
 * Author: Simon Xue <xxm@rock-chips.com>
 */

#include <linux/clk.h>
#include <linux/gpio/consumer.h>
#include <linux/miscdevice.h>
#include <linux/mfd/syscon.h>
#include <linux/module.h>
#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/phy/phy.h>
#include <linux/platform_device.h>
#include <linux/regmap.h>
#include <linux/reset.h>
#include <linux/uaccess.h>
#include <uapi/linux/rk-pcie-ep.h>

#include "../rockchip-pcie-dma.h"
#include "pcie-designware.h"
#include "pcie-dw-dmatest.h"

/*
 * The upper 16 bits of PCIE_CLIENT_CONFIG are a write
 * mask for the lower 16 bits.
 */
#define HIWORD_UPDATE(mask, val)	(((mask) << 16U) | (val))
#define HIWORD_UPDATE_BIT(val)		HIWORD_UPDATE(val, val)

#define to_rockchip_pcie(x)		dev_get_drvdata((x)->dev)

#define PCIE_DMA_OFFSET			0x380000U

#define PCIE_DMA_CTRL_OFF		0x8U
#define PCIE_DMA_WR_ENB			0xcU
#define PCIE_DMA_WR_CTRL_LO		0x200U
#define PCIE_DMA_WR_CTRL_HI		0x204U
#define PCIE_DMA_WR_XFERSIZE		0x208U
#define PCIE_DMA_WR_SAR_PTR_LO		0x20cU
#define PCIE_DMA_WR_SAR_PTR_HI		0x210U
#define PCIE_DMA_WR_DAR_PTR_LO		0x214U
#define PCIE_DMA_WR_DAR_PTR_HI		0x218U
#define PCIE_DMA_WR_WEILO		0x18U
#define PCIE_DMA_WR_WEIHI		0x1cU
#define PCIE_DMA_WR_DOORBELL		0x10U
#define PCIE_DMA_WR_INT_STATUS		0x4cU
#define PCIE_DMA_WR_INT_MASK		0x54U
#define PCIE_DMA_WR_INT_CLEAR		0x58U

#define PCIE_DMA_RD_ENB			0x2cU
#define PCIE_DMA_RD_CTRL_LO		0x300U
#define PCIE_DMA_RD_CTRL_HI		0x304U
#define PCIE_DMA_RD_XFERSIZE		0x308U
#define PCIE_DMA_RD_SAR_PTR_LO		0x30cU
#define PCIE_DMA_RD_SAR_PTR_HI		0x310U
#define PCIE_DMA_RD_DAR_PTR_LO		0x314U
#define PCIE_DMA_RD_DAR_PTR_HI		0x318U
#define PCIE_DMA_RD_WEILO		0x38U
#define PCIE_DMA_RD_WEIHI		0x3cU
#define PCIE_DMA_RD_DOORBELL		0x30U
#define PCIE_DMA_RD_INT_STATUS		0xa0U
#define PCIE_DMA_RD_INT_MASK		0xa8U
#define PCIE_DMA_RD_INT_CLEAR		0xacU

#define PCIE_DMA_CHANEL_MAX_NUM		2U

#define PCIE_CLIENT_RC_MODE		0x400040U
#define PCIE_CLIENT_ENABLE_LTSSM	0xC000CU
#define PCIE_CLIENT_INTR_STATUS_MISC	0x10U
#define PCIE_SMLH_LINKUP		0x10000U
#define PCIE_RDLH_LINKUP		0x20000U
#define PCIE_L0S_ENTRY			0x11U
#define PCIE_CLIENT_GENERAL_CONTROL	0x0U
#define PCIE_CLIENT_GENERAL_DEBUG	0x104U
#define PCIE_CLIENT_HOT_RESET_CTRL      0x180U
#define PCIE_CLIENT_LTSSM_STATUS	0x300U
#define PCIE_CLIENT_INTR_MASK		0x24U
#define PCIE_LTSSM_APP_DLY1_EN		(1U << 0)
#define PCIE_LTSSM_APP_DLY2_EN		(1U << 1)
#define PCIE_LTSSM_APP_DLY1_DONE	(1U << 2)
#define PCIE_LTSSM_APP_DLY2_DONE	(1U << 3)
#define PCIE_LTSSM_ENABLE_ENHANCE       (1U << 4)
#define PCIE_CLIENT_MSI_GEN_CON		0x38U

#define PCIe_CLIENT_MSI_OBJ_IRQ		0U	/* rockchip ep object special irq */

#define PCIE_ELBI_REG_NUM		2
#define PCIE_ELBI_LOCAL_BASE		0x200e00U

#define PCIE_ELBI_APP_ELBI_INT_GEN0		0x0U
#define PCIE_ELBI_APP_ELBI_INT_GEN0_IRQ_USER	(1U << 0)

#define PCIE_ELBI_APP_ELBI_INT_GEN1		0x4U

#define PCIE_ELBI_LOCAL_ENABLE_OFF	0x8U

#define PCIE_ELBI_USER_DATA_OFF	0x10U

#define PCIE_DIRECT_SPEED_CHANGE	(1U << 17)

#define PCIE_TYPE0_STATUS_COMMAND_REG	0x4U
#define PCIE_TYPE0_HDR_DBI2_OFFSET	0x100000U

#define PCIE_DBI_SIZE			0x400000U

#define PCIE_EP_OBJ_INFO_DRV_VERSION	0x00000001U

#define PCIE_BAR_MAX_NUM		6U
#define PCIE_HOTRESET_TMOUT_US		10000U

struct rockchip_pcie {
	struct dw_pcie			pci;
	void __iomem			*apb_base;
	struct phy			*phy;
	struct clk_bulk_data		*clks;
	int				clk_cnt;
	struct reset_control		*rst;
	struct gpio_desc		*rst_gpio;
	unsigned long			*ib_window_map;
	unsigned long			*ob_window_map;
	u32				num_ib_windows;
	u32				num_ob_windows;
	phys_addr_t			*outbound_addr;
	u8				bar_to_atu[PCIE_BAR_MAX_NUM];
	dma_addr_t			ib_target_address[PCIE_BAR_MAX_NUM];
	u32				ib_target_size[PCIE_BAR_MAX_NUM];
	void				*ib_target_base[PCIE_BAR_MAX_NUM];
	struct dma_trx_obj		*dma_obj;
	phys_addr_t			dbi_base_physical;
	struct pcie_ep_obj_info		*obj_info;
	enum pcie_ep_mmap_resource	cur_mmap_res;
	u32				irq;
	struct workqueue_struct		*hot_rst_wq;
	struct work_struct		hot_rst_work;
	struct mutex			file_mutex;
	DECLARE_BITMAP(virtual_id_irq_bitmap, RKEP_EP_VIRTUAL_ID_MAX);
	wait_queue_head_t		wq_head;
};

struct rockchip_pcie_misc_dev {
	struct miscdevice		dev;
	struct rockchip_pcie		*pcie;
};

static const struct of_device_id rockchip_pcie_ep_of_match[] = {
	{
		.compatible = "rockchip,rk3568-pcie-std-ep",
	},
	{
		.compatible = "rockchip,rk3588-pcie-std-ep",
	},
	{},
};

MODULE_DEVICE_TABLE(of, rockchip_pcie_ep_of_match);

static void rockchip_pcie_devmode_update(struct rockchip_pcie *rockchip, int mode, int submode)
{
	rockchip->obj_info->devmode.mode    = (u16)mode;
	rockchip->obj_info->devmode.submode = (u16)submode;
}

static u32 rockchip_pcie_readl_apb(struct rockchip_pcie *rockchip, u32 reg)
{
	return readl(rockchip->apb_base + reg);
}

static void rockchip_pcie_writel_apb(struct rockchip_pcie *rockchip, u32 val, u32 reg)
{
	writel(val, rockchip->apb_base + reg);
}

static void *rockchip_pcie_map_kernel(phys_addr_t start, size_t len)
{
	int i;
	void *vaddr;
	pgprot_t pgprot;
	phys_addr_t phys;
	int aligned = ((int)len + (int)PAGE_SIZE - 1) / (int)PAGE_SIZE;
	int pagesize = (int)PAGE_SIZE;
	int npages = aligned / pagesize;
	struct page **p = vmalloc(sizeof(struct page *) * (size_t)npages);

	if (!p) {
		return NULL;
	}

	pgprot = pgprot_noncached(PAGE_KERNEL);

	phys = start;
	for (i = 0; i < npages; i++) {
		p[i] = phys_to_page(phys);
		phys += PAGE_SIZE;
	}

	vaddr = vmap(p, (unsigned int)npages, VM_MAP, pgprot);
	vfree(p);

	return vaddr;
}

static int rockchip_pcie_get_io_resource(struct platform_device *pdev,
					 struct rockchip_pcie *rockchip)
{
	int ret;
	struct device *dev = &pdev->dev;
	struct device_node *np = dev->of_node;
	void *addr;
	struct resource *apb_res, *dbi_res;
	struct device_node *mem;
	struct resource reg;
	char name[8];
	int i, idx;

	rockchip->rst_gpio = devm_gpiod_get_optional(dev, "reset", GPIOD_IN);
	if (IS_ERR(rockchip->rst_gpio)) {
		dev_err(dev, "Failed to get reset gpio\n");
		return (int)PTR_ERR(rockchip->rst_gpio);
	}

	apb_res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "pcie-apb");
	if (!apb_res) {
		dev_err(&pdev->dev, "Failed to get pcie-apb\n");
		return -ENODEV;
	}

	rockchip->apb_base = devm_ioremap_resource(dev, apb_res);
	if (IS_ERR(rockchip->apb_base)) {
		return (int)PTR_ERR(rockchip->apb_base);
	}

	dbi_res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "pcie-dbi");
	if (!dbi_res) {
		dev_err(&pdev->dev, "Failed to get pcie-dbi\n");
		return -ENODEV;
	}

	rockchip->pci.dbi_base = devm_ioremap_resource(dev, dbi_res);
	if (IS_ERR(rockchip->pci.dbi_base)) {
		return (int)PTR_ERR(rockchip->pci.dbi_base);
	}
	rockchip->pci.atu_base = rockchip->pci.dbi_base + DEFAULT_DBI_ATU_OFFSET;
	rockchip->dbi_base_physical = dbi_res->start;

	ret = device_property_read_u32(dev, "num-ib-windows", &rockchip->num_ib_windows);
	if ((ret < 0) || (rockchip->num_ib_windows > MAX_IATU_IN)) {
		dev_err(dev, "Invalid *num-ib-windows*\n");
		return -EINVAL;
	}

	ret = device_property_read_u32(dev, "num-ob-windows", &rockchip->num_ob_windows);
	if ((ret < 0) || (rockchip->num_ob_windows > MAX_IATU_OUT)) {
		dev_err(dev, "Invalid *num-ob-windows*, num=%d\n", rockchip->num_ob_windows);
		return -EINVAL;
	}

	rockchip->ib_window_map = devm_kcalloc(dev,
					       rockchip->num_ib_windows,
					       sizeof(long), GFP_KERNEL);
	if (!rockchip->ib_window_map) {
		return -ENOMEM;
	}

	rockchip->ob_window_map = devm_kcalloc(dev,
					       rockchip->num_ob_windows,
					       sizeof(long), GFP_KERNEL);
	if (!rockchip->ob_window_map) {
		return -ENOMEM;
	}

	addr = devm_kcalloc(dev, rockchip->num_ob_windows, sizeof(phys_addr_t), GFP_KERNEL);
	if (!addr) {
		return -ENOMEM;
	}
	rockchip->outbound_addr = addr;

	for (i = 0; i < (int)PCIE_BAR_MAX_NUM; i++) {
		ret = snprintf(name, sizeof(name), "bar%d", i);
		if (ret <= 0) {
			return -EINVAL;
		}
		idx = of_property_match_string(np, "memory-region-names", name);
		if (idx < 0) {
			continue;
		}

		mem = of_parse_phandle(np, "memory-region", idx);
		if (!mem) {
			dev_err(dev, "missing \"memory-region\" %s property\n", name);
			return -ENODEV;
		}

		ret = of_address_to_resource(mem, 0, &reg);
		if (ret < 0) {
			dev_err(dev, "missing \"reg\" %s property\n", name);
			return -ENODEV;
		}

		rockchip->ib_target_address[i] = reg.start;
		rockchip->ib_target_size[i]    = (u32)resource_size(&reg);
		rockchip->ib_target_base[i]    = rockchip_pcie_map_kernel(reg.start,
									  resource_size(&reg));
		dev_info(dev, "%s: assigned [0x%llx-%llx]\n", name,
			 rockchip->ib_target_address[i],
			 rockchip->ib_target_address[i] + rockchip->ib_target_size[i] - 1ULL);
	}

	if (rockchip->ib_target_size[0] > 0U) {
		rockchip->obj_info = (struct pcie_ep_obj_info *)rockchip->ib_target_base[0];
		memset_io(rockchip->obj_info, 0, sizeof(struct pcie_ep_obj_info));
		rockchip->obj_info->magic   = PCIE_EP_OBJ_INFO_MAGIC;
		rockchip->obj_info->version = PCIE_EP_OBJ_INFO_DRV_VERSION;
		rockchip_pcie_devmode_update(rockchip, RKEP_MODE_KERNEL, RKEP_SMODE_INIT);
	} else {
		dev_err(dev, "missing bar0 memory region\n");
		return -ENODEV;
	}

	return 0;
}

static int rockchip_pcie_get_resource(struct platform_device *pdev,
				      struct rockchip_pcie *rockchip)
{
	struct device *dev = &pdev->dev;
	int ret;

	ret = rockchip_pcie_get_io_resource(pdev, rockchip);
	if (ret != 0) {
		dev_err(dev, "Failed to get io resources %d\n", ret);
		return ret;
	}

	rockchip->clk_cnt = devm_clk_bulk_get_all(dev, &rockchip->clks);
	if (rockchip->clk_cnt < 0) {
		dev_err(dev, "Failed to get clk_bulk\n");
		return rockchip->clk_cnt;
	}

	rockchip->rst = devm_reset_control_array_get_exclusive(dev);
	if (IS_ERR(rockchip->rst)) {
		dev_err(dev, "Failed to get reset lines\n");
		return (int)PTR_ERR(rockchip->rst);
	}

	rockchip->phy = devm_phy_get(dev, "pcie-phy");
	if (IS_ERR(rockchip->phy)) {
		dev_err(dev, "Failed to get pcie-phy\n");
		return (int)PTR_ERR(rockchip->phy);
	}

	rockchip->irq = platform_get_irq_byname(pdev, "sys");
	if (rockchip->irq < 0) {
		dev_err(dev, "Failed to get sys irq\n");
		return -EINVAL;
	}

	return 0;
}

static int rockchip_pci_find_ext_capability(struct rockchip_pcie *rockchip, int cap)
{
	u32 header, val;
	int ttl;
	int start = 0;
	int pos = PCI_CFG_SPACE_SIZE;

	/* minimum 8 bytes per capability */
	ttl = (PCI_CFG_SPACE_EXP_SIZE - PCI_CFG_SPACE_SIZE) / 8;

	header = dw_pcie_readl_dbi(&rockchip->pci, (u32)pos);

	/*
	 * If we have no capabilities, this is indicated by cap ID,
	 * cap version and next pointer all being 0.
	 */
	if (header == 0U) {
		return 0;
	}

	while (ttl > 0) {
		ttl--;
		if (((header & (u32)0x0000ffff) == (u32)cap) && (pos != start)) {
			return pos;
		}

		val = (header >> ((u32)20)) & ((u32)0xffc);
		pos = (int)(val);
		if (pos < PCI_CFG_SPACE_SIZE) {
			break;
		}

		header = dw_pcie_readl_dbi(&rockchip->pci, (u32)pos);
		if (header == 0U) {
			break;
		}
	}

	return 0;
}

static void rockchip_pcie_ep_set_bar_flag(struct rockchip_pcie *rockchip,
					 enum pci_barno barno, int flags)
{
	enum pci_barno bar = barno;
	u32 reg;

	reg = (u32)PCI_BASE_ADDRESS_0 + ((u32)bar * 4U);

	/* Disabled the upper 32bits BAR to make a 64bits bar pair */
	if (((u32)flags & (u32)PCI_BASE_ADDRESS_MEM_TYPE_64) != 0U) {
		dw_pcie_writel_dbi(&rockchip->pci, reg + PCIE_TYPE0_HDR_DBI2_OFFSET + 4U, 0U);
	}

	dw_pcie_writel_dbi(&rockchip->pci, reg, (u32)flags);
	if (((u32)flags & (u32)PCI_BASE_ADDRESS_MEM_TYPE_64) != 0U) {
		dw_pcie_writel_dbi(&rockchip->pci, reg + 4U, 0U);
	}
}

static void rockchip_pcie_resize_bar_nsticky(struct rockchip_pcie *rockchip)
{
	struct dw_pcie *pci = &rockchip->pci;
	enum pci_barno bar;
	u32 resbar_base;
	int val;

	dw_pcie_dbi_ro_wr_en(&rockchip->pci);

	resbar_base = (u32)rockchip_pci_find_ext_capability(rockchip, PCI_EXT_CAP_ID_REBAR);

	/* Resize BAR0 4M 32bits, BAR2 64M 64bits-pref, BAR4 1MB 32bits */
	bar = BAR_0;
	dw_pcie_writel_dbi(pci, resbar_base + 0x4U + ((u32)bar * 8U), 0x40U);
	dw_pcie_writel_dbi(pci, resbar_base + 0x8U + ((u32)bar * 8U), 0x2c0U);
	rockchip_pcie_ep_set_bar_flag(rockchip, (enum pci_barno)bar,
				      PCI_BASE_ADDRESS_MEM_TYPE_32);

	bar = BAR_1;
	dw_pcie_writel_dbi(pci, resbar_base + 0x4U + ((u32)bar * 8U), 0x10U);
	dw_pcie_writel_dbi(pci, resbar_base + 0x8U + ((u32)bar * 8U), 0xc0U);
	rockchip_pcie_ep_set_bar_flag(rockchip, (enum pci_barno)bar,
				      PCI_BASE_ADDRESS_MEM_TYPE_32);

	bar = BAR_2;
	dw_pcie_writel_dbi(pci, resbar_base + 0x4U + ((u32)bar * 8U), 0x400U);
	dw_pcie_writel_dbi(pci, resbar_base + 0x8U + ((u32)bar * 8U), 0x6c0U);
	val = (int)((u32)PCI_BASE_ADDRESS_MEM_PREFETCH | (u32)PCI_BASE_ADDRESS_MEM_TYPE_64);
	rockchip_pcie_ep_set_bar_flag(rockchip, (enum pci_barno)bar, val);

	bar = BAR_4;
	dw_pcie_writel_dbi(pci, resbar_base + 0x4U + ((u32)bar * 8U), 0x10U);
	dw_pcie_writel_dbi(pci, resbar_base + 0x8U + ((u32)bar * 8U), 0xc0U);
	rockchip_pcie_ep_set_bar_flag(rockchip, (enum pci_barno)bar,
				      PCI_BASE_ADDRESS_MEM_TYPE_32);

	bar = BAR_5;
	dw_pcie_writel_dbi(pci, resbar_base + 0x4U + ((u32)bar * 8U), 0x10U);
	dw_pcie_writel_dbi(pci, resbar_base + 0x8U + ((u32)bar * 8U), 0xc0U);
	rockchip_pcie_ep_set_bar_flag(rockchip, (enum pci_barno)bar,
				      PCI_BASE_ADDRESS_MEM_TYPE_32);

	/* Disable BAR1 BAR5*/
	bar = BAR_1;
	if (rockchip->ib_target_size[bar] == 0U) {
		dw_pcie_writel_dbi(pci, PCIE_TYPE0_HDR_DBI2_OFFSET + 0x10U + ((u32)bar * 4U), 0U);
	}
	bar = BAR_5;
	if (rockchip->ib_target_size[bar] == 0U) {
		dw_pcie_writel_dbi(pci, PCIE_TYPE0_HDR_DBI2_OFFSET + 0x10U + ((u32)bar * 4U), 0U);
	}
	dw_pcie_dbi_ro_wr_dis(&rockchip->pci);
}

static int rockchip_pcie_ep_set_bar(struct rockchip_pcie *rockchip, int bar,
				    dma_addr_t cpu_addr)
{
	int ret;
	int free_win;
	struct dw_pcie *pci = &rockchip->pci;

	if (bar >= PCIE_BAR_MAX_NUM) {
		return -EINVAL;
	}

	free_win = find_first_zero_bit(rockchip->ib_window_map,
				       rockchip->num_ib_windows);
	if (free_win >= (int)rockchip->num_ib_windows) {
		dev_err(pci->dev, "No free inbound window\n");
		return -EINVAL;
	}

	ret = dw_pcie_prog_inbound_atu(pci, 0U, free_win, bar, cpu_addr, DW_PCIE_AS_MEM);
	if (ret < 0) {
		dev_err(pci->dev, "Failed to program IB window\n");
		return ret;
	}

	rockchip->bar_to_atu[bar] = (u8)free_win;
	set_bit((u32)free_win, rockchip->ib_window_map);

	return 0;
}

static void rockchip_pcie_elbi_clear(struct rockchip_pcie *rockchip)
{
	int i;
	u32 elbi_reg;
	struct dw_pcie *pci = &rockchip->pci;
	u32 val;

	for (i = 0; i < PCIE_ELBI_REG_NUM; i++) {
		elbi_reg = PCIE_ELBI_LOCAL_BASE + ((u32)i * 4U);
		val      = dw_pcie_readl_dbi(pci, elbi_reg);
		val    <<= 16;
		dw_pcie_writel_dbi(pci, elbi_reg, val);
	}
}

static void rockchip_pcie_raise_msi_irq(struct rockchip_pcie *rockchip, u32 interrupt_num)
{
	rockchip_pcie_writel_apb(rockchip, (u32)(1U << interrupt_num),
				 PCIE_CLIENT_MSI_GEN_CON);
}

static int rockchip_pcie_raise_irq_user(struct rockchip_pcie *rockchip, u32 index)
{
	if (index >= (u32)RKEP_EP_VIRTUAL_ID_MAX) {
		dev_err(rockchip->pci.dev,
			"raise irq_user, virtual id %d out of range\n", index);
		return -EINVAL;
	}

	mutex_lock(&rockchip->file_mutex);
	rockchip->obj_info->irq_type_rc        = (u32)OBJ_IRQ_USER;
	rockchip->obj_info->irq_user_data_rc   = index;
	rockchip_pcie_raise_msi_irq(rockchip, PCIe_CLIENT_MSI_OBJ_IRQ);
	mutex_unlock(&rockchip->file_mutex);

	return 0;
}

static int rockchip_pcie_poll_irq_user(struct rockchip_pcie *rockchip,
				       struct pcie_ep_obj_poll_virtual_id_cfg *cfg)
{
	u32 index = cfg->virtual_id;

	if (index >= (u32)RKEP_EP_VIRTUAL_ID_MAX) {
		dev_err(rockchip->pci.dev,
			"poll irq_user, virtual id %d out of range\n", index);
		return -EINVAL;
	}

	cfg->poll_status = NSIGPOLL;
	if (cfg->sync != 0U) {
		wait_event_interruptible(rockchip->wq_head,
					 test_bit(index, rockchip->virtual_id_irq_bitmap));
	} else {
		wait_event_interruptible_timeout(rockchip->wq_head,
						 test_bit(index, rockchip->virtual_id_irq_bitmap),
						 cfg->timeout_ms);
	}
	if (test_and_clear_bit(index, rockchip->virtual_id_irq_bitmap)) {
		cfg->poll_status = POLL_IN;
	}

	dev_dbg(rockchip->pci.dev, "poll virtual id %d, ret=%d\n",
		index, cfg->poll_status);

	return 0;
}

static irqreturn_t rockchip_pcie_sys_irq_handler(int irq, void *arg)
{
	struct rockchip_pcie *rockchip = arg;
	struct dw_pcie *pci = &rockchip->pci;
	u32 elbi_reg;
	u32 chn;
	union int_status wr_status, rd_status;
	union int_clear clears;
	u32 reg, mask;
	bool ret;

	/* ELBI helper, only check the valid bits, and discard the rest interrupts */
	elbi_reg = dw_pcie_readl_dbi(pci, PCIE_ELBI_LOCAL_BASE + PCIE_ELBI_APP_ELBI_INT_GEN0);
	if ((elbi_reg & PCIE_ELBI_APP_ELBI_INT_GEN0_IRQ_USER) != 0U) {
		rockchip_pcie_elbi_clear(rockchip);

		if (rockchip->obj_info->irq_type_ep == (u32)OBJ_IRQ_USER) {
			reg = rockchip->obj_info->irq_user_data_ep;
			if (reg < (u32)RKEP_EP_VIRTUAL_ID_MAX) {
				set_bit(reg, rockchip->virtual_id_irq_bitmap);
				wake_up_interruptible(&rockchip->wq_head);
			}
		}
		goto out;
	}

	/* DMA helper */
	mask = dw_pcie_readl_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_WR_INT_MASK);
	wr_status.asdword = dw_pcie_readl_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_WR_INT_STATUS) &
			    (~mask);
	mask = dw_pcie_readl_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_RD_INT_MASK);
	rd_status.asdword = dw_pcie_readl_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_RD_INT_STATUS) &
			    (~mask);

	for (chn = 0U; chn < (u32)PCIE_DMA_CHANEL_MAX_NUM; chn++) {
		if ((wr_status.donesta & (1U << chn)) != 0U) {
			clears.doneclr = (1U << chn);
			dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET +
					   PCIE_DMA_WR_INT_CLEAR, clears.asdword);
			if ((rockchip->dma_obj != NULL) && (rockchip->dma_obj->cb != NULL)) {
				rockchip->dma_obj->cb(rockchip->dma_obj, chn, DMA_TO_BUS);
			}
		}

		if ((wr_status.abortsta & (1U << chn)) != 0U) {
			dev_err(pci->dev, "%s, abort\n", __func__);
			clears.abortclr = (1U << chn);
			dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET +
					   PCIE_DMA_WR_INT_CLEAR, clears.asdword);
		}
	}

	for (chn = 0U; chn < (u32)PCIE_DMA_CHANEL_MAX_NUM; chn++) {
		if ((rd_status.donesta & (1U << chn)) != 0U) {
			clears.doneclr = (1U << chn);
			dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET +
					   PCIE_DMA_RD_INT_CLEAR, clears.asdword);
			if ((rockchip->dma_obj != NULL) && (rockchip->dma_obj->cb != NULL)) {
				rockchip->dma_obj->cb(rockchip->dma_obj, chn, DMA_FROM_BUS);
			}
		}

		if ((rd_status.abortsta & (1U << chn)) != 0U) {
			dev_err(pci->dev, "%s, read abort %x\n", __func__, rd_status.asdword);
			clears.abortclr = (1U << chn);
			dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET +
					   PCIE_DMA_RD_INT_CLEAR, clears.asdword);
		}
	}

	if ((wr_status.asdword != 0U) || (rd_status.asdword != 0U)) {
		rockchip->obj_info->irq_type_rc = (u32)OBJ_IRQ_DMA;
		rockchip->obj_info->dma_status_rc.wr |= wr_status.asdword;
		rockchip->obj_info->dma_status_rc.rd |= rd_status.asdword;
		rockchip_pcie_raise_msi_irq(rockchip, PCIe_CLIENT_MSI_OBJ_IRQ);

		rockchip->obj_info->irq_type_ep = (u32)OBJ_IRQ_DMA;
		rockchip->obj_info->dma_status_ep.wr |= wr_status.asdword;
		rockchip->obj_info->dma_status_ep.rd |= rd_status.asdword;
	}

out:
	reg = rockchip_pcie_readl_apb(rockchip, PCIE_CLIENT_INTR_STATUS_MISC);
	if ((reg & (1U << 2)) != 0U) {
		ret = queue_work(rockchip->hot_rst_wq, &rockchip->hot_rst_work);
		if (ret == (bool)false) {
			dev_err(pci->dev, "queue_work failed\n");
		}
	}

	rockchip_pcie_writel_apb(rockchip, reg, PCIE_CLIENT_INTR_STATUS_MISC);

	return IRQ_HANDLED;
}

static void rockchip_pcie_hot_rst_work(struct work_struct *work)
{
	struct rockchip_pcie *rockchip = container_of(work, struct rockchip_pcie, hot_rst_work);
	u32 status;
	int ret;

	/* Reinit none-sticky register */
	rockchip_pcie_resize_bar_nsticky(rockchip);

	if ((rockchip_pcie_readl_apb(rockchip, PCIE_CLIENT_HOT_RESET_CTRL) &
	     PCIE_LTSSM_APP_DLY2_EN) != 0U) {
		ret = readl_poll_timeout(rockchip->apb_base + PCIE_CLIENT_LTSSM_STATUS,
					 status, ((status & 0x3FU) == 0U), 100,
					 PCIE_HOTRESET_TMOUT_US);
		if (ret < 0) {
			dev_err(rockchip->pci.dev, "wait for detect quiet failed!\n");
		}

		status = (u32)PCIE_LTSSM_APP_DLY2_DONE << 16U;
		status = PCIE_LTSSM_APP_DLY2_DONE | status;
		rockchip_pcie_writel_apb(rockchip,
					 status,
					 PCIE_CLIENT_HOT_RESET_CTRL);
	}
}

static int rockchip_pcie_link_up(struct dw_pcie *pci)
{
	struct rockchip_pcie *rockchip = to_rockchip_pcie(pci);
	u32 val = rockchip_pcie_readl_apb(rockchip, PCIE_CLIENT_LTSSM_STATUS);
	u32 mask = PCIE_RDLH_LINKUP | PCIE_SMLH_LINKUP;

	if ((val & mask) == 0x30000U) {
		return 1;
	}

	return 0;
}

static int rockchip_pcie_init_host(struct rockchip_pcie *rockchip)
{
	struct device *dev = rockchip->pci.dev;
	int ret;

	ret = clk_bulk_prepare_enable(rockchip->clk_cnt, rockchip->clks);
	if (ret < 0) {
		return 0;
	}

	if (dw_pcie_link_up(&rockchip->pci) != 0) {
		dev_info(dev, "Already linkup\n");
		return 0;
	}

	ret = phy_init(rockchip->phy);
	if (ret < 0) {
		goto disable_clk_bulk;
	}
	ret = phy_power_on(rockchip->phy);
	if (ret < 0) {
		goto disable_clk_bulk;
	}

	ret = reset_control_deassert(rockchip->rst);
	if (ret < 0) {
		goto disable_phy;
	}

	ret = phy_calibrate(rockchip->phy);
	if (ret != 0) {
		dev_err(dev, "phy lock failed\n");
		goto disable_controller;
	}

	return 0;

disable_controller:
	ret = reset_control_assert(rockchip->rst);
	if (ret < 0) {
		dev_err(dev, "reset_control_assert failed\n");
	}

disable_phy:
	ret = phy_exit(rockchip->phy);
	if (ret < 0) {
		dev_err(dev, "phy_exit failed\n");
	}
	ret = phy_power_off(rockchip->phy);
	if (ret < 0) {
		dev_err(dev, "phy_power_off failed\n");
	}
disable_clk_bulk:
	clk_bulk_disable_unprepare(rockchip->clk_cnt, rockchip->clks);

	return ret;
}

static int rockchip_pcie_deinit_host(struct rockchip_pcie *rockchip)
{
	struct device *dev = rockchip->pci.dev;
	int ret;

	ret = phy_exit(rockchip->phy);
	if (ret < 0) {
		dev_err(dev, "phy_exit failed\n");
	}
	ret = phy_power_off(rockchip->phy);
	if (ret < 0) {
		dev_err(dev, "phy_power_off failed\n");
	}
	clk_bulk_disable_unprepare(rockchip->clk_cnt, rockchip->clks);

	return 0;
}

static int rockchip_pcie_config_host(struct rockchip_pcie *rockchip)
{
	struct device *dev = rockchip->pci.dev;
	struct dw_pcie *pci = &rockchip->pci;
	u32 reg, val;
	int ret, retries, i;

	if (dw_pcie_link_up(&rockchip->pci) != 0) {
		goto already_linkup;
	} else {
		dev_info(dev, "Configure complete registers\n");
	}

	dw_pcie_setup(&rockchip->pci);

	dw_pcie_dbi_ro_wr_en(&rockchip->pci);
	/* Enable bus master and memory space */
	dw_pcie_writel_dbi(pci, PCIE_TYPE0_STATUS_COMMAND_REG, 0x6U);

	/* Enable bar and setting vid/did */
	dw_pcie_writew_dbi(&rockchip->pci, PCI_DEVICE_ID, 0x356aU);
	dw_pcie_writew_dbi(&rockchip->pci, PCI_CLASS_DEVICE, 0x0580U);

	/* Disable ASPM */
	reg = dw_pcie_find_capability(&rockchip->pci, PCI_CAP_ID_EXP);
	if (reg == 0U) {
		dev_err(dev, "Not able to find PCIE CAP!\n");
		return (int)reg;
	}
	val = dw_pcie_readl_dbi(&rockchip->pci, reg + (u32)PCI_EXP_LNKCAP);
	val &= ~((u32)PCI_EXP_LNKCAP_ASPMS);
	dw_pcie_writew_dbi(&rockchip->pci, reg + (u32)PCI_EXP_LNKCAP, (u16)val);
	dw_pcie_dbi_ro_wr_dis(&rockchip->pci);

	rockchip_pcie_resize_bar_nsticky(rockchip);

	/* Enable rasdes */
	reg = (u32)rockchip_pci_find_ext_capability(rockchip, PCI_EXT_CAP_ID_VNDR);
	if (reg == 0U) {
		dev_err(dev, "Not able to find RASDES CAP!\n");
		return (int)reg;
	}
	dw_pcie_writel_dbi(&rockchip->pci, reg + 8U, 0x1cU);
	dw_pcie_writel_dbi(&rockchip->pci, reg + 8U, 0x3U);

	/* Setting EP mode */
	rockchip_pcie_writel_apb(rockchip, 0xf00000U, 0x0U);

	/* Enable hot reset ltssm dly2 */
	val = rockchip_pcie_readl_apb(rockchip, PCIE_CLIENT_HOT_RESET_CTRL);
	val |= (u32)(PCIE_LTSSM_APP_DLY2_EN) << 16U;
	val |= (u32)(PCIE_LTSSM_ENABLE_ENHANCE) << 16U;
	val |= (PCIE_LTSSM_ENABLE_ENHANCE | PCIE_LTSSM_APP_DLY2_EN);
	rockchip_pcie_writel_apb(rockchip, val, PCIE_CLIENT_HOT_RESET_CTRL);

	/* Enable linking */
	rockchip_pcie_writel_apb(rockchip, PCIE_CLIENT_ENABLE_LTSSM, PCIE_CLIENT_GENERAL_CONTROL);
	rockchip_pcie_devmode_update(rockchip, RKEP_MODE_KERNEL, RKEP_SMODE_LNKRDY);

	/* Detect hot reset and clear the status */
	reg = rockchip_pcie_readl_apb(rockchip, PCIE_CLIENT_INTR_STATUS_MISC);
	if (((reg & (1U << 2)) != 0U) &&
	    ((rockchip_pcie_readl_apb(rockchip, PCIE_CLIENT_HOT_RESET_CTRL) &
	      PCIE_LTSSM_APP_DLY2_EN) != 0U)) {
		rockchip_pcie_writel_apb(rockchip,
					 PCIE_LTSSM_APP_DLY2_DONE |
					 ((u32)PCIE_LTSSM_APP_DLY2_DONE << 16U),
					 PCIE_CLIENT_HOT_RESET_CTRL);
		dev_info(dev, "hot reset ever\n");
	}
	rockchip_pcie_writel_apb(rockchip, reg, PCIE_CLIENT_INTR_STATUS_MISC);

	retries = 1000;
	for (i = 0; i < retries; i++) {
		if (dw_pcie_link_up(&rockchip->pci) != 0) {
			/*
			 * We may be here in case of L0 in Gen1. But if EP is capable
			 * of Gen2 or Gen3, Gen switch may happen just in this time, but
			 * we keep on accessing devices in unstable link status. Given
			 * that LTSSM max timeout is 24ms per period, we can wait a bit
			 * more for Gen switch.
			 */
			msleep(50);
			/* In case link drop after linkup, double check it */
			if (dw_pcie_link_up(pci) != 0) {
				dev_info(pci->dev, "PCIe Link up, LTSSM is 0x%x\n",
					 rockchip_pcie_readl_apb(rockchip, PCIE_CLIENT_LTSSM_STATUS));
				break;
			}
		}

		dev_info_ratelimited(dev, "PCIe Linking... LTSSM is 0x%x\n",
				     rockchip_pcie_readl_apb(rockchip, PCIE_CLIENT_LTSSM_STATUS));
		msleep(20);
	}

	if (i >= retries) {
		ret = -ENODEV;
		return ret;
	}

already_linkup:
	/* Enable client reset or link down interrupt */
	rockchip_pcie_writel_apb(rockchip, 0x40000U, PCIE_CLIENT_INTR_MASK);
	rockchip->hot_rst_wq = create_singlethread_workqueue("rkep_hot_rst_wq");
	if (!rockchip->hot_rst_wq) {
		dev_err(dev, "Failed to create hot_rst workqueue\n");
		return -ENOMEM;
	}
	INIT_WORK(&rockchip->hot_rst_work, rockchip_pcie_hot_rst_work);
	init_waitqueue_head(&rockchip->wq_head);

	/* Enable client elbi interrupt */
	rockchip_pcie_writel_apb(rockchip, 0x80000000U, PCIE_CLIENT_INTR_MASK);
	for (i = 0; i < PCIE_ELBI_REG_NUM; i++) {
		reg = PCIE_ELBI_LOCAL_BASE + PCIE_ELBI_LOCAL_ENABLE_OFF + ((u32)i * 4U);
		dw_pcie_writel_dbi(&rockchip->pci, reg, 0xffff0000U);
	}

	/* Enable client dma_write, dma_read and elbi interrupt */
	rockchip_pcie_writel_apb(rockchip, 0x0c000000U, PCIE_CLIENT_INTR_MASK);
	dw_pcie_writel_dbi(&rockchip->pci, PCIE_DMA_OFFSET + PCIE_DMA_WR_INT_MASK, 0U);
	dw_pcie_writel_dbi(&rockchip->pci, PCIE_DMA_OFFSET + PCIE_DMA_RD_INT_MASK, 0U);

	ret = devm_request_irq(dev, rockchip->irq, rockchip_pcie_sys_irq_handler,
			       IRQF_SHARED, "pcie-sys", rockchip);
	if (ret != 0) {
		dev_err(dev, "failed to request PCIe subsystem IRQ\n");
		return ret;
	}

	/* Setting device */
	if (dw_pcie_readl_dbi(&rockchip->pci, PCIE_ATU_VIEWPORT) == 0xffffffffU) {
		rockchip->pci.iatu_unroll_enabled = 1;
	}
	for (i = 0; i < (int)PCIE_BAR_MAX_NUM; i++) {
		if (rockchip->ib_target_size[i] > 0U) {
			rockchip_pcie_ep_set_bar(rockchip, i,
						 rockchip->ib_target_address[i]);
		}
	}
	rockchip_pcie_devmode_update(rockchip, RKEP_MODE_KERNEL, RKEP_SMODE_LNKUP);

	return 0;
}

static const struct dw_pcie_ops dw_pcie_ops = {
	.link_up = rockchip_pcie_link_up,
};

static void rockchip_pcie_start_dma_rd(struct dma_trx_obj *obj,
				       struct dma_table *cur, int ctr_off)
{
	struct rockchip_pcie *rockchip = dev_get_drvdata(obj->dev);
	struct dw_pcie *pci = &rockchip->pci;

	dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_RD_ENB,
			   cur->enb.asdword);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_RD_CTRL_LO,
			   cur->ctx_reg.ctrllo.asdword);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_RD_CTRL_HI,
			   cur->ctx_reg.ctrlhi.asdword);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_RD_XFERSIZE,
			   cur->ctx_reg.xfersize);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_RD_SAR_PTR_LO,
			   cur->ctx_reg.sarptrlo);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_RD_SAR_PTR_HI,
			   cur->ctx_reg.sarptrhi);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_RD_DAR_PTR_LO,
			   cur->ctx_reg.darptrlo);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_RD_DAR_PTR_HI,
			   cur->ctx_reg.darptrhi);
	dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_RD_DOORBELL,
			   cur->start.asdword);
}

static void rockchip_pcie_start_dma_wr(struct dma_trx_obj *obj,
				       struct dma_table *cur, int ctr_off)
{
	struct rockchip_pcie *rockchip = dev_get_drvdata(obj->dev);
	struct dw_pcie *pci = &rockchip->pci;

	dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_WR_ENB,
			   cur->enb.asdword);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_WR_CTRL_LO,
			   cur->ctx_reg.ctrllo.asdword);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_WR_CTRL_HI,
			   cur->ctx_reg.ctrlhi.asdword);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_WR_XFERSIZE,
			   cur->ctx_reg.xfersize);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_WR_SAR_PTR_LO,
			   cur->ctx_reg.sarptrlo);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_WR_SAR_PTR_HI,
			   cur->ctx_reg.sarptrhi);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_WR_DAR_PTR_LO,
			   cur->ctx_reg.darptrlo);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_WR_DAR_PTR_HI,
			   cur->ctx_reg.darptrhi);
	dw_pcie_writel_dbi(pci, (u32)ctr_off + PCIE_DMA_WR_WEILO,
			   cur->weilo.asdword);
	dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_WR_DOORBELL,
			   cur->start.asdword);
}

static void rockchip_pcie_start_dma_dwc(struct dma_trx_obj *obj,
					struct dma_table *table)
{
	u32 dir = table->dir;
	int chn = table->chn;
	int ctr_off = (int)PCIE_DMA_OFFSET + chn * 0x200;

	if (dir == (u32)DMA_FROM_BUS) {
		rockchip_pcie_start_dma_rd(obj, table, ctr_off);
	} else {
		rockchip_pcie_start_dma_wr(obj, table, ctr_off);
	}
}

static void rockchip_pcie_config_dma_dwc(struct dma_table *table)
{
	table->enb.enb			= 0x1U;
	table->ctx_reg.ctrllo.lie	= 0x1U;
	table->ctx_reg.ctrllo.rie	= 0x0U;
	table->ctx_reg.ctrllo.td	= 0x1U;
	table->ctx_reg.ctrlhi.asdword	= 0x0U;
	table->ctx_reg.xfersize		= (u32)table->buf_size;
	if (table->dir == (u32)DMA_FROM_BUS) {
		table->ctx_reg.sarptrlo = (u32)(table->bus & 0xffffffffULL);
		table->ctx_reg.sarptrhi = (u32)(table->bus >> 32);
		table->ctx_reg.darptrlo = (u32)(table->local & 0xffffffffULL);
		table->ctx_reg.darptrhi = (u32)(table->local >> 32);
	} else {
		table->ctx_reg.sarptrlo = (u32)(table->local & 0xffffffffULL);
		table->ctx_reg.sarptrhi = (u32)(table->local >> 32);
		table->ctx_reg.darptrlo = (u32)(table->bus & 0xffffffffULL);
		table->ctx_reg.darptrhi = (u32)(table->bus >> 32);
	}
	table->weilo.weight0	= 0x0U;
	table->start.stop	= 0x0U;
	table->start.chnl	= (u8)table->chn;
}

static int rockchip_pcie_get_dma_status(struct dma_trx_obj *obj,
					u8 chn, enum dma_dir dir)
{
	struct rockchip_pcie *rockchip = dev_get_drvdata(obj->dev);
	struct dw_pcie *pci = &rockchip->pci;
	union int_status status;
	union int_clear clears;
	int ret = 0;

	dev_dbg(pci->dev, "%s %x %x\n", __func__,
		dw_pcie_readl_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_WR_INT_STATUS),
		dw_pcie_readl_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_RD_INT_STATUS));

	if ((u32)dir == (u32)DMA_TO_BUS) {
		status.asdword = dw_pcie_readl_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_WR_INT_STATUS);
		if ((status.donesta & (1U << chn)) != 0U) {
			clears.doneclr = (1U << chn);
			dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET +
					   PCIE_DMA_WR_INT_CLEAR, clears.asdword);
			ret = 1;
		}

		if ((status.abortsta & (1U << chn)) != 0U) {
			dev_err(pci->dev, "%s, write abort\n", __func__);
			clears.abortclr = (1U << chn);
			dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET +
					   PCIE_DMA_WR_INT_CLEAR, clears.asdword);
			ret = -1;
		}
	} else {
		status.asdword = dw_pcie_readl_dbi(pci, PCIE_DMA_OFFSET + PCIE_DMA_RD_INT_STATUS);

		if ((status.donesta & (1U << chn)) != 0U) {
			clears.doneclr = (1U << chn);
			dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET +
					   PCIE_DMA_RD_INT_CLEAR, clears.asdword);
			ret = 1;
		}

		if ((status.abortsta & (1U << chn)) != 0U) {
			dev_err(pci->dev, "%s, read abort %x\n", __func__, status.asdword);
			clears.abortclr = (1U << chn);
			dw_pcie_writel_dbi(pci, PCIE_DMA_OFFSET +
					   PCIE_DMA_RD_INT_CLEAR, clears.asdword);
			ret = -1;
		}
	}

	return ret;
}

static int rockchip_pcie_init_dma_trx(struct rockchip_pcie *rockchip)
{
	struct dw_pcie *pci = &rockchip->pci;

	rockchip->dma_obj = pcie_dw_dmatest_register(pci->dev, (bool)true);
	if (IS_ERR(rockchip->dma_obj)) {
		dev_err(rockchip->pci.dev, "failed to prepare dmatest\n");
		return -EINVAL;
	}
	if (rockchip->dma_obj != NULL) {
		rockchip->dma_obj->start_dma_func = rockchip_pcie_start_dma_dwc;
		rockchip->dma_obj->config_dma_func = rockchip_pcie_config_dma_dwc;
		rockchip->dma_obj->get_dma_status = rockchip_pcie_get_dma_status;
	}

	return 0;
}

static int pcie_ep_open(struct inode *inode, struct file *file)
{
	struct miscdevice *miscdev = file->private_data;
	struct rockchip_pcie_misc_dev *pcie_misc_dev;

	pcie_misc_dev = container_of(miscdev, struct rockchip_pcie_misc_dev, dev);
	file->private_data = pcie_misc_dev->pcie;

	return 0;
}

static long pcie_ep_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
	struct rockchip_pcie *rockchip = (struct rockchip_pcie *)file->private_data;
	struct pcie_ep_dma_cache_cfg cfg;
	void __user *uarg = (void __user *)arg;
	struct pcie_ep_obj_poll_virtual_id_cfg poll_cfg;
	enum pcie_ep_mmap_resource mmap_res;
	int ret, index;

	switch (cmd) {
	case PCIE_DMA_CACHE_INVALIDE:
		ret = (int)copy_from_user(&cfg, uarg, sizeof(cfg));
		if (ret != 0) {
			dev_err(rockchip->pci.dev, "failed to get copy from\n");
			return -EFAULT;
		}
		dma_sync_single_for_cpu(rockchip->pci.dev, cfg.addr, cfg.size, DMA_FROM_DEVICE);
		break;

	case PCIE_DMA_CACHE_FLUSH:
		ret = (int)copy_from_user(&cfg, uarg, sizeof(cfg));
		if (ret != 0) {
			dev_err(rockchip->pci.dev, "failed to get copy from\n");
			return -EFAULT;
		}
		dma_sync_single_for_device(rockchip->pci.dev, cfg.addr, cfg.size, DMA_TO_DEVICE);
		break;

	case PCIE_DMA_IRQ_MASK_ALL:
		dw_pcie_writel_dbi(&rockchip->pci, PCIE_DMA_OFFSET + PCIE_DMA_WR_INT_MASK,
				   0xffffffffU);
		dw_pcie_writel_dbi(&rockchip->pci, PCIE_DMA_OFFSET + PCIE_DMA_RD_INT_MASK,
				   0xffffffffU);
		break;

	case PCIE_EP_RAISE_MSI:
		rockchip_pcie_raise_msi_irq(rockchip, PCIe_CLIENT_MSI_OBJ_IRQ);
		break;

	case PCIE_EP_SET_MMAP_RESOURCE:
		ret = (int)copy_from_user(&mmap_res, uarg, sizeof(mmap_res));
		if (ret != 0) {
			dev_err(rockchip->pci.dev, "failed to get copy from\n");
			return -EFAULT;
		}

		if (mmap_res >= PCIE_EP_MMAP_RESOURCE_MAX) {
			dev_err(rockchip->pci.dev, "mmap index %d is out of number\n", mmap_res);
			return -EINVAL;
		}

		rockchip->cur_mmap_res = mmap_res;
		break;

	case PCIE_EP_RAISE_IRQ_USER:
		ret = copy_from_user(&index, uarg, sizeof(index));
		if (ret != 0) {
			dev_err(rockchip->pci.dev,
				"failed to get raise irq data copy from userspace\n");
			return -EFAULT;
		}

		ret = rockchip_pcie_raise_irq_user(rockchip, (u32)index);
		if (ret < 0) {
			return -EFAULT;
		}
		break;

	case PCIE_EP_POLL_IRQ_USER:
		ret = (int)copy_from_user(&poll_cfg, uarg, sizeof(poll_cfg));
		if (ret != 0) {
			dev_err(rockchip->pci.dev,
				"failed to get poll irq data copy from userspace\n");
			return -EFAULT;
		}

		ret = rockchip_pcie_poll_irq_user(rockchip, &poll_cfg);
		if (ret < 0) {
			return -EFAULT;
		}

		if (copy_to_user(uarg, &poll_cfg, sizeof(poll_cfg)) != 0UL) {
			return -EFAULT;
		}
		break;

	default:
		dev_err(rockchip->pci.dev, "unkown ioctl\n");
		break;
	}
	return 0;
}

static int pcie_ep_mmap(struct file *file, struct vm_area_struct *vma)
{
	struct rockchip_pcie *rockchip = (struct rockchip_pcie *)file->private_data;
	size_t size = vma->vm_end - vma->vm_start;
	int err = 0;
	unsigned long addr;

	switch (rockchip->cur_mmap_res) {
	case PCIE_EP_MMAP_RESOURCE_DBI:
		if (size > PCIE_DBI_SIZE) {
			dev_warn(rockchip->pci.dev, "dbi mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = (unsigned long)rockchip->dbi_base_physical;
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR0:
		if (size > rockchip->ib_target_size[0]) {
			dev_warn(rockchip->pci.dev, "bar0 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = (unsigned long)rockchip->ib_target_address[0];
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR1:
		if (size > rockchip->ib_target_size[1]) {
			dev_warn(rockchip->pci.dev, "bar1 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = (unsigned long)rockchip->ib_target_address[1];
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR2:
		if (size > rockchip->ib_target_size[2]) {
			dev_warn(rockchip->pci.dev, "bar2 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = (unsigned long)rockchip->ib_target_address[2];
		break;

	case PCIE_EP_MMAP_RESOURCE_BAR5:
		if (size > rockchip->ib_target_size[5]) {
			dev_warn(rockchip->pci.dev, "bar5 mmap size is out of limitation\n");
			return -EINVAL;
		}
		addr = (unsigned long)rockchip->ib_target_address[5];
		break;

	default:
		dev_err(rockchip->pci.dev, "cur mmap_res %d is unsurreport\n",
			rockchip->cur_mmap_res);
		err = -EINVAL;
		break;
	}
	if (err < 0) {
		return err;
	}

	if (rockchip->cur_mmap_res == PCIE_EP_MMAP_RESOURCE_BAR2) {
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

static const struct file_operations pcie_ep_ops = {
	.owner		= THIS_MODULE,
	.open		= pcie_ep_open,
	.unlocked_ioctl	= pcie_ep_ioctl,
	.mmap		= pcie_ep_mmap,
};

static int rockchip_pcie_add_misc(struct rockchip_pcie *rockchip)
{
	int ret;
	struct rockchip_pcie_misc_dev *pcie_dev;

	pcie_dev = devm_kzalloc(rockchip->pci.dev, sizeof(struct rockchip_pcie_misc_dev),
				GFP_KERNEL);
	if (!pcie_dev) {
		return -ENOMEM;
	}

	pcie_dev->dev.minor	= MISC_DYNAMIC_MINOR;
	pcie_dev->dev.name	= "pcie_ep";
	pcie_dev->dev.fops	= &pcie_ep_ops;
	pcie_dev->dev.parent	= rockchip->pci.dev;

	ret = misc_register(&pcie_dev->dev);
	if (ret != 0) {
		dev_err(rockchip->pci.dev, "pcie: failed to register misc device.\n");
		return ret;
	}

	pcie_dev->pcie = rockchip;

	dev_info(rockchip->pci.dev, "register misc device pcie_ep\n");

	return 0;
}

static int rockchip_pcie_ep_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct rockchip_pcie *rockchip;
	int ret;

	rockchip = devm_kzalloc(dev, sizeof(*rockchip), GFP_KERNEL);
	if (!rockchip) {
		return -ENOMEM;
	}

	rockchip->pci.dev = dev;
	rockchip->pci.ops = &dw_pcie_ops;
	mutex_init(&rockchip->file_mutex);
	platform_set_drvdata(pdev, rockchip);

	ret = rockchip_pcie_get_resource(pdev, rockchip);
	if (ret != 0) {
		dev_err(dev, "Failed to get resource!\n");
		return ret;
	}

	ret = rockchip_pcie_init_host(rockchip);
	if (ret != 0) {
		dev_err(dev, "Failed to init host!\n");
		return ret;
	}

	ret = rockchip_pcie_config_host(rockchip);
	if (ret != 0) {
		dev_err(dev, "Failed to config host!\n");
		goto deinit_host;
	}

	ret = rockchip_pcie_init_dma_trx(rockchip);
	if (ret != 0) {
		dev_err(dev, "Failed to initial dma trx!\n");
		goto deinit_host;
	}

	ret = rockchip_pcie_add_misc(rockchip);
	if (ret < 0) {
		dev_err(dev, "Failed to add misc!\n");
	}

	return 0;

deinit_host:
	ret = rockchip_pcie_deinit_host(rockchip);
	if (ret < 0) {
		dev_err(dev, "Failed to deinit host!\n");
	}
	return ret;
}

static struct platform_driver rk_plat_pcie_driver = {
	.driver = {
		.name			= "rk-pcie-ep",
		.of_match_table		= rockchip_pcie_ep_of_match,
		.suppress_bind_attrs	= (bool)true,
	},
	.probe	= rockchip_pcie_ep_probe,
};

module_platform_driver(rk_plat_pcie_driver);

MODULE_AUTHOR("Simon Xue <xxm@rock-chips.com>");
MODULE_DESCRIPTION("RockChip PCIe Controller EP driver");
MODULE_LICENSE("GPL");
