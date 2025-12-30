/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
/*
 * Copyright (c) 2025 Rockchip Electronics Co., Ltd.
 */

#ifndef _UAPI__RK_SPI_H__
#define _UAPI__RK_SPI_H__

#include <linux/types.h>

#define SPI_BASE   'S'
#define ROCKCHIP_SPI_SET_RSD               _IOW(SPI_BASE, 0x01, int)

#endif
