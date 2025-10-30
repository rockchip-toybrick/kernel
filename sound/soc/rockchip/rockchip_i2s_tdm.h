/*
 * sound/soc/rockchip/rockchip_i2s_tdm.h
 *
 * ALSA SoC Audio Layer - Rockchip I2S_TDM Controller driver
 *
 * Copyright (c) 2018 Rockchip Electronics Co. Ltd.
 * Author: Sugar Zhang <sugar.zhang@rock-chips.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#ifndef _ROCKCHIP_I2S_TDM_H
#define _ROCKCHIP_I2S_TDM_H

/*
 * TXCR
 * transmit operation control register
 */
#define I2S_TXCR_PATH_SHIFT(x)	(23U + (unsigned int)(x) * 2U)
#define I2S_TXCR_PATH_MASK(x)	((unsigned int)0x3 << I2S_TXCR_PATH_SHIFT(x))
#define I2S_TXCR_PATH(x, v)	((v) << I2S_TXCR_PATH_SHIFT(x))
#define I2S_TXCR_RCNT_SHIFT	17
#define I2S_TXCR_RCNT_MASK	((unsigned int)0x3f << I2S_TXCR_RCNT_SHIFT)
#define I2S_TXCR_CSR_SHIFT	15
#define I2S_TXCR_CSR_MASK	((unsigned int)3 << I2S_TXCR_CSR_SHIFT)
#define I2S_TXCR_CSR(x)		((unsigned int)(x) << I2S_TXCR_CSR_SHIFT)
#define I2S_TXCR_CSR_V(v)	((((unsigned int)(v) & I2S_TXCR_CSR_MASK) >> 15) + 1U)
#define I2S_TXCR_HWT		((unsigned int)BIT(14))
#define I2S_TXCR_SJM_SHIFT	12
#define I2S_TXCR_SJM_R		((unsigned int)0 << I2S_TXCR_SJM_SHIFT)
#define I2S_TXCR_SJM_L		((unsigned int)1 << I2S_TXCR_SJM_SHIFT)
#define I2S_TXCR_FBM_SHIFT	11
#define I2S_TXCR_FBM_MSB	((unsigned int)0 << I2S_TXCR_FBM_SHIFT)
#define I2S_TXCR_FBM_LSB	((unsigned int)1 << I2S_TXCR_FBM_SHIFT)
#define I2S_TXCR_IBM_SHIFT	9
#define I2S_TXCR_IBM_NORMAL	((unsigned int)0 << I2S_TXCR_IBM_SHIFT)
#define I2S_TXCR_IBM_LSJM	((unsigned int)1 << I2S_TXCR_IBM_SHIFT)
#define I2S_TXCR_IBM_RSJM	((unsigned int)2 << I2S_TXCR_IBM_SHIFT)
#define I2S_TXCR_IBM_MASK	((unsigned int)3 << I2S_TXCR_IBM_SHIFT)
#define I2S_TXCR_PBM_SHIFT	7
#define I2S_TXCR_PBM_MODE(x)	((unsigned int)(x) << I2S_TXCR_PBM_SHIFT)
#define I2S_TXCR_PBM_MASK	(3U << I2S_TXCR_PBM_SHIFT)
#define I2S_TXCR_TFS_SHIFT	5
#define I2S_TXCR_TFS_I2S	(0U << I2S_TXCR_TFS_SHIFT)
#define I2S_TXCR_TFS_PCM	(1U << I2S_TXCR_TFS_SHIFT)
#define I2S_TXCR_TFS_TDM_PCM	(2U << I2S_TXCR_TFS_SHIFT)
#define I2S_TXCR_TFS_TDM_I2S	(3U << I2S_TXCR_TFS_SHIFT)
#define I2S_TXCR_TFS_MASK	(3U << I2S_TXCR_TFS_SHIFT)
#define I2S_TXCR_VDW_SHIFT	0
#define I2S_TXCR_VDW(x)		(((unsigned int)(x) - 1U) << I2S_TXCR_VDW_SHIFT)
#define I2S_TXCR_VDW_MASK	(0x1fU << I2S_TXCR_VDW_SHIFT)

/*
 * RXCR
 * receive operation control register
 */
#define I2S_RXCR_PATH_SHIFT(x)	(17U + (unsigned int)(x) * 2U)
#define I2S_RXCR_PATH_MASK(x)	((unsigned int)0x3 << I2S_RXCR_PATH_SHIFT(x))
#define I2S_RXCR_PATH(x, v)	((unsigned int)(v) << I2S_RXCR_PATH_SHIFT(x))
#define I2S_RXCR_CSR_SHIFT	15
#define I2S_RXCR_CSR_MASK	((unsigned int)3 << I2S_RXCR_CSR_SHIFT)
#define I2S_RXCR_CSR(x)		((unsigned int)(x) << I2S_RXCR_CSR_SHIFT)
#define I2S_RXCR_CSR_V(v)	((((unsigned int)(v) & I2S_RXCR_CSR_MASK) >> 15) + 1U)
#define I2S_RXCR_HWT		((unsigned int)BIT(14))
#define I2S_RXCR_SJM_SHIFT	12
#define I2S_RXCR_SJM_R		((unsigned int)0 << I2S_RXCR_SJM_SHIFT)
#define I2S_RXCR_SJM_L		((unsigned int)1 << I2S_RXCR_SJM_SHIFT)
#define I2S_RXCR_FBM_SHIFT	11
#define I2S_RXCR_FBM_MSB	((unsigned int)0 << I2S_RXCR_FBM_SHIFT)
#define I2S_RXCR_FBM_LSB	((unsigned int)1 << I2S_RXCR_FBM_SHIFT)
#define I2S_RXCR_IBM_SHIFT	9
#define I2S_RXCR_IBM_NORMAL	((unsigned int)0 << I2S_RXCR_IBM_SHIFT)
#define I2S_RXCR_IBM_LSJM	((unsigned int)1 << I2S_RXCR_IBM_SHIFT)
#define I2S_RXCR_IBM_RSJM	((unsigned int)2 << I2S_RXCR_IBM_SHIFT)
#define I2S_RXCR_IBM_MASK	((unsigned int)3 << I2S_RXCR_IBM_SHIFT)
#define I2S_RXCR_PBM_SHIFT	7
#define I2S_RXCR_PBM_MODE(x)	((unsigned int)(x) << I2S_RXCR_PBM_SHIFT)
#define I2S_RXCR_PBM_MASK	(3U << I2S_RXCR_PBM_SHIFT)
#define I2S_RXCR_TFS_SHIFT	5
#define I2S_RXCR_TFS_I2S	(0U << I2S_RXCR_TFS_SHIFT)
#define I2S_RXCR_TFS_PCM	(1U << I2S_RXCR_TFS_SHIFT)
#define I2S_RXCR_TFS_TDM_PCM	(2U << I2S_RXCR_TFS_SHIFT)
#define I2S_RXCR_TFS_TDM_I2S	(3U << I2S_RXCR_TFS_SHIFT)
#define I2S_RXCR_TFS_MASK	(3U << I2S_RXCR_TFS_SHIFT)
#define I2S_RXCR_VDW_SHIFT	0
#define I2S_RXCR_VDW(x)		(((unsigned int)(x) - 1U) << I2S_RXCR_VDW_SHIFT)
#define I2S_RXCR_VDW_MASK	(0x1fU << I2S_RXCR_VDW_SHIFT)

/*
 * CKR
 * clock generation register
 */
#define I2S_CKR_TRCM_SHIFT	28
#define I2S_CKR_TRCM(x)	((unsigned int)(x) << I2S_CKR_TRCM_SHIFT)
#define I2S_CKR_TRCM_TXRX	((unsigned int)0 << I2S_CKR_TRCM_SHIFT)
#define I2S_CKR_TRCM_TXONLY	((unsigned int)1 << I2S_CKR_TRCM_SHIFT)
#define I2S_CKR_TRCM_RXONLY	((unsigned int)2 << I2S_CKR_TRCM_SHIFT)
#define I2S_CKR_TRCM_MASK	((unsigned int)3 << I2S_CKR_TRCM_SHIFT)
#define I2S_CKR_MSS_SHIFT	27
#define I2S_CKR_MSS_MASTER	((unsigned int)0 << I2S_CKR_MSS_SHIFT)
#define I2S_CKR_MSS_SLAVE	((unsigned int)1 << I2S_CKR_MSS_SHIFT)
#define I2S_CKR_MSS_MASK	((unsigned int)1 << I2S_CKR_MSS_SHIFT)
#define I2S_CKR_CKP_SHIFT	26
#define I2S_CKR_CKP_NORMAL	((unsigned int)0 << I2S_CKR_CKP_SHIFT)
#define I2S_CKR_CKP_INVERTED	((unsigned int)1 << I2S_CKR_CKP_SHIFT)
#define I2S_CKR_CKP_MASK	((unsigned int)1 << I2S_CKR_CKP_SHIFT)
#define I2S_CKR_RLP_SHIFT	25
#define I2S_CKR_RLP_NORMAL	((unsigned int)0 << I2S_CKR_RLP_SHIFT)
#define I2S_CKR_RLP_INVERTED	((unsigned int)1 << I2S_CKR_RLP_SHIFT)
#define I2S_CKR_RLP_MASK	((unsigned int)1 << I2S_CKR_RLP_SHIFT)
#define I2S_CKR_TLP_SHIFT	24
#define I2S_CKR_TLP_NORMAL	((unsigned int)0 << I2S_CKR_TLP_SHIFT)
#define I2S_CKR_TLP_INVERTED	((unsigned int)1 << I2S_CKR_TLP_SHIFT)
#define I2S_CKR_TLP_MASK	((unsigned int)1 << I2S_CKR_TLP_SHIFT)
#define I2S_CKR_MDIV_SHIFT	16
#define I2S_CKR_MDIV(x)		(((unsigned int)(x) - 1U) << I2S_CKR_MDIV_SHIFT)
#define I2S_CKR_MDIV_MASK	((unsigned int)0xff << I2S_CKR_MDIV_SHIFT)
#define I2S_CKR_RSD_SHIFT	8
#define I2S_CKR_RSD(x)		(((unsigned int)(x) - 1U) << I2S_CKR_RSD_SHIFT)
#define I2S_CKR_RSD_MASK	((unsigned int)0xff << I2S_CKR_RSD_SHIFT)
#define I2S_CKR_TSD_SHIFT	0
#define I2S_CKR_TSD(x)		(((unsigned int)(x) - 1U) << I2S_CKR_TSD_SHIFT)
#define I2S_CKR_TSD_V(x)	((((unsigned int)(x) & I2S_CKR_TSD_MASK) >> I2S_CKR_TSD_SHIFT) + 1U)
#define I2S_CKR_TSD_MASK	(0xffU << I2S_CKR_TSD_SHIFT)

/*
 * FIFOLR
 * FIFO level register
 */
#define I2S_FIFOLR_RFL_SHIFT	24
#define I2S_FIFOLR_RFL_MASK	((unsigned int)0x3f << I2S_FIFOLR_RFL_SHIFT)
#define I2S_FIFOLR_TFL3_SHIFT	18
#define I2S_FIFOLR_TFL3_MASK	((unsigned int)0x3f << I2S_FIFOLR_TFL3_SHIFT)
#define I2S_FIFOLR_TFL2_SHIFT	12
#define I2S_FIFOLR_TFL2_MASK	((unsigned int)0x3f << I2S_FIFOLR_TFL2_SHIFT)
#define I2S_FIFOLR_TFL1_SHIFT	6
#define I2S_FIFOLR_TFL1_MASK	(0x3fU << I2S_FIFOLR_TFL1_SHIFT)
#define I2S_FIFOLR_TFL0_SHIFT	0
#define I2S_FIFOLR_TFL0_MASK	(0x3fU << I2S_FIFOLR_TFL0_SHIFT)

/*
 * DMACR
 * DMA control register
 */
#define I2S_DMACR_RDE_SHIFT	24
#define I2S_DMACR_RDE_DISABLE	((unsigned int)0 << I2S_DMACR_RDE_SHIFT)
#define I2S_DMACR_RDE_ENABLE	((unsigned int)1 << I2S_DMACR_RDE_SHIFT)
#define I2S_DMACR_RDE_MASK	((unsigned int)1 << I2S_DMACR_RDE_SHIFT)
#define I2S_DMACR_RDE(x)	((unsigned int)(x) << I2S_DMACR_RDE_SHIFT)
#define I2S_DMACR_RDL_SHIFT	16
#define I2S_DMACR_RDL_MASK	((unsigned int)0x1f << I2S_DMACR_RDL_SHIFT)
#define I2S_DMACR_RDL(x)	(((unsigned int)(x) - 1U) << I2S_DMACR_RDL_SHIFT)
#define I2S_DMACR_RDL_V(v)	((((unsigned int)(v) & I2S_DMACR_RDL_MASK) >> 16) + 1)
#define I2S_DMACR_TDE_SHIFT	8
#define I2S_DMACR_TDE_DISABLE	((unsigned int)0 << I2S_DMACR_TDE_SHIFT)
#define I2S_DMACR_TDE_ENABLE	((unsigned int)1 << I2S_DMACR_TDE_SHIFT)
#define I2S_DMACR_TDE_MASK	((unsigned int)1 << I2S_DMACR_TDE_SHIFT)
#define I2S_DMACR_TDE(x)	((unsigned int)(x) << I2S_DMACR_TDE_SHIFT)
#define I2S_DMACR_TDL_SHIFT	0
#define I2S_DMACR_TDL_MASK	(0x1fU << I2S_DMACR_TDL_SHIFT)
#define I2S_DMACR_TDL(x)	((unsigned int)(x) << I2S_DMACR_TDL_SHIFT)
#define I2S_DMACR_TDL_V(v)	(((unsigned int)(v) & I2S_DMACR_TDL_MASK) >> 0)

/*
 * INTCR
 * interrupt control register
 */
#define I2S_INTCR_RFT_SHIFT	20
#define I2S_INTCR_RFT(x)	((unsigned int)((x) - 1) << I2S_INTCR_RFT_SHIFT)
#define I2S_INTCR_RXOIC		((unsigned int)BIT(18))
#define I2S_INTCR_RXOIE_SHIFT	17
#define I2S_INTCR_RXOIE_MASK	((unsigned int)1 << I2S_INTCR_RXOIE_SHIFT)
#define I2S_INTCR_RXOIE(x)	((unsigned int)(x) << I2S_INTCR_RXOIE_SHIFT)
#define I2S_INTCR_RXFIE_SHIFT	16
#define I2S_INTCR_RXFIE_DISABLE	((unsigned int)0 << I2S_INTCR_RXFIE_SHIFT)
#define I2S_INTCR_RXFIE_ENABLE	((unsigned int)1 << I2S_INTCR_RXFIE_SHIFT)
#define I2S_INTCR_TFT_SHIFT	4
#define I2S_INTCR_TFT(x)	(((unsigned int)(x) - 1U) << I2S_INTCR_TFT_SHIFT)
#define I2S_INTCR_TFT_MASK	(0x1fU << I2S_INTCR_TFT_SHIFT)
#define I2S_INTCR_TXUIC		((unsigned int)BIT(2))
#define I2S_INTCR_TXUIE_SHIFT	1
#define I2S_INTCR_TXUIE_MASK	(1U << I2S_INTCR_TXUIE_SHIFT)
#define I2S_INTCR_TXUIE(x)	((unsigned int)(x) << I2S_INTCR_TXUIE_SHIFT)

/*
 * INTSR
 * interrupt status register
 */
#define I2S_INTSR_TXEIE_SHIFT	0
#define I2S_INTSR_TXEIE_DISABLE	(0U << I2S_INTSR_TXEIE_SHIFT)
#define I2S_INTSR_TXEIE_ENABLE	(1U << I2S_INTSR_TXEIE_SHIFT)
#define I2S_INTSR_RXOI_SHIFT	17
#define I2S_INTSR_RXOI_INA	((unsigned int)0 << I2S_INTSR_RXOI_SHIFT)
#define I2S_INTSR_RXOI_ACT	((unsigned int)1 << I2S_INTSR_RXOI_SHIFT)
#define I2S_INTSR_RXFI_SHIFT	16
#define I2S_INTSR_RXFI_INA	((unsigned int)0 << I2S_INTSR_RXFI_SHIFT)
#define I2S_INTSR_RXFI_ACT	((unsigned int)1 << I2S_INTSR_RXFI_SHIFT)
#define I2S_INTSR_TXUI_SHIFT	1
#define I2S_INTSR_TXUI_INA	(0U << I2S_INTSR_TXUI_SHIFT)
#define I2S_INTSR_TXUI_ACT	(1U << I2S_INTSR_TXUI_SHIFT)
#define I2S_INTSR_TXEI_SHIFT	0
#define I2S_INTSR_TXEI_INA	(0U << I2S_INTSR_TXEI_SHIFT)
#define I2S_INTSR_TXEI_ACT	(1U << I2S_INTSR_TXEI_SHIFT)

/*
 * XFER
 * Transfer start register
 */
/*
 * lp mode2 swap:
 * i2s sdi0_l <- i2s sdo0_l
 * i2s sdi0_r <- codec sdo_r
 *
 * lp mode2:
 * i2s sdi0_l <- codec sdo_l
 * i2s sdi0_r <- i2s sdo0_r
 *
 * lp mode1:
 * i2s sdi0_l <- codec sdo_l
 * i2s sdi0_r <- codec sdo_r
 * i2s sdi1_l <- i2s sdo0_l
 * i2s sdi1_r <- i2s sdo0_r
 *
 */
#define I2S_XFER_LP_MODE_MASK	((unsigned int)GENMASK(4, 2))
#define I2S_XFER_LP_MODE_2_SWAP	((unsigned int)BIT(4) | (unsigned int)BIT(3))
#define I2S_XFER_LP_MODE_2	((unsigned int)BIT(3))
#define I2S_XFER_LP_MODE_1	((unsigned int)BIT(2))
#define I2S_XFER_LP_MODE_DIS	0
#define I2S_XFER_RXS_SHIFT	1
#define I2S_XFER_RXS_STOP	(0U << I2S_XFER_RXS_SHIFT)
#define I2S_XFER_RXS_START	(1U << I2S_XFER_RXS_SHIFT)
#define I2S_XFER_RXS_MASK	(1U << I2S_XFER_RXS_SHIFT)
#define I2S_XFER_RXS(x)		((unsigned int)(x) << I2S_XFER_RXS_SHIFT)
#define I2S_XFER_TXS_SHIFT	0
#define I2S_XFER_TXS_STOP	(0U << I2S_XFER_TXS_SHIFT)
#define I2S_XFER_TXS_START	(1U << I2S_XFER_TXS_SHIFT)
#define I2S_XFER_TXS_MASK	(1U << I2S_XFER_TXS_SHIFT)
#define I2S_XFER_TXS(x)		((unsigned int)(x) << I2S_XFER_TXS_SHIFT)

/*
 * CLR
 * clear SCLK domain logic register
 */
#define I2S_CLR_RXC	((unsigned int)BIT(1))
#define I2S_CLR_TXC	((unsigned int)BIT(0))

/*
 * TXDR
 * Transimt FIFO data register, write only.
 */
#define I2S_TXDR_MASK	(0xffU)

/*
 * RXDR
 * Receive FIFO data register, write only.
 */
#define I2S_RXDR_MASK	(0xffU)

/*
 * TDM_CTRL
 * TDM ctrl register
 */
#define TDM_FSYNC_WIDTH_SEL1_MSK	((unsigned int)GENMASK(20, 18))
#define TDM_FSYNC_WIDTH_SEL1(x)		(((unsigned int)(x) - 1U) << 18)
#define TDM_FSYNC_WIDTH_SEL0_MSK	((unsigned int)BIT(17))
#define TDM_FSYNC_WIDTH_HALF_FRAME	0U
#define TDM_FSYNC_WIDTH_ONE_FRAME	((unsigned int)BIT(17))
#define TDM_SHIFT_CTRL_MSK		((unsigned int)GENMASK(16, 14))
#define TDM_SHIFT_CTRL(x)		((unsigned int)(x) << 14)
#define TDM_SLOT_BIT_WIDTH_MSK		((unsigned int)GENMASK(13, 9))
#define TDM_SLOT_BIT_WIDTH(x)		(((unsigned int)(x) - 1U) << 9)
#define TDM_FRAME_WIDTH_MSK		((unsigned int)GENMASK(8, 0))
#define TDM_FRAME_WIDTH(x)		(((unsigned int)(x) - 1U) << 0)
#define TDM_FRAME_WIDTH_V(v)		((((unsigned int)(v) & TDM_FRAME_WIDTH_MSK) >> 0) + 1U)

/*
 * CLKDIV
 * Mclk div register
 */
#define I2S_CLKDIV_TXM_SHIFT	0
#define I2S_CLKDIV_TXM(x)		(((unsigned int)(x) - 1U) << I2S_CLKDIV_TXM_SHIFT)
#define I2S_CLKDIV_TXM_MASK	(0xffU << I2S_CLKDIV_TXM_SHIFT)
#define I2S_CLKDIV_RXM_SHIFT	8
#define I2S_CLKDIV_RXM(x)		(((unsigned int)(x) - 1U) << I2S_CLKDIV_RXM_SHIFT)
#define I2S_CLKDIV_RXM_MASK	((unsigned int)0xff << I2S_CLKDIV_RXM_SHIFT)

/* Clock divider id */
enum {
	ROCKCHIP_DIV_MCLK = 0,
	ROCKCHIP_DIV_BCLK,
};

/* channel select */
#define I2S_CSR_SHIFT	15
#define I2S_CHN_2	((unsigned int)0 << I2S_CSR_SHIFT)
#define I2S_CHN_4	((unsigned int)1 << I2S_CSR_SHIFT)
#define I2S_CHN_6	((unsigned int)2 << I2S_CSR_SHIFT)
#define I2S_CHN_8	((unsigned int)3 << I2S_CSR_SHIFT)

/* io direction cfg register */
#define I2S_IO_DIRECTION_MASK	((unsigned int)7)
#define I2S_IO_8CH_OUT_2CH_IN	((unsigned int)7)
#define I2S_IO_6CH_OUT_4CH_IN	((unsigned int)3)
#define I2S_IO_4CH_OUT_6CH_IN	((unsigned int)1)
#define I2S_IO_2CH_OUT_8CH_IN	((unsigned int)0)

/* I2S REGS */
#define I2S_TXCR	(0x0000U)
#define I2S_RXCR	(0x0004U)
#define I2S_CKR		(0x0008U)
#define I2S_TXFIFOLR	(0x000cU)
#define I2S_DMACR	(0x0010U)
#define I2S_INTCR	(0x0014U)
#define I2S_INTSR	(0x0018U)
#define I2S_XFER	(0x001cU)
#define I2S_CLR		(0x0020U)
#define I2S_TXDR	(0x0024U)
#define I2S_RXDR	(0x0028U)
#define I2S_RXFIFOLR	(0x002cU)
#define I2S_TDM_TXCR	(0x0030U)
#define I2S_TDM_RXCR	(0x0034U)
#define I2S_CLKDIV	(0x0038U)

#define HIWORD_UPDATE(v, h, l)	(((unsigned int)(v) << (l)) | ((unsigned int)GENMASK((h), (l)) << 16))

/* I2Sx CLK SRC Mux Common Define */
#define I2S_CLK_SRC(v)				(((unsigned int)(v) & (unsigned int)GENMASK(11, 10)) >> 10)
#define I2S_CLK_SRC_MCLKIN			HIWORD_UPDATE(2, 11, 10)
#define I2S_CLK_SRC_PLL				HIWORD_UPDATE(0, 11, 10)
#define IS_I2S_CLK_SRC_MCLKIN(v)		(I2S_CLK_SRC(v) == 2U)

/* PX30 CRU CONFIGS */
#define PX30_CLKSEL_CON28_I2S0_TX		0x170U
#define PX30_CLKSEL_CON58_I2S0_RX		0x1e8U

#define PX30_CLKGATE_CON9			0x224U
#define PX30_CLKGATE_CON9_I2S0_TX_PLL_DIS	HIWORD_UPDATE(1, 12, 12)
#define PX30_CLKGATE_CON9_I2S0_TX_PLL_EN	HIWORD_UPDATE(0, 12, 12)

#define PX30_CLKGATE_CON17			0x244U
#define PX30_CLKGATE_CON17_I2S0_RX_PLL_DIS	HIWORD_UPDATE(1, 0, 0)
#define PX30_CLKGATE_CON17_I2S0_RX_PLL_EN	HIWORD_UPDATE(0, 0, 0)

/* PX30 GRF CONFIGS */
#define PX30_I2S0_CLK_IN_SRC_FROM_TX		HIWORD_UPDATE(1, 13, 12)
#define PX30_I2S0_CLK_IN_SRC_FROM_RX		HIWORD_UPDATE(2, 13, 12)
#define PX30_I2S0_MCLK_OUT_SRC_FROM_TX		HIWORD_UPDATE(1, 5, 5)
#define PX30_I2S0_MCLK_OUT_SRC_FROM_RX		HIWORD_UPDATE(0, 5, 5)

#define PX30_I2S0_CLK_TXONLY \
	(PX30_I2S0_MCLK_OUT_SRC_FROM_TX | PX30_I2S0_CLK_IN_SRC_FROM_TX)

#define PX30_I2S0_CLK_RXONLY \
	(PX30_I2S0_MCLK_OUT_SRC_FROM_RX | PX30_I2S0_CLK_IN_SRC_FROM_RX)

/* RK1808 CRU CONFIGS */
#define RK1808_CLKSEL_CON32_I2S0_TX		0x180U
#define RK1808_CLKSEL_CON34_I2S0_RX		0x188U

#define RK1808_CLKGATE_CON17			0x274U
#define RK1808_CLKGATE_CON17_I2S0_TX_PLL_DIS	HIWORD_UPDATE(1, 12, 12)
#define RK1808_CLKGATE_CON17_I2S0_TX_PLL_EN	HIWORD_UPDATE(0, 12, 12)

#define RK1808_CLKGATE_CON18			0x278U
#define RK1808_CLKGATE_CON18_I2S0_RX_PLL_DIS	HIWORD_UPDATE(1, 0, 0)
#define RK1808_CLKGATE_CON18_I2S0_RX_PLL_EN	HIWORD_UPDATE(0, 0, 0)

/* RK1808 GRF CONFIGS */
#define RK1808_I2S0_MCLK_OUT_SRC_FROM_RX	HIWORD_UPDATE(1, 2, 2)
#define RK1808_I2S0_MCLK_OUT_SRC_FROM_TX	HIWORD_UPDATE(0, 2, 2)
#define RK1808_I2S0_CLK_IN_SRC_FROM_TX		HIWORD_UPDATE(1, 1, 0)
#define RK1808_I2S0_CLK_IN_SRC_FROM_RX		HIWORD_UPDATE(2, 1, 0)

#define RK1808_I2S0_CLK_TXONLY \
	(RK1808_I2S0_MCLK_OUT_SRC_FROM_TX | RK1808_I2S0_CLK_IN_SRC_FROM_TX)

#define RK1808_I2S0_CLK_RXONLY \
	(RK1808_I2S0_MCLK_OUT_SRC_FROM_RX | RK1808_I2S0_CLK_IN_SRC_FROM_RX)

/* RK3308 CRU CONFIGS */
#define RK3308_CLKSEL_CON52_I2S0_TX		0x1d0U
#define RK3308_CLKSEL_CON54_I2S0_RX		0x1d8U
#define RK3308_CLKSEL_CON56_I2S1_TX		0x1e0U
#define RK3308_CLKSEL_CON58_I2S1_RX		0x1e8U

#define RK3308_CLKGATE_CON10			0x328U
#define RK3308_CLKGATE_CON10_I2S0_TX_PLL_DIS	HIWORD_UPDATE(1, 12, 12)
#define RK3308_CLKGATE_CON10_I2S0_TX_PLL_EN	HIWORD_UPDATE(0, 12, 12)

#define RK3308_CLKGATE_CON11			0x32cU
#define RK3308_CLKGATE_CON11_I2S0_RX_PLL_DIS	HIWORD_UPDATE(1, 0, 0)
#define RK3308_CLKGATE_CON11_I2S0_RX_PLL_EN	HIWORD_UPDATE(0, 0, 0)

#define RK3308_CLKGATE_CON11_I2S1_TX_PLL_DIS	HIWORD_UPDATE(1, 4, 4)
#define RK3308_CLKGATE_CON11_I2S1_TX_PLL_EN	HIWORD_UPDATE(0, 4, 4)

#define RK3308_CLKGATE_CON11_I2S1_RX_PLL_DIS	HIWORD_UPDATE(1, 8, 8)
#define RK3308_CLKGATE_CON11_I2S1_RX_PLL_EN	HIWORD_UPDATE(0, 8, 8)

/* RK3308 GRF CONFIGS */
#define RK3308_I2S0_8CH_MCLK_OUT_SRC_FROM_RX	HIWORD_UPDATE(1, 10, 10)
#define RK3308_I2S0_8CH_MCLK_OUT_SRC_FROM_TX	HIWORD_UPDATE(0, 10, 10)
#define RK3308_I2S0_8CH_CLK_IN_RX_SRC_FROM_TX	HIWORD_UPDATE(1, 9, 9)
#define RK3308_I2S0_8CH_CLK_IN_RX_SRC_FROM_RX	HIWORD_UPDATE(0, 9, 9)
#define RK3308_I2S0_8CH_CLK_IN_TX_SRC_FROM_RX	HIWORD_UPDATE(1, 8, 8)
#define RK3308_I2S0_8CH_CLK_IN_TX_SRC_FROM_TX	HIWORD_UPDATE(0, 8, 8)
#define RK3308_I2S1_8CH_MCLK_OUT_SRC_FROM_RX	HIWORD_UPDATE(1, 2, 2)
#define RK3308_I2S1_8CH_MCLK_OUT_SRC_FROM_TX	HIWORD_UPDATE(0, 2, 2)
#define RK3308_I2S1_8CH_CLK_IN_RX_SRC_FROM_TX	HIWORD_UPDATE(1, 1, 1)
#define RK3308_I2S1_8CH_CLK_IN_RX_SRC_FROM_RX	HIWORD_UPDATE(0, 1, 1)
#define RK3308_I2S1_8CH_CLK_IN_TX_SRC_FROM_RX	HIWORD_UPDATE(1, 0, 0)
#define RK3308_I2S1_8CH_CLK_IN_TX_SRC_FROM_TX	HIWORD_UPDATE(0, 0, 0)

#define RK3308_I2S0_CLK_TXONLY \
	(RK3308_I2S0_8CH_MCLK_OUT_SRC_FROM_TX | \
	RK3308_I2S0_8CH_CLK_IN_RX_SRC_FROM_TX | \
	RK3308_I2S0_8CH_CLK_IN_TX_SRC_FROM_TX)

#define RK3308_I2S0_CLK_RXONLY \
	(RK3308_I2S0_8CH_MCLK_OUT_SRC_FROM_RX | \
	RK3308_I2S0_8CH_CLK_IN_RX_SRC_FROM_RX | \
	RK3308_I2S0_8CH_CLK_IN_TX_SRC_FROM_RX)

#define RK3308_I2S1_CLK_TXONLY \
	(RK3308_I2S1_8CH_MCLK_OUT_SRC_FROM_TX | \
	RK3308_I2S1_8CH_CLK_IN_RX_SRC_FROM_TX | \
	RK3308_I2S1_8CH_CLK_IN_TX_SRC_FROM_TX)

#define RK3308_I2S1_CLK_RXONLY \
	(RK3308_I2S1_8CH_MCLK_OUT_SRC_FROM_RX | \
	RK3308_I2S1_8CH_CLK_IN_RX_SRC_FROM_RX | \
	RK3308_I2S1_8CH_CLK_IN_TX_SRC_FROM_RX)

/* RK3568 GRF CONFIGS*/
#define RK3568_I2S1_MCLK_OUT_SRC_FROM_TX	HIWORD_UPDATE(1, 5, 5)
#define RK3568_I2S1_MCLK_OUT_SRC_FROM_RX	HIWORD_UPDATE(0, 5, 5)

#define RK3568_I2S1_CLK_TXONLY \
	RK3568_I2S1_MCLK_OUT_SRC_FROM_TX

#define RK3568_I2S1_CLK_RXONLY \
	RK3568_I2S1_MCLK_OUT_SRC_FROM_RX

#define RK3568_I2S3_MCLK_OUT_SRC_FROM_TX	HIWORD_UPDATE(1, 15, 15)
#define RK3568_I2S3_MCLK_OUT_SRC_FROM_RX	HIWORD_UPDATE(0, 15, 15)
#define RK3568_I2S3_SCLK_SRC_FROM_TX		HIWORD_UPDATE(1, 7, 7)
#define RK3568_I2S3_SCLK_SRC_FROM_RX		HIWORD_UPDATE(0, 7, 7)
#define RK3568_I2S3_LRCK_SRC_FROM_TX		HIWORD_UPDATE(1, 6, 6)
#define RK3568_I2S3_LRCK_SRC_FROM_RX		HIWORD_UPDATE(0, 6, 6)

#define RK3568_I2S3_MCLK_TXONLY \
	RK3568_I2S3_MCLK_OUT_SRC_FROM_TX

#define RK3568_I2S3_CLK_TXONLY \
	(RK3568_I2S3_SCLK_SRC_FROM_TX | \
	RK3568_I2S3_LRCK_SRC_FROM_TX)

#define RK3568_I2S3_MCLK_RXONLY \
	RK3568_I2S3_MCLK_OUT_SRC_FROM_RX

#define RK3568_I2S3_CLK_RXONLY \
	(RK3568_I2S3_SCLK_SRC_FROM_RX | \
	RK3568_I2S3_LRCK_SRC_FROM_RX)

/* RV1126 GRF CONFIGS*/
#define RV1126_I2S0_MCLK_OUT_SRC_FROM_TX	HIWORD_UPDATE(0, 9, 9)
#define RV1126_I2S0_MCLK_OUT_SRC_FROM_RX	HIWORD_UPDATE(1, 9, 9)

#define RV1126_I2S0_CLK_TXONLY \
	RV1126_I2S0_MCLK_OUT_SRC_FROM_TX

#define RV1126_I2S0_CLK_RXONLY \
	RV1126_I2S0_MCLK_OUT_SRC_FROM_RX

#endif /* _ROCKCHIP_I2S_TDM_H */
