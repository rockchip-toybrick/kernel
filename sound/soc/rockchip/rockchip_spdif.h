/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * ALSA SoC Audio Layer - Rockchip SPDIF transceiver driver
 *
 * Copyright (c) 2015 Collabora Ltd.
 * Author: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
 */

#ifndef _ROCKCHIP_SPDIF_H
#define _ROCKCHIP_SPDIF_H

/*
 * CFGR
 * transfer configuration register
*/
#define SPDIF_CFGR_CLK_DIV_SHIFT	(16)
#define SPDIF_CFGR_CLK_DIV_MASK		((unsigned int)0xff << SPDIF_CFGR_CLK_DIV_SHIFT)
#define SPDIF_CFGR_CLK_DIV(x)		((((unsigned int)(x)) - 1U) << SPDIF_CFGR_CLK_DIV_SHIFT)

#define SPDIF_CFGR_CLR_MASK		BIT(7)
#define SPDIF_CFGR_CLR_EN		BIT(7)
#define SPDIF_CFGR_CLR_DIS		0U

#define SPDIF_CFGR_CSE_MASK		BIT(6)
#define SPDIF_CFGR_CSE_EN		BIT(6)
#define SPDIF_CFGR_CSE_DIS		0U

#define SPDIF_CFGR_ADJ_MASK		BIT(3)
#define SPDIF_CFGR_ADJ_LEFT_J		BIT(3)
#define SPDIF_CFGR_ADJ_RIGHT_J		0U

#define SPDIF_CFGR_HALFWORD_SHIFT	2
#define SPDIF_CFGR_HALFWORD_DISABLE	(0U << SPDIF_CFGR_HALFWORD_SHIFT)
#define SPDIF_CFGR_HALFWORD_ENABLE	(1U << SPDIF_CFGR_HALFWORD_SHIFT)

#define SPDIF_CFGR_VDW_SHIFT	0
#define SPDIF_CFGR_VDW(x)	((unsigned int)(x) << SPDIF_CFGR_VDW_SHIFT)
#define SDPIF_CFGR_VDW_MASK	(0xfU << SPDIF_CFGR_VDW_SHIFT)

#define SPDIF_CFGR_VDW_16	SPDIF_CFGR_VDW(0x0)
#define SPDIF_CFGR_VDW_20	SPDIF_CFGR_VDW(0x1)
#define SPDIF_CFGR_VDW_24	SPDIF_CFGR_VDW(0x2)

/*
 * DMACR
 * DMA control register
*/
#define SPDIF_DMACR_TDE_SHIFT	5
#define SPDIF_DMACR_TDE_DISABLE	(0U << SPDIF_DMACR_TDE_SHIFT)
#define SPDIF_DMACR_TDE_ENABLE	(1U << SPDIF_DMACR_TDE_SHIFT)

#define SPDIF_DMACR_TDL_SHIFT	0
#define SPDIF_DMACR_TDL(x)	((unsigned int)(x) << SPDIF_DMACR_TDL_SHIFT)
#define SPDIF_DMACR_TDL_MASK	(0x1fU << SPDIF_DMACR_TDL_SHIFT)

/*
 * XFER
 * Transfer control register
*/
#define SPDIF_XFER_TXS_SHIFT	0
#define SPDIF_XFER_TXS_STOP	(0U << SPDIF_XFER_TXS_SHIFT)
#define SPDIF_XFER_TXS_START	(1U << SPDIF_XFER_TXS_SHIFT)

#define SPDIF_CFGR	(0x0000U)
#define SPDIF_SDBLR	(0x0004U)
#define SPDIF_DMACR	(0x0008U)
#define SPDIF_INTCR	(0x000cU)
#define SPDIF_INTSR	(0x0010U)
#define SPDIF_XFER	(0x0018U)
#define SPDIF_SMPDR	(0x0020U)
#define SPDIF_VLDFRn(x)	(0x0060U + (unsigned int)(x) * 4U)
#define SPDIF_USRDRn(x)	(0x0090U + (unsigned int)(x) * 4U)
#define SPDIF_CHNSRn(x)	(0x00c0U + (unsigned int)(x) * 4U)
#define SPDIF_VERSION	(0x01c0U)

#endif /* _ROCKCHIP_SPDIF_H */
