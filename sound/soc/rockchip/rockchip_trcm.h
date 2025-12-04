/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Rockchip TRCM Pcm driver
 *
 * Copyright (C) 2023 Rockchip Electronics Co., Ltd
 * Author: Sugar Zhang <sugar.zhang@rock-chips.com>
 *
 */

#ifndef _ROCKCHIP_TRCM_H
#define _ROCKCHIP_TRCM_H

#define SND_DMAENGINE_TRCM_DRV_NAME	"snd_dmaengine_trcm"

#if IS_REACHABLE(CONFIG_SND_SOC_ROCKCHIP_TRCM)

struct dmaengine_dma_guard {
	dma_addr_t dma_addr;
	unsigned char *dma_area;
};

struct dmaengine_trcm {
	struct device *dev;
	struct dma_chan *chan[SNDRV_PCM_STREAM_LAST + 1];
	struct dmaengine_dma_guard guard[SNDRV_PCM_STREAM_LAST + 1];
	struct dmaengine_dma_route route_dma[SNDRV_PCM_STREAM_LAST + 1];
	struct snd_soc_component component;
	bool always_on;
};

int dmaengine_trcm_dma_guard_ctrl(struct snd_soc_component *component,
				  int stream, bool en);
int devm_snd_dmaengine_trcm_register(struct device *dev);
int dmaengine_trcm_dma_route_ctrl(struct snd_soc_component *component,
					int stream, bool en);
inline struct dmaengine_trcm *soc_component_to_trcm(struct snd_soc_component *p);

#else
static inline int dmaengine_trcm_dma_guard_ctrl(struct snd_soc_component *component,
						int stream, bool en)
{
	return -ENOSYS;
}

static inline int devm_snd_dmaengine_trcm_register(struct device *dev)
{
	return -ENOSYS;
}

static inline int dmaengine_trcm_dma_route_ctrl(struct snd_soc_component *component,
					int stream, bool en)
{
	return -EOPNOTSUPP;
}

static inline struct dmaengine_trcm *soc_component_to_trcm(struct snd_soc_component *p)
{
	return -EOPNOTSUPP;
}

#endif

#endif
