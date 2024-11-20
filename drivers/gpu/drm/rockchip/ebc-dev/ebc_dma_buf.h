/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (c) 2024 Rockchip Electronics Co., Ltd.
 */

#ifndef EBC_DMA_BUF_H
#define EBC_DMA_BUF_H

#include <linux/dma-buf.h>

/**
 * ebc_get_dma_buf - Convert ebc buffer to dma_buf
 * @phy_addr: Physical address of the ebc buffer
 * @size: Size of the ebc buffer
 *
 * The caller must ensure that the physical address and size of the ebc buffer
 * are aligned to PAGE_SIZE.
 */
struct dma_buf *ebc_get_dma_buf(phys_addr_t phy_addr, size_t size);

#endif /* EBC_DMA_BUF_H */
