/* SPDX-License-Identifier: GPL-2.0 */
/* Copyright (c) 2020 Rockchip Electronics Co., Ltd. */
#ifndef _RKCIF_MIPI_CSI2_H_
#define _RKCIF_MIPI_CSI2_H_

#include <linux/notifier.h>
#include <media/v4l2-fwnode.h>

#define CSI2_ERR_FSFE_MASK	(0xff << 8)
#define CSI2_ERR_COUNT_ALL_MASK	(0xff)

/*
 * there must be 5 pads: 1 input pad from sensor, and
 * the 4 virtual channel output pads
 */
#define CSI2_SINK_PAD			0
#define CSI2_NUM_SINK_PADS		1
#define CSI2_NUM_SRC_PADS		4
#define CSI2_NUM_PADS			5
#define CSI2_NUM_PADS_SINGLE_LINK	2
#define MAX_CSI2_SENSORS		2

#define RKCIF_DEFAULT_WIDTH	640
#define RKCIF_DEFAULT_HEIGHT	480

/*
 * The default maximum bit-rate per lane in Mbps, if the
 * source subdev does not provide V4L2_CID_LINK_FREQ.
 */
#define CSI2_DEFAULT_MAX_MBPS 849

#define IMX_MEDIA_GRP_ID_CSI2      BIT(8)
#define CSIHOST_MAX_ERRINT_COUNT	10

/*
 * add new chip id in tail in time order
 * by increasing to distinguish csi2 host version
 */
enum rkcsi2_chip_id {
	CHIP_PX30_CSI2,
	CHIP_RK1808_CSI2,
	CHIP_RK3128_CSI2,
	CHIP_RK3288_CSI2,
	CHIP_RV1126_CSI2,
	CHIP_RK3568_CSI2,
};

enum csi2_pads {
	RK_CSI2_PAD_SINK = 0,
	RK_CSI2X_PAD_SOURCE0,
	RK_CSI2X_PAD_SOURCE1,
	RK_CSI2X_PAD_SOURCE2,
	RK_CSI2X_PAD_SOURCE3
};

enum csi2_err {
	RK_CSI2_ERR_SOTSYN = 0x0,
	RK_CSI2_ERR_FS_FE_MIS,
	RK_CSI2_ERR_FRM_SEQ_ERR,
	RK_CSI2_ERR_CRC_ONCE,
	RK_CSI2_ERR_CRC,
	RK_CSI2_ERR_ALL,
	RK_CSI2_ERR_MAX
};

enum host_type_t {
	RK_CSI_RXHOST,
	RK_DSI_RXHOST
};

struct csi2_match_data {
	int chip_id;
	int num_pads;
};

struct csi2_sensor {
	struct v4l2_subdev *sd;
	struct v4l2_mbus_config mbus;
	int lanes;
};

struct csi2_err_stats {
	unsigned int cnt;
};

struct csi2_dev {
	struct device		*dev;
	struct v4l2_subdev	sd;
	struct media_pad	pad[CSI2_NUM_PADS];
	struct clk_bulk_data	*clks_bulk;
	int			clks_num;
	struct reset_control	*rsts_bulk;

	void __iomem		*base;
	struct v4l2_async_notifier	notifier;
	struct v4l2_fwnode_bus_mipi_csi2	bus;

	/* lock to protect all members below */
	struct mutex lock;

	struct v4l2_mbus_framefmt	format_mbus;
	struct v4l2_rect	crop;
	int			stream_count;
	struct v4l2_subdev	*src_sd;
	bool			sink_linked[CSI2_NUM_SRC_PADS];
	struct csi2_sensor	sensors[MAX_CSI2_SENSORS];
	const struct csi2_match_data	*match_data;
	int			num_sensors;
	atomic_t		frm_sync_seq;
	struct csi2_err_stats err_list[RK_CSI2_ERR_MAX];
	int dsi_input_en;
};

u32 rkcif_csi2_get_sof(void);
void rkcif_csi2_set_sof(u32 seq);
void rkcif_csi2_event_inc_sof(void);
int __init rkcif_csi2_plat_drv_init(void);
void __exit rkcif_csi2_plat_drv_exit(void);
int rkcif_csi2_register_notifier(struct notifier_block *nb);
int rkcif_csi2_unregister_notifier(struct notifier_block *nb);

#endif
