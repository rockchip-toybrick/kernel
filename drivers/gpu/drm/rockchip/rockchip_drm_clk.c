// SPDX-License-Identifier: (GPL-2.0+ OR MIT)
/*
 * Copyright (c) 2023 Rockchip Electronics Co., Ltd.
 * Author: Sandy Huang <hjc@rock-chips.com>
 */

#include <linux/clk.h>
#include <linux/clk-provider.h>
#include <linux/clk/clk-conf.h>

#include "rockchip_drm_vop.h"
#include "rockchip_drm_drv.h"

#define VOP2_PLL_LIMIT_FREQ 594000000UL
#define VOP2_PLL_MIN_FREQ 40000000UL

static long rockchip_rk3562_drm_dclk_round_rate(struct clk *dclk, unsigned long rate)
{
	struct clk_hw *hw;
	struct clk_hw *p_hw;
	unsigned long round_rate;
	const char *name;

	hw = __clk_get_hw(dclk);
	if (!hw) {
		return -EINVAL;
	}

	p_hw = clk_hw_get_parent(hw);
	if (!p_hw) {
		return -EINVAL;
	}
	name = clk_hw_get_name(p_hw);

	if (0 == strncmp(name, "vpll", 4)) {
		round_rate = rate;
	} else {
		round_rate = (unsigned long)clk_round_rate(dclk, rate);
	}

	return (long)round_rate;
}

static long rockchip_rk3568_drm_dclk_round_rate(struct clk *dclk, unsigned long rate)
{
	struct clk_hw *hw;
	struct clk_hw *p_hw;
	unsigned long round_rate;
	const char *name;

	hw = __clk_get_hw(dclk);
	if (!hw) {
		return -EINVAL;
	}

	p_hw = clk_hw_get_parent(hw);
	if (!p_hw) {
		return -EINVAL;
	}
	name = clk_hw_get_name(p_hw);

	if (0 == strncmp(name, "vpll", 4)) {
		round_rate = rate;
	} else if (0 == strncmp(name, "hpll", 4)) {
		round_rate = rate;
	} else {
		round_rate = (unsigned long)clk_round_rate(dclk, rate);
	}

	return (long)round_rate;
}

static long rockchip_rk3588_drm_dclk_round_rate(struct clk *dclk, unsigned long rate)
{
	struct clk_hw *hw;
	struct clk_hw *p_hw;
	unsigned long round_rate;
	const char *name;

	hw = __clk_get_hw(dclk);
	if (!hw) {
		return -EINVAL;
	}
	name = clk_hw_get_name(hw);

	if (0 == strncmp(name, "dclk_vop3", 9)) {
		p_hw = clk_hw_get_parent(hw);
	} else {
		p_hw = clk_hw_get_parent(hw);
		if (!p_hw) {
			return -EINVAL;
	}
		p_hw = clk_hw_get_parent(p_hw);
	}

	if (!p_hw) {
		return -EINVAL;
	}
	name = clk_hw_get_name(p_hw);

	if (0 == strncmp(name, "v0pll", 5)) {
		round_rate = rate;
	} else {
		round_rate = (unsigned long)clk_round_rate(dclk, rate);
	}

	return (long)round_rate;
}

/*
 * The rk3562 is a single display, exclusive to vpll
 */
static int rockchip_rk3562_drm_dclk_set_rate(struct clk *dclk, unsigned long rate)
{
	struct clk_hw *hw;
	struct clk_hw *p_hw;
	unsigned long pll_rate;
	const char *name;
	int div;

	hw = __clk_get_hw(dclk);
	if (!hw) {
		return -EINVAL;
	}

	p_hw = clk_hw_get_parent(hw);
	if (!p_hw) {
		return -EINVAL;
	}
	name = clk_hw_get_name(p_hw);

	if (0 == strncmp(name, "vpll", 4)) {
		pll_rate = clk_hw_get_rate(p_hw);
		if (pll_rate >= VOP2_PLL_LIMIT_FREQ && pll_rate % rate == 0UL) {
			(void)clk_set_rate(dclk, rate);
		} else {
			div = (int)(unsigned long)DIV_ROUND_UP(VOP2_PLL_LIMIT_FREQ, rate);
			if (div % 2 != 0) {
				div += 1;
			}
			(void)clk_set_rate(p_hw->clk, rate * (unsigned long)div);
			(void)clk_set_rate(dclk, rate);
		}
	} else {
		(void)clk_set_rate(dclk, rate);
	}

	(void)pr_debug("%s:request rate = %ld, %s = %ld, %s = %ld\n", __func__, rate,
		 clk_hw_get_name(hw), clk_hw_get_rate(hw),
		 clk_hw_get_name(p_hw), clk_hw_get_rate(p_hw));

	return 0;
}

/*
 * The rk3568 has three ports, dclk_vop0/dclk_vop1/dclk_vop2
 * For the dclk used by hdmi, the parent clock must be specified in hpll.
 * There is also a dclk that can be specified on the vpll.
 * The last dclk can only choose the nearest frequency division,
 * and cannot support accurate frequency setting.
 */
static int rockchip_rk3568_drm_dclk_set_rate(struct clk *dclk, unsigned long rate)
{
	struct clk_hw *hw;
	struct clk_hw *p_hw;
	unsigned long pll_rate;
	const char *name;
	int div;

	hw = __clk_get_hw(dclk);
	if (!hw) {
		return -EINVAL;
	}

	p_hw = clk_hw_get_parent(hw);
	if (!p_hw) {
		return -EINVAL;
	}
	name = clk_hw_get_name(p_hw);

	if (0 == strncmp(name, "vpll", 4)) {
		pll_rate = clk_hw_get_rate(p_hw);
		if (pll_rate >= VOP2_PLL_LIMIT_FREQ && pll_rate % rate == 0UL) {
			(void)clk_set_rate(dclk, rate);
		} else {
			div = (int)(unsigned long)DIV_ROUND_UP(VOP2_PLL_LIMIT_FREQ, rate);
			if (div % 2 != 0) {
				div += 1;
			}
			(void)clk_set_rate(p_hw->clk, rate * (unsigned long)div);
			(void)clk_set_rate(dclk, rate);
		}
	} else if (0 == strncmp(name, "hpll", 4)) {
		if (rate < VOP2_PLL_MIN_FREQ) {
			(void)pr_warn("%s: Warning: rate is low than pll min limit!\n", __func__);
		}
		(void)clk_set_rate(p_hw->clk, rate);
		(void)clk_set_rate(dclk, rate);
	} else {
		(void)clk_set_rate(dclk, rate);
	}

	(void)pr_debug("%s:request rate = %ld, %s = %ld %s = %ld\n", __func__, rate,
		 clk_hw_get_name(hw), clk_hw_get_rate(hw),
		 clk_hw_get_name(p_hw), clk_hw_get_rate(p_hw));

	return 0;
}

/*
 * The rk3588 has four ports, dclk_vop0\1\2\3.
 * The dclk_vop0\1\2 can select 2 ports specified on clk_hdmiphy_pixelx.
 * The dclk_vop0\1\2\3 can select 1 ports specified on v0pll.
 * The last dclk can only choose the nearest frequency division,
 * and cannot support accurate frequency setting.
 */
static int rockchip_rk3588_drm_dclk_set_rate(struct clk *dclk, unsigned long rate)
{
	struct clk_hw *hw;
	struct clk_hw *p_hw;
	unsigned long pll_rate;
	const char *name;
	int div;

	hw = __clk_get_hw(dclk);
	if (!hw) {
		return -EINVAL;
	}
	name = clk_hw_get_name(hw);

	if (0 == strncmp(name, "dclk_vop3", 9)) {
		p_hw = clk_hw_get_parent(hw);
	} else {
		p_hw = clk_hw_get_parent(hw);
		if (!p_hw) {
			return -EINVAL;
		}
		p_hw = clk_hw_get_parent(p_hw);
	}

	if (!p_hw) {
		return -EINVAL;
	}
	name = clk_hw_get_name(p_hw);

	if (0 == strncmp(name, "v0pll", 5)) {
		pll_rate = clk_hw_get_rate(p_hw);
		if (pll_rate >= VOP2_PLL_LIMIT_FREQ && pll_rate % rate == 0UL) {
			(void)clk_set_rate(dclk, rate);
		} else {
			div = (int)(unsigned long)DIV_ROUND_UP(VOP2_PLL_LIMIT_FREQ, rate);
			if (div % 2 != 0) {
				div += 1;
			}
			(void)clk_set_rate(p_hw->clk, rate * (unsigned long)div);
			(void)clk_set_rate(dclk, rate);
		}
	} else {
		(void)clk_set_rate(dclk, rate);
	}

	(void)pr_debug("%s:request rate = %ld, %s = %ld %s = %ld\n", __func__, rate,
		 clk_hw_get_name(hw), clk_hw_get_rate(hw),
		 clk_hw_get_name(p_hw), clk_hw_get_rate(p_hw));

	return 0;
}

long rockchip_drm_dclk_round_rate(u32 version, struct clk *dclk, unsigned long rate)
{
	long round_rate;

	if (version == VOP_VERSION_RK3562) {
		round_rate = rockchip_rk3562_drm_dclk_round_rate(dclk, rate);
	} else if (version == VOP_VERSION_RK3568) {
		round_rate = rockchip_rk3568_drm_dclk_round_rate(dclk, rate);
	} else if (version == VOP_VERSION_RK3588) {
		round_rate = rockchip_rk3588_drm_dclk_round_rate(dclk, rate);
	} else {
		round_rate = clk_round_rate(dclk, rate);
	}

	if (round_rate < 0) {
		(void)pr_warn("%s:the clk_hw of dclk or parent of dclk may be NULL\n", __func__);
	}

	return round_rate;
}

int rockchip_drm_dclk_set_rate(u32 version, struct clk *dclk, unsigned long rate)
{
	int ret;

	if (version == VOP_VERSION_RK3562) {
		ret = rockchip_rk3562_drm_dclk_set_rate(dclk, rate);
	} else if (version == VOP_VERSION_RK3568) {
		ret = rockchip_rk3568_drm_dclk_set_rate(dclk, rate);
	} else if (version == VOP_VERSION_RK3588) {
		ret = rockchip_rk3588_drm_dclk_set_rate(dclk, rate);
	} else {
		ret = clk_set_rate(dclk, rate);
	}

	if (ret < 0) {
		(void)pr_warn("%s:the clk_hw of dclk or parent of dclk may be NULL\n", __func__);
	}

	return ret;
}
