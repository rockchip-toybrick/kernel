// SPDX-License-Identifier:     GPL-2.0+
/*
 * Copyright (C) 2020 Rockchip Electronics Co., Ltd
 */
#include <linux/clk.h>
#include <linux/delay.h>
#include <linux/initramfs.h>
#include <linux/interrupt.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/platform_device.h>
#include <linux/reset.h>
#include <linux/soc/rockchip/rockchip_decompress.h>

#define DECOM_CTRL		0x0U
#define DECOM_ENR		0x4U
#define DECOM_RADDR		0x8U
#define DECOM_WADDR		0xcU
#define DECOM_UDDSL		0x10U
#define DECOM_UDDSH		0x14U
#define DECOM_TXTHR		0x18U
#define DECOM_RXTHR		0x1cU
#define DECOM_SLEN		0x20U
#define DECOM_STAT		0x24U
#define DECOM_ISR		0x28U
#define DECOM_IEN		0x2cU
#define DECOM_AXI_STAT		0x30U
#define DECOM_TSIZEL		0x34U
#define DECOM_TSIZEH		0x38U
#define DECOM_MGNUM		0x3cU
#define DECOM_FRAME		0x40U
#define DECOM_DICTID		0x44U
#define DECOM_CSL		0x48U
#define DECOM_CSH		0x4cU
#define DECOM_LMTSL		0x50U
#define DECOM_LMTSH		0x54U

#define LZ4_HEAD_CSUM_CHECK_EN	(1U << 1)
#define LZ4_BLOCK_CSUM_CHECK_EN	(1U << 2)
#define LZ4_CONT_CSUM_CHECK_EN	(1U << 3)

#define DSOLIEN			(1U << 19)
#define ZDICTEIEN		(1U << 18)
#define GCMEIEN			(1U << 17)
#define GIDEIEN			(1U << 16)
#define CCCEIEN			(1U << 15)
#define BCCEIEN			(1U << 14)
#define HCCEIEN			(1U << 13)
#define CSEIEN			(1U << 12)
#define DICTEIEN		(1U << 11)
#define VNEIEN			(1U << 10)
#define WNEIEN			(1U << 9)
#define RDCEIEN			(1U << 8)
#define WRCEIEN			(1U << 7)
#define DISEIEN			(1U << 6)
#define LENEIEN			(1U << 5)
#define LITEIEN			(1U << 4)
#define SQMEIEN			(1U << 3)
#define SLCIEN			(1U << 2)
#define HDEIEN			(1U << 1)
#define DSIEN			(1U << 0)

#define DECOM_STOP		(1U << 0)
#define DECOM_COMPLETE		(1U << 0)
#define DECOM_GZIP_MODE		(1U << 4)
#define DECOM_ZLIB_MODE		(1U << 5)
#define DECOM_DEFLATE_MODE	(1U << 0)

#define DECOM_ENABLE		0x1U
#define DECOM_DISABLE		0x0U

#define DECOM_INT_MASK \
	(DSOLIEN | ZDICTEIEN | GCMEIEN | GIDEIEN | \
	CCCEIEN | BCCEIEN | HCCEIEN | CSEIEN | \
	DICTEIEN | VNEIEN | WNEIEN | RDCEIEN | WRCEIEN | \
	DISEIEN | LENEIEN | LITEIEN | SQMEIEN | SLCIEN | \
	HDEIEN | DSIEN)

struct rk_decom {
	struct device *dev;
	int irq;
	int num_clocks;
	struct clk_bulk_data *clocks;
	void __iomem *regs;
	phys_addr_t mem_start;
	size_t mem_size;
	struct reset_control *reset;
};

static struct rk_decom *g_decom;

static DECLARE_WAIT_QUEUE_HEAD(g_decom_wait);
static bool g_decom_complete;
static bool g_decom_noblocking;
static u64 g_decom_data_len;

int rk_decom_wait_done(u32 timeout, u64 *decom_len)
{
	long ret;

	if (!decom_len) {
		return -EINVAL;
	}

	ret = wait_event_timeout(g_decom_wait, g_decom_complete, (long)(timeout * HZ));
	if (ret == 0) {
		if (g_decom) {
			clk_bulk_disable_unprepare(g_decom->num_clocks, g_decom->clocks);
		}

		return -ETIMEDOUT;
	}

	*decom_len = g_decom_data_len;

	return 0;
}
EXPORT_SYMBOL(rk_decom_wait_done);

static DECLARE_WAIT_QUEUE_HEAD(decom_init_done);

int rk_decom_start(u32 mode, phys_addr_t src, phys_addr_t dst, u32 dst_max_size)
{
	int ret;
	u32 irq_status;
	u32 decom_enr;
	u32 decom_mode = rk_get_decom_mode(mode);

	(void)wait_event_timeout(decom_init_done, g_decom, HZ);
	if (!g_decom) {
		return -EINVAL;
	}

	if (g_decom->mem_start != (phys_addr_t)0) {
		(void)pr_info("%s: mode %u src %pa dst %pa max_size %u\n",
			__func__, mode, &src, &dst, dst_max_size);
	}

	ret = clk_bulk_prepare_enable(g_decom->num_clocks, g_decom->clocks);
	if (ret != 0) {
		return ret;
	}

	g_decom_complete = (bool)false;
	g_decom_data_len   = 0;
	g_decom_noblocking = rk_get_noblocking_flag(mode);

	decom_enr = readl(g_decom->regs + DECOM_ENR);
	if ((decom_enr & 0x1U) != 0U){
		(void)pr_err("decompress busy\n");
		ret = -EBUSY;
		goto error;
	}

	if (g_decom->reset) {
		(void)reset_control_assert(g_decom->reset);
		udelay(10);
		(void)reset_control_deassert(g_decom->reset);
	}

	irq_status = readl(g_decom->regs + DECOM_ISR);
	/* clear interrupts */
	if (irq_status != 0U) {
		writel(irq_status, g_decom->regs + DECOM_ISR);
	}

	switch (decom_mode) {
	case (u32)LZ4_MOD:
		writel(LZ4_CONT_CSUM_CHECK_EN |
		       LZ4_HEAD_CSUM_CHECK_EN |
		       LZ4_BLOCK_CSUM_CHECK_EN |
		       (u32)LZ4_MOD, g_decom->regs + DECOM_CTRL);
		break;
	case (u32)GZIP_MOD:
		writel(DECOM_DEFLATE_MODE | DECOM_GZIP_MODE,
		       g_decom->regs + DECOM_CTRL);
		break;
	case (u32)ZLIB_MOD:
		writel(DECOM_DEFLATE_MODE | DECOM_ZLIB_MODE,
		       g_decom->regs + DECOM_CTRL);
		break;
	default:
		(void)pr_err("undefined mode : %d\n", decom_mode);
		ret = -EINVAL;
		break;
	}

	if (ret < 0) {
		goto error;
	}

	writel(src, g_decom->regs + DECOM_RADDR);
	writel(dst, g_decom->regs + DECOM_WADDR);

	writel(dst_max_size, g_decom->regs + DECOM_LMTSL);
	writel(0x0, g_decom->regs + DECOM_LMTSH);

	writel(DECOM_INT_MASK, g_decom->regs + DECOM_IEN);
	writel(DECOM_ENABLE, g_decom->regs + DECOM_ENR);

	return 0;
error:
	clk_bulk_disable_unprepare(g_decom->num_clocks, g_decom->clocks);

	return ret;
}
EXPORT_SYMBOL(rk_decom_start);

static irqreturn_t rk_decom_irq_handler(int irq, void *priv)
{
	struct rk_decom *rk_dec = priv;
	u32 irq_status;
	u32 decom_status;

	irq_status = readl(rk_dec->regs + DECOM_ISR);
	/* clear interrupts */
	writel(irq_status, rk_dec->regs + DECOM_ISR);
	if ((irq_status & DECOM_STOP) != 0U) {
		decom_status = readl(rk_dec->regs + DECOM_STAT);
		if ((decom_status & DECOM_COMPLETE) != 0U) {
			g_decom_complete = (bool)true;
			g_decom_data_len = readl(rk_dec->regs + DECOM_TSIZEH);
			g_decom_data_len = (g_decom_data_len << 32) |
					   readl(rk_dec->regs + DECOM_TSIZEL);
			wake_up(&g_decom_wait);
			if ((rk_dec->mem_start) != (phys_addr_t)0) {
				dev_info(rk_dec->dev,
					 "decom completed, decom_data_len = %llu\n",
					 g_decom_data_len);
			}
		} else {
			dev_info(rk_dec->dev,
				 "decom failed, irq_status = 0x%x, decom_status = 0x%x, try again !\n",
				 irq_status, decom_status);

			print_hex_dump(KERN_WARNING, "", DUMP_PREFIX_OFFSET,
				       32, 4, rk_dec->regs, 0x128, (bool)false);

			if (g_decom_noblocking) {
				dev_info(rk_dec->dev, "decom failed and exit in noblocking mode.");
				writel(DECOM_DISABLE, rk_dec->regs + DECOM_ENR);
				writel(0, g_decom->regs + DECOM_IEN);

				g_decom_complete = (bool)true;
				g_decom_data_len = 0;
				g_decom_noblocking = (bool)false;
				wake_up(&g_decom_wait);
			} else {
				writel(DECOM_ENABLE, rk_dec->regs + DECOM_ENR);
			}
		}
	}

	return IRQ_WAKE_THREAD;
}

static irqreturn_t rk_decom_irq_thread(int irq, void *priv)
{
	struct rk_decom *rk_dec = priv;

	if (g_decom_complete) {
		void *start, *end;

		if ((rk_dec->mem_start) != (phys_addr_t)0) {
			/*
			 * Now it is safe to free reserve memory that
			 * store the origin ramdisk file
			 */
			start = phys_to_virt(rk_dec->mem_start);
			end = start + rk_dec->mem_size;
			(void)free_reserved_area(start, end, -1, "ramdisk gzip archive");
			rk_dec->mem_start = 0;
		}

		clk_bulk_disable_unprepare(rk_dec->num_clocks, rk_dec->clocks);
	}

	return IRQ_HANDLED;
}

static int __init rockchip_decom_probe(struct platform_device *pdev)
{
	struct rk_decom *rk_dec;
	struct resource *res;
	struct device *dev = &pdev->dev;
	struct device_node *np = dev->of_node;
	struct device_node *mem;
	struct resource reg;
	int ret;

	rk_dec = devm_kzalloc(dev, sizeof(*rk_dec), GFP_KERNEL);
	if (!rk_dec) {
		return -ENOMEM;
	}

	rk_dec->dev = dev;
	rk_dec->irq = platform_get_irq(pdev, 0);
	if (rk_dec->irq < 0) {
		dev_err(dev, "failed to get rk_dec irq\n");
		return -ENOENT;
	}

	mem = of_parse_phandle(np, "memory-region", 0);
	if (!mem) {
		dev_err(dev, "missing \"memory-region\" property\n");
		return -ENODEV;
	}

	ret = of_address_to_resource(mem, 0, &reg);
	of_node_put(mem);
	if (ret != 0) {
		dev_err(dev, "missing \"reg\" property\n");
		return -ENODEV;
	}

	rk_dec->mem_start = reg.start;
	rk_dec->mem_size = resource_size(&reg);

	rk_dec->num_clocks = devm_clk_bulk_get_all(dev, &rk_dec->clocks);
	if (rk_dec->num_clocks < 0) {
		dev_err(dev, "failed to get decompress clock\n");
		return -ENODEV;
	}

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	rk_dec->regs = devm_ioremap_resource(dev, res);
	if (IS_ERR(rk_dec->regs)) {
		ret = (int)PTR_ERR(rk_dec->regs);
		goto disable_clk;
	}

	dev_set_drvdata(dev, rk_dec);

	rk_dec->reset = devm_reset_control_get_exclusive(dev, "dresetn");
	if (IS_ERR(rk_dec->reset)) {
		ret = (int)PTR_ERR(rk_dec->reset);
		if (ret != -ENOENT) {
			return ret;
		}

		dev_dbg(dev, "no reset control found\n");
		rk_dec->reset = NULL;
	}

	ret = devm_request_threaded_irq(dev, (unsigned int)rk_dec->irq, rk_decom_irq_handler,
					rk_decom_irq_thread, IRQF_ONESHOT,
					dev_name(dev), rk_dec);
	if (ret < 0) {
		dev_err(dev, "failed to attach decompress irq\n");
		goto disable_clk;
	}

	g_decom = rk_dec;
	wake_up(&decom_init_done);

	return 0;

disable_clk:
	clk_bulk_disable_unprepare(rk_dec->num_clocks, rk_dec->clocks);

	return ret;
}

#ifdef CONFIG_OF
static const struct of_device_id rockchip_decom_dt_match[] = {
	{ .compatible = "rockchip,hw-decompress" },
	{},
};
#endif

static struct platform_driver rk_decom_driver = {
	.driver		= {
		.name	= "rockchip_hw_decompress",
		.of_match_table = rockchip_decom_dt_match,
	},
};

static int __init rockchip_hw_decompress_init(void)
{
	struct device_node *node;

	node = of_find_matching_node(NULL, rockchip_decom_dt_match);
	if (node) {
		(void)of_platform_device_create(node, NULL, NULL);
		of_node_put(node);
		return platform_driver_probe(&rk_decom_driver, rockchip_decom_probe);
	}

	return 0;
}

pure_initcall(rockchip_hw_decompress_init);
