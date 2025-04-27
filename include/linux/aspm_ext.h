/* SPDX-License-Identifier: GPL-2.0 */

/* Copyright (c) 2024 Rockchip Electronics Co., Ltd. */

#ifndef _ASPM_EXT_H
#define _ASPM_EXT_H

enum rockchip_pcie_pm_ctrl_flag {
	ROCKCHIP_PCIE_PM_CTRL_RESET = 1,
};

int rockchip_dw_pcie_pm_ctrl_for_user(struct pci_dev *dev, enum rockchip_pcie_pm_ctrl_flag flag);

#endif
