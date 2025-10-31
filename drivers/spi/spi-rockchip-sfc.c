// SPDX-License-Identifier: GPL-2.0-only
/*
 * Rockchip Serial Flash Controller Driver
 *
 * Copyright (c) 2017-2021, Rockchip Inc.
 * Author: Shawn Lin <shawn.lin@rock-chips.com>
 *	   Chris Morgan <macroalpha82@gmail.com>
 *	   Jon Lin <Jon.lin@rock-chips.com>
 */

#include <linux/acpi.h>
#include <linux/bitops.h>
#include <linux/clk.h>
#include <linux/completion.h>
#include <linux/dma-mapping.h>
#include <linux/iopoll.h>
#include <linux/interrupt.h>
#include <linux/mfd/syscon.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/pinctrl/consumer.h>
#include <linux/platform_device.h>
#include <linux/pm_runtime.h>
#include <linux/regmap.h>
#include <linux/slab.h>
#include <linux/spi/spi-mem.h>
#include <linux/of_gpio.h>

/* System control */
#define SFC_CTRL			0x0U
#define  SFC_CTRL_PHASE_SEL_NEGETIVE	(1U << 1)
#define  SFC_CTRL_CMD_BITS_SHIFT	8U
#define  SFC_CTRL_ADDR_BITS_SHIFT	10U
#define  SFC_CTRL_DATA_BITS_SHIFT	12U

/* Interrupt mask */
#define SFC_IMR				0x4U
#define  SFC_IMR_RX_FULL		(1U << 0)
#define  SFC_IMR_RX_UFLOW		(1U << 1)
#define  SFC_IMR_TX_OFLOW		(1U << 2)
#define  SFC_IMR_TX_EMPTY		(1U << 3)
#define  SFC_IMR_TRAN_FINISH		(1U << 4)
#define  SFC_IMR_BUS_ERR		(1U << 5)
#define  SFC_IMR_NSPI_ERR		(1U << 6)
#define  SFC_IMR_DMA			(1U << 7)

/* Interrupt clear */
#define SFC_ICLR			0x8U
#define  SFC_ICLR_RX_FULL		(1U << 0)
#define  SFC_ICLR_RX_UFLOW		(1U << 1)
#define  SFC_ICLR_TX_OFLOW		(1U << 2)
#define  SFC_ICLR_TX_EMPTY		(1U << 3)
#define  SFC_ICLR_TRAN_FINISH		(1U << 4)
#define  SFC_ICLR_BUS_ERR		(1U << 5)
#define  SFC_ICLR_NSPI_ERR		(1U << 6)
#define  SFC_ICLR_DMA			(1U << 7)

/* FIFO threshold level */
#define SFC_FTLR			0xcU
#define  SFC_FTLR_TX_SHIFT		0U
#define  SFC_FTLR_TX_MASK		0x1fU
#define  SFC_FTLR_RX_SHIFT		8U
#define  SFC_FTLR_RX_MASK		0x1fU

/* Reset FSM and FIFO */
#define SFC_RCVR			0x10U
#define  SFC_RCVR_RESET			(1U << 0)

/* Enhanced mode */
#define SFC_AX				0x14U

/* Address Bit number */
#define SFC_ABIT			0x18U

/* Interrupt status */
#define SFC_ISR				0x1cU
#define  SFC_ISR_RX_FULL_SHIFT		(1U << 0)
#define  SFC_ISR_RX_UFLOW_SHIFT		(1U << 1)
#define  SFC_ISR_TX_OFLOW_SHIFT		(1U << 2)
#define  SFC_ISR_TX_EMPTY_SHIFT		(1U << 3)
#define  SFC_ISR_TX_FINISH_SHIFT	(1U << 4)
#define  SFC_ISR_BUS_ERR_SHIFT		(1U << 5)
#define  SFC_ISR_NSPI_ERR_SHIFT		(1U << 6)
#define  SFC_ISR_DMA_SHIFT		(1U << 7)

/* FIFO status */
#define SFC_FSR				0x20U
#define  SFC_FSR_TX_IS_FULL		(1U << 0)
#define  SFC_FSR_TX_IS_EMPTY		(1U << 1)
#define  SFC_FSR_RX_IS_EMPTY		(1U << 2)
#define  SFC_FSR_RX_IS_FULL		(1U << 3)
#define  SFC_FSR_TXLV_MASK		((u32)0x3FU << 8)
#define  SFC_FSR_TXLV_SHIFT		8U
#define  SFC_FSR_RXLV_MASK		((u32)0x1FU << 16)
#define  SFC_FSR_RXLV_SHIFT		16U

/* FSM status */
#define SFC_SR				0x24U
#define  SFC_SR_IS_IDLE			0x0U
#define  SFC_SR_IS_BUSY			0x1U

/* Raw interrupt status */
#define SFC_RISR			0x28U
#define  SFC_RISR_RX_FULL		(1U << 0)
#define  SFC_RISR_RX_UNDERFLOW		(1U << 1)
#define  SFC_RISR_TX_OVERFLOW		(1U << 2)
#define  SFC_RISR_TX_EMPTY		(1U << 3)
#define  SFC_RISR_TRAN_FINISH		(1U << 4)
#define  SFC_RISR_BUS_ERR		(1U << 5)
#define  SFC_RISR_NSPI_ERR		(1U << 6)
#define  SFC_RISR_DMA			(1U << 7)

/* Version */
#define SFC_VER				0x2CU
#define  SFC_VER_3			0x3U
#define  SFC_VER_4			0x4U
#define  SFC_VER_5			0x5U
#define  SFC_VER_6			0x6U
#define  SFC_VER_8			0x8U

/* Ext ctrl */
#define SFC_EXT_CTRL			0x34U
#define  SFC_SCLK_X2_BYPASS		((u32)(1U << 24))

/* Delay line controller resiter */
#define SFC_DLL_CTRL0			0x3CU
#define SFC_DLL_CTRL0_SCLK_SMP_DLL	(1U << 15)
#define SFC_DLL_CTRL0_DLL_MAX_VER4	0xFFU
#define SFC_DLL_CTRL0_DLL_MAX_VER5	0x1FFU

/* Master trigger */
#define SFC_DMA_TRIGGER			0x80U
#define SFC_DMA_TRIGGER_START		1U

/* Src or Dst addr for master */
#define SFC_DMA_ADDR			0x84U

/* Length control register extension 32GB */
#define SFC_LEN_CTRL			0x88U
#define SFC_LEN_CTRL_TRB_SEL		1U
#define SFC_LEN_EXT			0x8CU

/* Command */
#define SFC_CMD				0x100U
#define  SFC_CMD_IDX_SHIFT		0U
#define  SFC_CMD_DUMMY_SHIFT		8U
#define  SFC_CMD_DIR_SHIFT		12U
#define  SFC_CMD_DIR_RD			0U
#define  SFC_CMD_DIR_WR			1U
#define  SFC_CMD_ADDR_SHIFT		14U
#define  SFC_CMD_ADDR_0BITS		0U
#define  SFC_CMD_ADDR_24BITS		1U
#define  SFC_CMD_ADDR_32BITS		2U
#define  SFC_CMD_ADDR_XBITS		3U
#define  SFC_CMD_TRAN_BYTES_SHIFT	16U
#define  SFC_CMD_CS_SHIFT		30U

/* Address */
#define SFC_ADDR			0x104U

/* Data */
#define SFC_DATA			0x108U

#define SFC_CS1_REG_OFFSET		0x200U

#define SFC_MAX_CHIPSELECT_NUM		2U

#define SFC_MAX_IOSIZE_VER3		(512 * 31)
#define SFC_MAX_IOSIZE_VER4		(0x10000U) /* Although up to 4GB, 64KB is enough with less mem reserved */

/* DMA is only enabled for large data transmission */
#define SFC_DMA_TRANS_THRETHOLD		(0x40U)

/* Maximum clock values from datasheet suggest keeping clock value under
 * 150MHz. No minimum or average value is suggested.
 */
#define SFC_MAX_SPEED		(150000000U)
#define SFC_DLL_THRESHOLD_RATE	(50000000U)

#define SFC_DLL_TRANING_STEP		10U	/* Training step */
#define SFC_DLL_TRANING_VALID_WINDOW	80U	/* Valid DLL winbow */

#define ROCKCHIP_AUTOSUSPEND_DELAY	((int)2000)

struct rockchip_sfc_powergood {
	bool	valid;
	u32	grf_offset;
	u8	bits_mask;
};

struct rockchip_sfc_data {
	struct rockchip_sfc_powergood powergood;
};

struct rockchip_sfc {
	struct device *dev;
	void __iomem *regbase;
	struct clk *hclk;
	struct clk *clk;
	u32 speed[SFC_MAX_CHIPSELECT_NUM];
	u32 cur_speed;
	u32 cur_real_speed;
	/* virtual mapped addr for dma_buffer */
	void *buffer;
	dma_addr_t dma_buffer;
	struct completion cp;
	bool use_dma;
	bool sclk_x2_bypass;
	u32 max_iosize;
	u32 max_dll_cells;
	u16 dll_cells[SFC_MAX_CHIPSELECT_NUM];
	u32 version;
	struct gpio_desc **cs_gpiods;
	struct spi_master *master;
	struct regmap *grf;
	const struct rockchip_sfc_data *data;
};

static int rockchip_sfc_reset(struct rockchip_sfc *sfc)
{
	int err;
	u32 status;

	writel_relaxed(SFC_RCVR_RESET, sfc->regbase + SFC_RCVR);

	err = readl_poll_timeout(sfc->regbase + SFC_RCVR, status,
				 !(status & SFC_RCVR_RESET), 20,
				 jiffies_to_usecs(HZ));
	if (err < 0) {
		dev_err(sfc->dev, "SFC reset never finished\n");
	}

	/* Still need to clear the masked interrupt from RISR */
	writel_relaxed(0xFFFFFFFFU, sfc->regbase + SFC_ICLR);

	dev_dbg(sfc->dev, "reset\n");

	return err;
}

static u16 rockchip_sfc_get_version(struct rockchip_sfc *sfc)
{
	return  (u16)(readl(sfc->regbase + SFC_VER) & 0xffffU);
}

static u32 rockchip_sfc_get_max_iosize(struct rockchip_sfc *sfc)
{
	if (sfc->version >= SFC_VER_4) {
		return SFC_MAX_IOSIZE_VER4;
	}

	return SFC_MAX_IOSIZE_VER3;
}

static u32 rockchip_sfc_get_max_dll_cells(struct rockchip_sfc *sfc)
{
	if (sfc->max_dll_cells != 0U) {
		return sfc->max_dll_cells;
	}

	if (sfc->version >= SFC_VER_5) {
		return SFC_DLL_CTRL0_DLL_MAX_VER5;
	} else if (sfc->version == SFC_VER_4) {
		return SFC_DLL_CTRL0_DLL_MAX_VER4;
	} else {
		return 0;
	}
}

static void rockchip_sfc_set_delay_lines(struct rockchip_sfc *sfc, u16 cells, u8 cs)
{
	u16 cell_max = (u16)rockchip_sfc_get_max_dll_cells(sfc);
	u32 val = 0;

	if (cells > cell_max) {
		cells = cell_max;
	}

	if (cells != (u16)0) {
		val = (u32)SFC_DLL_CTRL0_SCLK_SMP_DLL | (u32)cells;
	}

	writel(val, sfc->regbase + cs * SFC_CS1_REG_OFFSET + SFC_DLL_CTRL0);
}

static int rockchip_sfc_clk_set_rate(struct rockchip_sfc *sfc, unsigned long speed)
{
	if (sfc->version < SFC_VER_8 || sfc->sclk_x2_bypass) {
		return clk_set_rate(sfc->clk, speed);
	} else {
		return clk_set_rate(sfc->clk, speed * 2UL);
	}
}

static unsigned long rockchip_sfc_clk_get_rate(struct rockchip_sfc *sfc)
{
	if (sfc->version < SFC_VER_8 || sfc->sclk_x2_bypass) {
		return clk_get_rate(sfc->clk);
	} else {
		return clk_get_rate(sfc->clk) / 2UL;
	}
}

static void rockchip_sfc_irq_unmask(struct rockchip_sfc *sfc, u32 mask)
{
	u32 reg;

	/* Enable transfer complete interrupt */
	reg = readl(sfc->regbase + SFC_IMR);
	reg &= ~mask;
	writel(reg, sfc->regbase + SFC_IMR);
}

static void rockchip_sfc_irq_mask(struct rockchip_sfc *sfc, u32 mask)
{
	u32 reg;

	/* Disable transfer finish interrupt */
	reg = readl(sfc->regbase + SFC_IMR);
	reg |= mask;
	writel(reg, sfc->regbase + SFC_IMR);
}

static int rockchip_sfc_init(struct rockchip_sfc *sfc)
{
	u32 reg;

	writel(0U, sfc->regbase + SFC_CTRL);
	writel(0xFFFFFFFFU, sfc->regbase + SFC_ICLR);
	rockchip_sfc_irq_mask(sfc, 0xFFFFFFFFU);
	if (rockchip_sfc_get_version(sfc) >= SFC_VER_4) {
		writel(SFC_LEN_CTRL_TRB_SEL, sfc->regbase + SFC_LEN_CTRL);
	}
	if (rockchip_sfc_get_version(sfc) >= SFC_VER_8 && sfc->sclk_x2_bypass) {
		reg = readl(sfc->regbase + SFC_EXT_CTRL);
		reg |= SFC_SCLK_X2_BYPASS;
		writel(reg, sfc->regbase + SFC_EXT_CTRL);
	}

	return 0;
}

static int rockchip_sfc_wait_txfifo_ready(struct rockchip_sfc *sfc, u32 timeout_us)
{
	int ret;
	u32 status;

	ret = readl_poll_timeout(sfc->regbase + SFC_FSR, status,
				 status & SFC_FSR_TXLV_MASK, 0,
				 timeout_us);
	if (ret < 0) {
		dev_dbg(sfc->dev, "sfc wait tx fifo timeout\n");

		return -ETIMEDOUT;
	}
	status = (status & SFC_FSR_TXLV_MASK) >> SFC_FSR_TXLV_SHIFT;

	return (int)(status);
}

static int rockchip_sfc_wait_rxfifo_ready(struct rockchip_sfc *sfc, u32 timeout_us)
{
	int ret;
	u32 status;

	ret = readl_poll_timeout(sfc->regbase + SFC_FSR, status,
				 status & SFC_FSR_RXLV_MASK, 0,
				 timeout_us);
	if (ret < 0) {
		dev_dbg(sfc->dev, "sfc wait rx fifo timeout\n");

		return -ETIMEDOUT;
	}

	status = (status & SFC_FSR_RXLV_MASK) >> SFC_FSR_RXLV_SHIFT;

	return (int)(status);
}

static void rockchip_sfc_adjust_op_work(struct spi_mem_op *op)
{
	if ((op->dummy.nbytes > 0U) && (op->addr.nbytes == 0U)) {
		/*
		 * SFC not support output DUMMY cycles right after CMD cycles, so
		 * treat it as ADDR cycles.
		 */
		op->addr.nbytes = op->dummy.nbytes;
		op->addr.buswidth = op->dummy.buswidth;
		op->addr.val = 0xFFFFFFFFF;

		op->dummy.nbytes = 0;
	}
}

static int rockchip_sfc_xfer_setup(struct rockchip_sfc *sfc,
				   struct spi_mem *mem,
				   const struct spi_mem_op *op,
				   u32 len)
{
	u32 ctrl = 0, cmd;
	u32 cs = (u32)mem->spi->chip_select;
	u32 voltage;

#ifdef CONFIG_MTD_SPI_NOR_AUTO_MERGE
	cs = mem->spi->cs_gpio;
#endif

	/* set CMD */
	cmd = op->cmd.opcode;
	ctrl |= (((u32)(op->cmd.buswidth) >> 1U) << SFC_CTRL_CMD_BITS_SHIFT);

	/* set ADDR */
	if (op->addr.nbytes > 0U) {
		if (op->addr.nbytes == 4U) {
			cmd |= (u32)SFC_CMD_ADDR_32BITS << SFC_CMD_ADDR_SHIFT;
		} else if (op->addr.nbytes == 3U) {
			cmd |= (u32)SFC_CMD_ADDR_24BITS << SFC_CMD_ADDR_SHIFT;
		} else {
			cmd |= (u32)SFC_CMD_ADDR_XBITS << SFC_CMD_ADDR_SHIFT;
			writel((u32)op->addr.nbytes * 8U - 1U, sfc->regbase + cs * SFC_CS1_REG_OFFSET + SFC_ABIT);
		}

		ctrl |= (((u32)op->addr.buswidth >> 1U) << SFC_CTRL_ADDR_BITS_SHIFT);
	}

	/* set DUMMY */
	if (op->dummy.nbytes > 0U) {
		if (op->dummy.buswidth == 4U) {
			cmd |= (u32)op->dummy.nbytes * 2U << SFC_CMD_DUMMY_SHIFT;
		} else if (op->dummy.buswidth == 2U) {
			cmd |= (u32)op->dummy.nbytes * 4U << SFC_CMD_DUMMY_SHIFT;
		} else {
			cmd |= (u32)op->dummy.nbytes * 8U << SFC_CMD_DUMMY_SHIFT;
		}
	}

	/* set DATA */
	if (sfc->version >= SFC_VER_4) { /* Clear it if no data to transfer */
		writel(len, sfc->regbase + SFC_LEN_EXT);
	} else {
		cmd |= len << SFC_CMD_TRAN_BYTES_SHIFT;
	}
	if (len > 0U) {
		if (op->data.dir == SPI_MEM_DATA_OUT) {
			cmd |= (u32)SFC_CMD_DIR_WR << SFC_CMD_DIR_SHIFT;
		}

		ctrl |= (((u32)op->data.buswidth >> 1) << SFC_CTRL_DATA_BITS_SHIFT);
	}
	if ((len == 0U) && (op->addr.nbytes > 0U)) {
		cmd |= (u32)SFC_CMD_DIR_WR << SFC_CMD_DIR_SHIFT;
	}

	/* set the Controller */
	ctrl |= SFC_CTRL_PHASE_SEL_NEGETIVE;
	cmd |= cs << SFC_CMD_CS_SHIFT;

	dev_dbg(sfc->dev, "sfc addr.nbytes=%x(x%d) dummy.nbytes=%x(x%d)\n",
		op->addr.nbytes, op->addr.buswidth,
		op->dummy.nbytes, op->dummy.buswidth);
	dev_dbg(sfc->dev, "sfc ctrl=%x cmd=%x addr=%llx len=%x cs=%d\n",
		ctrl, cmd, op->addr.val, len, cs);

	if (sfc->data && sfc->data->powergood.valid) {
		if (regmap_read_poll_timeout(sfc->grf, sfc->data->powergood.grf_offset,
					     voltage, voltage & sfc->data->powergood.bits_mask,
					     1000, jiffies_to_usecs(HZ))) {
			dev_err(sfc->dev, "wait for powergood failed\n");
			return -EIO;
		}
	}

	writel(ctrl, sfc->regbase + cs * SFC_CS1_REG_OFFSET + SFC_CTRL);
	writel(cmd, sfc->regbase + SFC_CMD);
	if (op->addr.nbytes > 0U) {
		writel(op->addr.val, sfc->regbase + SFC_ADDR);
	}

	return 0;
}

static int rockchip_sfc_write_fifo(struct rockchip_sfc *sfc, const u8 *buf, int len)
{
	u8 bytes = (u8)len & 0x3U;
	u32 dwords;
	int tx_level;
	u32 write_words;
	u32 tmp = 0;

	dwords = (u32)len >> 2;
	while (dwords > 0U) {
		tx_level = rockchip_sfc_wait_txfifo_ready(sfc, 1000);
		if (tx_level < 0) {
			return tx_level;
		}
		if ((u32)tx_level < dwords) {
			write_words = (u32)tx_level;
		} else {
			write_words = dwords;
		}
		iowrite32_rep(sfc->regbase + SFC_DATA, buf, write_words);
		buf += write_words << 2;
		dwords -= write_words;
	}

	/* write the rest non word aligned bytes */
	if (bytes > 0U) {
		tx_level = rockchip_sfc_wait_txfifo_ready(sfc, 1000);
		if (tx_level < 0) {
			return tx_level;
		}
		memcpy(&tmp, buf, bytes);
		writel(tmp, sfc->regbase + SFC_DATA);
	}

	return len;
}

static int rockchip_sfc_read_fifo(struct rockchip_sfc *sfc, u8 *buf, int len)
{
	u8 bytes = (u8)len & 0x3U;
	u32 dwords;
	u8 read_words;
	int rx_level;
	u32 tmp;

	/* word aligned access only */
	dwords = (u32)len >> 2;
	while (dwords > 0U) {
		rx_level = rockchip_sfc_wait_rxfifo_ready(sfc, 1000);
		if (rx_level < 0) {
			return rx_level;
		}
		if ((u32)rx_level < dwords) {
			read_words = (u32)rx_level;
		} else {
			read_words = dwords;
		}
		ioread32_rep(sfc->regbase + SFC_DATA, buf, read_words);
		buf += read_words << 2;
		dwords -= read_words;
	}

	/* read the rest non word aligned bytes */
	if (bytes > 0U) {
		rx_level = rockchip_sfc_wait_rxfifo_ready(sfc, 1000);
		if (rx_level < 0) {
			return rx_level;
		}
		tmp = readl(sfc->regbase + SFC_DATA);
		memcpy(buf, &tmp, bytes);
	}

	return len;
}

static int rockchip_sfc_fifo_transfer_dma(struct rockchip_sfc *sfc, dma_addr_t dma_buf, size_t len)
{
	writel(0xFFFFFFFFU, sfc->regbase + SFC_ICLR);
	writel((u32)dma_buf, sfc->regbase + SFC_DMA_ADDR);
	writel(SFC_DMA_TRIGGER_START, sfc->regbase + SFC_DMA_TRIGGER);

	return (int)len;
}

static int rockchip_sfc_xfer_data_poll(struct rockchip_sfc *sfc,
				       const struct spi_mem_op *op, size_t len)
{
	dev_dbg(sfc->dev, "sfc xfer_poll len=%x\n", len);

	if (op->data.dir == SPI_MEM_DATA_OUT) {
		return rockchip_sfc_write_fifo(sfc, op->data.buf.out, (int)len);
	} else {
		return rockchip_sfc_read_fifo(sfc, op->data.buf.in, (int)len);
	}
}

static int rockchip_sfc_xfer_data_dma(struct rockchip_sfc *sfc,
				      const struct spi_mem_op *op, size_t len)
{
	int ret;
#ifdef ROCKCHIP_SFC_VERBOSE
	ktime_t start_time;
	ktime_t end_time;
	unsigned long us = 0;
#endif

	dev_dbg(sfc->dev, "sfc xfer_dma len=%x\n", len);

	if (op->data.dir == SPI_MEM_DATA_OUT) {
		memcpy(sfc->buffer, op->data.buf.out, (int)len);
		dma_sync_single_for_device(sfc->dev, sfc->dma_buffer, len, DMA_TO_DEVICE);
	}

#ifdef ROCKCHIP_SFC_VERBOSE
	start_time = ktime_get();
#endif
	ret = rockchip_sfc_fifo_transfer_dma(sfc, sfc->dma_buffer, len);
	if (wait_for_completion_timeout(&sfc->cp, msecs_to_jiffies(2000)) == 0U) {
		dev_err(sfc->dev, "DMA wait for transfer finish timeout\n");
		ret = -ETIMEDOUT;
	}
#ifdef ROCKCHIP_SFC_VERBOSE
	end_time = ktime_get();
	us = ktime_to_us(ktime_sub(end_time, start_time));
	dev_err(sfc->dev, "sfc io %d cost %ldus speed:%ldKB/S %llx\n", len, us, len * 1000 / us, sfc->dma_buffer);
#endif
	rockchip_sfc_irq_mask(sfc, SFC_IMR_DMA);

#ifdef ROCKCHIP_SFC_VERBOSE
	start_time = ktime_get();
#endif
	if (op->data.dir == SPI_MEM_DATA_IN) {
		dma_sync_single_for_cpu(sfc->dev, sfc->dma_buffer, len, DMA_FROM_DEVICE);
		memcpy(op->data.buf.in, sfc->buffer, len);
	}
#ifdef ROCKCHIP_SFC_VERBOSE
	end_time = ktime_get();
	us = ktime_to_us(ktime_sub(end_time, start_time));
	dev_err(sfc->dev, "sfc cp %d cost %ldus speed:%ldKB/S\n", len, us, len * 1000 / us);
#endif

	return ret;
}

static int rockchip_sfc_xfer_done(struct rockchip_sfc *sfc, u32 timeout_us)
{
	int ret;
	u32 status;

	/*
	 * There is very little data left in fifo, and the controller will
	 * complete the transmission in a short period of time.
	 */
	ret = readl_poll_timeout(sfc->regbase + SFC_SR, status,
				 !(status & SFC_SR_IS_BUSY),
				 0, 10);
	if (ret == 0) {
		return 0;
	}

	ret = readl_poll_timeout(sfc->regbase + SFC_SR, status,
				 !(status & SFC_SR_IS_BUSY),
				 20, timeout_us);
	if (ret < 0) {
		dev_err(sfc->dev, "wait sfc idle timeout\n");
		rockchip_sfc_reset(sfc);

		ret = -EIO;
	}

	return ret;
}

static void rockchip_sfc_set_cs_gpio(struct rockchip_sfc *sfc, u8 cs, int enable)
{
	int invert;

	if (enable == 0) {
		invert = 1;
	} else {
		invert = 0;
	}

	if (sfc->cs_gpiods) {
		if (has_acpi_companion(sfc->dev) == (bool)true) {
			gpiod_set_value_cansleep(sfc->cs_gpiods[cs], invert);
		} else {
			/* Polarity handled by GPIO library */
			gpiod_set_value_cansleep(sfc->cs_gpiods[cs], enable);
		}
	}
}

static int rockchip_sfc_exec_op_bypass(struct rockchip_sfc *sfc,
				       struct spi_mem *mem,
				       struct spi_mem_op *op)
{
	u32 len;
	u8 cs = mem->spi->chip_select;
	int ret;

	if (op->data.nbytes < sfc->max_iosize) {
		len = op->data.nbytes;
	} else {
		len = sfc->max_iosize;
	}

	rockchip_sfc_adjust_op_work((struct spi_mem_op *)op);
	rockchip_sfc_set_cs_gpio(sfc, cs, 1);
	ret = rockchip_sfc_xfer_setup(sfc, mem, op, len);
	if (ret < 0) {
		return -EIO;
	}
	ret = rockchip_sfc_xfer_data_poll(sfc, op, len);
	if (ret <= 0) {
		dev_err(sfc->dev, "xfer data failed ret %d\n", ret);

		return -EIO;
	}

	ret = rockchip_sfc_xfer_done(sfc, 100000);
	rockchip_sfc_set_cs_gpio(sfc, cs, 0);

	return ret;
}

static void rockchip_sfc_delay_lines_tuning(struct rockchip_sfc *sfc, struct spi_mem *mem)
{
	struct spi_mem_op op = SPI_MEM_OP(SPI_MEM_OP_CMD(0x9FU, 1U),
						SPI_MEM_OP_NO_ADDR,
						SPI_MEM_OP_NO_DUMMY,
						SPI_MEM_OP_DATA_IN(3U, NULL, 1U));
	u8 id[3], id_temp[3];
	u16 cell_max = (u16)rockchip_sfc_get_max_dll_cells(sfc);
	u16 right, left = 0;
	u16 step = SFC_DLL_TRANING_STEP;
	bool dll_valid = (bool)false;
	u8 cs = mem->spi->chip_select;
	int ret;

	if ((cs >= SFC_MAX_CHIPSELECT_NUM) ||( sfc == NULL) || (cell_max == 0)) {
		return;
	}

	ret = rockchip_sfc_clk_set_rate(sfc, SFC_DLL_THRESHOLD_RATE);
	if (ret < 0) {
		return;
	}
	op.data.buf.in = &id;
	ret = rockchip_sfc_exec_op_bypass(sfc, mem, &op);
	if (ret < 0) {
		return;
	}
	if ((0xFFU == id[0] && 0xFFU == id[1]) ||
	    (0x00U == id[0] && 0x00U == id[1])) {
		dev_dbg(sfc->dev, "no dev, dll by pass\n");
		ret = rockchip_sfc_clk_set_rate(sfc, sfc->speed[cs]);
		if (ret < 0) {
			return;
		}
		sfc->speed[cs] = SFC_DLL_THRESHOLD_RATE;

		return;
	}

	ret = rockchip_sfc_clk_set_rate(sfc, sfc->speed[cs]);
	if (ret < 0) {
		return;
	}
	op.data.buf.in = &id_temp;
	for (right = 0U; right <= cell_max; right += step) {
		rockchip_sfc_set_delay_lines(sfc, right, cs);
		ret = rockchip_sfc_exec_op_bypass(sfc, mem, &op);
		if (ret < 0) {
			return;
		}
		dev_dbg(sfc->dev, "dll read flash id:%x %x %x\n",
			id_temp[0], id_temp[1], id_temp[2]);

		ret = memcmp(&id, &id_temp, 3);
		if ((dll_valid == (bool)true) && (ret != 0)) {
			break;
		}
		if ((dll_valid == (bool)false) && (ret == 0)) {
			left = right;
		}

		if (ret == 0) {
			dll_valid = (bool)true;
		}

		/* Add cell_max to loop */
		if (right == cell_max) {
			break;
		}
	}
	if ((dll_valid == (bool)true) && (ret != 0)) {
		right -= step;
	}

	if (dll_valid && (right - left) >= SFC_DLL_TRANING_VALID_WINDOW) {
		if ((left == 0U) && (right < cell_max)) {
			sfc->dll_cells[cs] = left + (right - left) * 2U / 5U;
		} else {
			sfc->dll_cells[cs] = left + (right - left) / 2U;
		}
	} else {
		sfc->dll_cells[cs] = 0U;
	}

	if (sfc->dll_cells[cs] > 0U) {
		dev_dbg(sfc->dev, "%d %d %d dll training success in %dMHz max_cells=%u sfc_ver=%d\n",
			left, right, sfc->dll_cells[cs], sfc->speed[cs],
			rockchip_sfc_get_max_dll_cells(sfc), rockchip_sfc_get_version(sfc));
		rockchip_sfc_set_delay_lines(sfc, sfc->dll_cells[cs], cs);
#ifdef CONFIG_MTD_SPI_NOR_AUTO_MERGE
		sfc->speed[1] = sfc->cur_speed;
		sfc->dll_cells[1] = sfc->dll_cells[0];
		rockchip_sfc_set_delay_lines(sfc, sfc->dll_cells[1], 1);
#endif
	} else {
		dev_err(sfc->dev, "%d %d dll training failed in %dMHz, reduce the frequency\n",
			left, right, sfc->speed[cs]);
		rockchip_sfc_set_delay_lines(sfc, 0, cs);
		ret = rockchip_sfc_clk_set_rate(sfc, SFC_DLL_THRESHOLD_RATE);
		if (ret) {
			return;
		}
		mem->spi->max_speed_hz = SFC_DLL_THRESHOLD_RATE;
		sfc->cur_speed = SFC_DLL_THRESHOLD_RATE;
		sfc->cur_real_speed = (u32)rockchip_sfc_clk_get_rate(sfc);
		sfc->speed[cs] = SFC_DLL_THRESHOLD_RATE;
	}
}

static int rockchip_sfc_exec_mem_op(struct spi_mem *mem, const struct spi_mem_op *op)
{
	struct rockchip_sfc *sfc = spi_master_get_devdata(mem->spi->master);
	u32 len = op->data.nbytes;
	struct spi_mem_op op_adjust;
	int ret;
	u8 cs = mem->spi->chip_select;

	if ((mem == NULL) || (mem->spi == NULL)) {
		return -EINVAL;
	}

#ifdef CONFIG_MTD_SPI_NOR_AUTO_MERGE
	cs = mem->spi->cs_gpio;
#endif

	ret = pm_runtime_get_sync(sfc->dev);
	if (ret < 0) {
		pm_runtime_put_noidle(sfc->dev);
		return ret;
	}

	if ((mem->spi->max_speed_hz != sfc->speed[cs]) &&
	    (has_acpi_companion(sfc->dev) == (bool)false)) {
		ret = rockchip_sfc_clk_set_rate(sfc, mem->spi->max_speed_hz);
		if (ret < 0) {
			goto out;
		}
		sfc->speed[cs] = mem->spi->max_speed_hz;
		sfc->cur_speed = mem->spi->max_speed_hz;
		sfc->cur_real_speed = (u32)rockchip_sfc_clk_get_rate(sfc);
		if (rockchip_sfc_get_version(sfc) >= SFC_VER_4) {
			if (sfc->cur_real_speed > SFC_DLL_THRESHOLD_RATE) {
				rockchip_sfc_delay_lines_tuning(sfc, mem);
			} else {
				rockchip_sfc_set_delay_lines(sfc, 0, cs);
			}
		}

		dev_dbg(sfc->dev, "set_freq=%dHz real_freq=%ldHz\n",
			sfc->speed[cs], rockchip_sfc_clk_get_rate(sfc));
	}

	memcpy(&op_adjust, op, sizeof(struct spi_mem_op));
	rockchip_sfc_adjust_op_work(&op_adjust);
	rockchip_sfc_set_cs_gpio(sfc, cs, 1);
	ret = rockchip_sfc_xfer_setup(sfc, mem, &op_adjust, len);
	if (ret < 0) {
		goto out;
	}
	if (len > 0U) {
		if ((sfc->use_dma == (bool)true) && (len >= SFC_DMA_TRANS_THRETHOLD) && ((len & 0x3U) == 0U)) {
			init_completion(&sfc->cp);
			rockchip_sfc_irq_unmask(sfc, SFC_IMR_DMA);
			ret = rockchip_sfc_xfer_data_dma(sfc, op, len);
		} else {
			ret = rockchip_sfc_xfer_data_poll(sfc, op, len);
		}

		if (ret <= 0) {
			dev_err(sfc->dev, "xfer data failed ret %d dir %d\n", ret, op->data.dir);

			ret = -EIO;
			goto out;
		}
	}

	ret = rockchip_sfc_xfer_done(sfc, 100000);
out:
	rockchip_sfc_set_cs_gpio(sfc, cs, 0);
	pm_runtime_mark_last_busy(sfc->dev);
	pm_runtime_put_autosuspend(sfc->dev);

	return ret;
}

static int rockchip_sfc_adjust_op_size(struct spi_mem *mem, struct spi_mem_op *op)
{
	struct rockchip_sfc *sfc = spi_master_get_devdata(mem->spi->master);

	if (op->data.nbytes < sfc->max_iosize) {
		op->data.nbytes = op->data.nbytes;
	} else {
		op->data.nbytes = sfc->max_iosize;
	}

	return 0;
}

static const struct spi_controller_mem_ops rockchip_sfc_mem_ops = {
	.exec_op = rockchip_sfc_exec_mem_op,
	.adjust_op_size = rockchip_sfc_adjust_op_size,
};

static irqreturn_t rockchip_sfc_irq_handler(int irq, void *dev_id)
{
	struct rockchip_sfc *sfc = dev_id;
	u32 reg;

	reg = readl(sfc->regbase + SFC_RISR);

	/* Clear interrupt */
	writel_relaxed(reg, sfc->regbase + SFC_ICLR);

	if ((reg & SFC_RISR_DMA) != 0U) {
		complete(&sfc->cp);

		return IRQ_HANDLED;
	}

	return IRQ_NONE;
}

static int rockchip_sfc_get_gpio_descs(struct spi_controller *ctlr, struct rockchip_sfc *sfc)
{
	u16 nb;
	int i, gpio_count, ret;
	struct gpio_desc **cs;
	struct device *dev = &ctlr->dev;
	unsigned int num_cs_gpios = 0;

	gpio_count = gpiod_count(dev, "sfc-cs");
	if (gpio_count <= 0) {
		return gpio_count;
	}
	nb = (u16)gpio_count;
	if (nb < ctlr->num_chipselect) {
		ctlr->num_chipselect = nb;
	}

	cs = devm_kcalloc(dev, ctlr->num_chipselect, sizeof(*cs),
			  GFP_KERNEL);
	if (cs == NULL) {
		return -ENOMEM;
	}
	sfc->cs_gpiods = cs;

	for (i = 0; i < gpio_count; i++) {
		cs[i] = devm_gpiod_get_index_optional(dev, "sfc-cs", (u32)i,
						      GPIOD_OUT_LOW);
		if (IS_ERR(cs[i])) {
			return -EINVAL;
		}

		if (cs[i] > 0) {
			/*
			 * If we find a CS GPIO, name it after the device and
			 * chip select line.
			 */
			char *gpioname;

			gpioname = devm_kasprintf(dev, GFP_KERNEL, "%s CS%d",
						  dev_name(dev), i);
			if (gpioname == NULL) {
				return -ENOMEM;
			}
			ret = gpiod_set_consumer_name(cs[i], gpioname);
			if (ret < 0) {
				return ret;
			}
			num_cs_gpios++;
			continue;
		}
	}

	return 0;
}

static int rockchip_sfc_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct spi_master *master;
	struct resource *res;
	struct rockchip_sfc *sfc;
	int ret;
	u32 i, val;
	unsigned long addr;

	master = devm_spi_alloc_master(&pdev->dev, sizeof(*sfc));
	if (!master) {
		return -ENOMEM;
	}

	master->flags = SPI_MASTER_HALF_DUPLEX;
	master->mem_ops = &rockchip_sfc_mem_ops;
	master->dev.of_node = pdev->dev.of_node;
	master->mode_bits = SPI_TX_QUAD | SPI_TX_DUAL | SPI_RX_QUAD | SPI_RX_DUAL;
	master->max_speed_hz = SFC_MAX_SPEED;
	master->num_chipselect = SFC_MAX_CHIPSELECT_NUM;

	sfc = spi_master_get_devdata(master);
	sfc->dev = dev;
	sfc->master = master;

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	sfc->regbase = devm_ioremap_resource(dev, res);
	if (IS_ERR(sfc->regbase)) {
		return -EINVAL;
	}

	if (!has_acpi_companion(&pdev->dev)) {
		sfc->clk = devm_clk_get(&pdev->dev, "clk_sfc");
	}
	if (IS_ERR(sfc->clk)) {
		dev_err(&pdev->dev, "Failed to get sfc interface clk\n");
		return -EINVAL;
	}

	if (!has_acpi_companion(&pdev->dev)) {
		sfc->hclk = devm_clk_get(&pdev->dev, "hclk_sfc");
	}
	if (IS_ERR(sfc->hclk)) {
		dev_err(&pdev->dev, "Failed to get sfc ahb clk\n");
		return -EINVAL;
	}

	if (has_acpi_companion(&pdev->dev)) {
		ret = device_property_read_u32(&pdev->dev, "clock-frequency", &val);
		if (ret > 0) {
			dev_err(&pdev->dev, "Failed to find clock-frequency in ACPI\n");
			return ret;
		}
		for (i = 0; i < SFC_MAX_CHIPSELECT_NUM; i++) {
			sfc->speed[i] = val;
		}
	}

	sfc->use_dma = !of_property_read_bool(sfc->dev->of_node,
					      "rockchip,sfc-no-dma");
	sfc->sclk_x2_bypass = of_property_read_bool(sfc->dev->of_node,
						    "rockchip,sclk-x2-bypass");

	ret = device_property_read_u32(&pdev->dev, "rockchip,max-dll", &sfc->max_dll_cells);
	if (ret < 0) {
		return ret;
	}
	if (sfc->max_dll_cells > SFC_DLL_CTRL0_DLL_MAX_VER5) {
		sfc->max_dll_cells = SFC_DLL_CTRL0_DLL_MAX_VER5;
	}

	ret = rockchip_sfc_get_gpio_descs(master, sfc);
	if (ret < 0) {
		dev_err(&pdev->dev, "Failed to get gpio_descs\n");
		return ret;
	}

	ret = clk_prepare_enable(sfc->hclk);
	if (ret < 0) {
		dev_err(&pdev->dev, "Failed to enable ahb clk\n");
		goto err_hclk;
	}

	ret = clk_prepare_enable(sfc->clk);
	if (ret < 0) {
		dev_err(&pdev->dev, "Failed to enable interface clk\n");
		goto err_clk;
	}

	/* Find the irq */
	ret = platform_get_irq(pdev, 0);
	if (ret < 0) {
		dev_err(dev, "Failed to get the irq\n");
		goto err_irq;
	}

	ret = devm_request_irq(dev, (u32)ret, rockchip_sfc_irq_handler,
			       0UL, pdev->name, sfc);
	if (ret < 0) {
		dev_err(dev, "Failed to request irq\n");

		return ret;
	}

	sfc->data = device_get_match_data(&pdev->dev);
	if (sfc->data) {
		sfc->grf = syscon_regmap_lookup_by_phandle(dev->of_node, "rockchip,grf");
		if (IS_ERR_OR_NULL(sfc->grf)) {
			ret = -EINVAL;
			dev_err(dev, "Failed to find grf\n");

			goto err_irq;
		}
	}

	platform_set_drvdata(pdev, sfc);

	if (IS_ENABLED(CONFIG_ROCKCHIP_THUNDER_BOOT_SFC)) {
		u32 status;

		ret = readl_poll_timeout(sfc->regbase + SFC_SR, status,
					 !(status & SFC_SR_IS_BUSY), 100,
					 5000 * USEC_PER_MSEC);
		if (ret < 0) {
			dev_err(dev, "Wait for SFC idle timeout!\n");
		} else {
			readl_poll_timeout(sfc->regbase + SFC_RISR, status,
					   !(status & SFC_RISR_DMA), 10,
					   100 * USEC_PER_MSEC);
		}
	}

	ret = rockchip_sfc_init(sfc);
	if (ret < 0) {
		goto err_irq;
	}

	sfc->version = rockchip_sfc_get_version(sfc);
	sfc->max_iosize = rockchip_sfc_get_max_iosize(sfc);

	pm_runtime_set_autosuspend_delay(dev, ROCKCHIP_AUTOSUSPEND_DELAY);
	pm_runtime_use_autosuspend(dev);
	ret = pm_runtime_set_active(dev);
	if (ret < 0) {
		return ret;
	}
	pm_runtime_enable(dev);
	pm_runtime_get_noresume(dev);

	if (sfc->use_dma) {
		addr = __get_free_pages(GFP_KERNEL | GFP_DMA32, (u32)get_order(sfc->max_iosize));
		sfc->buffer = (void *)addr;
		if (!sfc->buffer) {
			return -ENOMEM;
			goto err_dma;
		}
		sfc->dma_buffer = virt_to_phys(sfc->buffer);
	}

	ret = spi_register_master(master);
	if (ret < 0) {
		goto err_register;
	}

	pm_runtime_mark_last_busy(dev);
	ret = pm_runtime_put_autosuspend(dev);

	return ret;

err_register:
	free_pages((unsigned long)sfc->buffer, get_order(sfc->max_iosize));
err_dma:
	pm_runtime_disable(sfc->dev);
	ret = pm_runtime_set_suspended(sfc->dev);
	if (ret < 0) {
		return ret;
	}
	pm_runtime_dont_use_autosuspend(sfc->dev);
err_irq:
	clk_disable_unprepare(sfc->clk);
err_clk:
	clk_disable_unprepare(sfc->hclk);
err_hclk:
	return ret;
}

static int rockchip_sfc_remove(struct platform_device *pdev)
{
	struct rockchip_sfc *sfc = platform_get_drvdata(pdev);
	struct spi_master *master = sfc->master;

	free_pages((unsigned long)sfc->buffer, (u32)get_order(sfc->max_iosize));
	spi_unregister_master(master);

	clk_disable_unprepare(sfc->clk);
	clk_disable_unprepare(sfc->hclk);

	return 0;
}

static int __maybe_unused rockchip_sfc_runtime_suspend(struct device *dev)
{
	struct rockchip_sfc *sfc = dev_get_drvdata(dev);

	clk_disable_unprepare(sfc->clk);
	clk_disable_unprepare(sfc->hclk);

	return 0;
}

static int __maybe_unused rockchip_sfc_runtime_resume(struct device *dev)
{
	struct rockchip_sfc *sfc = dev_get_drvdata(dev);
	int ret;

	ret = clk_prepare_enable(sfc->hclk);
	if (ret < 0) {
		return ret;
	}

	ret = clk_prepare_enable(sfc->clk);
	if (ret < 0) {
		clk_disable_unprepare(sfc->hclk);
	}

	return ret;
}

static int __maybe_unused rockchip_sfc_suspend(struct device *dev)
{
	int ret;

	ret = pinctrl_pm_select_sleep_state(dev);
	if (ret < 0) {
		return ret;
	}

	return pm_runtime_force_suspend(dev);
}

static int __maybe_unused rockchip_sfc_resume(struct device *dev)
{
	struct rockchip_sfc *sfc = dev_get_drvdata(dev);
	int ret;
	u8 i;

	ret = pm_runtime_force_resume(dev);
	if (ret < 0) {
		return ret;
	}

	ret = pinctrl_pm_select_default_state(dev);
	if (ret < 0){
		return ret;
	}

	ret = pm_runtime_get_sync(dev);
	if (ret < 0) {
		pm_runtime_put_noidle(dev);
		return ret;
	}

	ret = rockchip_sfc_init(sfc);
	if (ret < 0) {
		return ret;
	}
	for (i = 0; i < SFC_MAX_CHIPSELECT_NUM; i++) {
		if (sfc->dll_cells[i] > 0U) {
			rockchip_sfc_set_delay_lines(sfc, (u16)sfc->dll_cells[i], i);
		}
	}

	pm_runtime_mark_last_busy(dev);
	ret = pm_runtime_put_autosuspend(dev);
	if (ret < 0) {
		return ret;
	}

	return 0;
}

static const struct dev_pm_ops rockchip_sfc_pm_ops = {
	SET_RUNTIME_PM_OPS(rockchip_sfc_runtime_suspend,
			   rockchip_sfc_runtime_resume, NULL)
	SET_SYSTEM_SLEEP_PM_OPS(rockchip_sfc_suspend, rockchip_sfc_resume)
};

static const struct rockchip_sfc_data rv1103b_fspi_data = {
	.powergood = {
		.valid = (bool)true,
		.grf_offset = 0x60030U,
		.bits_mask = (1U << 3),
	},
};

static const struct of_device_id rockchip_sfc_dt_ids[] = {
	{ .compatible = "rockchip,fspi",},
	{ .compatible = "rockchip,rv1103b-fspi", .data = &rv1103b_fspi_data},
	{ .compatible = "rockchip,sfc"},
	{ /* sentinel */ }
};
MODULE_DEVICE_TABLE(of, rockchip_sfc_dt_ids);

static struct platform_driver rockchip_sfc_driver = {
	.driver = {
		.name	= "rockchip-sfc",
		.of_match_table = rockchip_sfc_dt_ids,
		.pm = &rockchip_sfc_pm_ops,
	},
	.probe	= rockchip_sfc_probe,
	.remove	= rockchip_sfc_remove,
};
module_platform_driver(rockchip_sfc_driver);

MODULE_LICENSE("GPL v2");
MODULE_DESCRIPTION("Rockchip Serial Flash Controller Driver");
MODULE_AUTHOR("Shawn Lin <shawn.lin@rock-chips.com>");
MODULE_AUTHOR("Chris Morgan <macromorgan@hotmail.com>");
MODULE_AUTHOR("Jon Lin <Jon.lin@rock-chips.com>");
