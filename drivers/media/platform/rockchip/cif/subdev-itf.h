/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Rockchip CIF Driver
 *
 * Copyright (C) 2020 Rockchip Electronics Co., Ltd.
 */

#ifndef _RKCIF_SDITF_H
#define _RKCIF_SDITF_H

#include <linux/mutex.h>
#include <media/media-device.h>
#include <media/media-entity.h>
#include <media/v4l2-ctrls.h>
#include <media/v4l2-device.h>
#include <media/videobuf2-v4l2.h>
#include <media/v4l2-mc.h>
#include <linux/rk-camera-module.h>
#include "hw.h"

struct sditf_frame_idx {
	u32 cur_frame_idx;
	u32 total_frame_idx;
};

struct sditf_time {
	struct list_head list;
	u32 time;
};

struct sditf_gain {
	struct list_head list;
	u32 gain;
};

struct sditf_effect_time {
	struct list_head list;
	u32 sequence;
	u32 time;
};

struct sditf_effect_gain {
	struct list_head list;
	u32 sequence;
	u32 gain;
};

struct sditf_effect_exp {
	struct list_head list;
	struct rkcif_effect_exp exp;
};

struct sditf_priv {
	struct device *dev;
	struct v4l2_async_notifier notifier;
	struct v4l2_subdev sd;
	struct media_pad pads[2];
	struct rkcif_device *cif_dev;
	struct sditf_frame_idx frame_idx;
	struct mutex mutex;
	struct v4l2_subdev *sensor_sd;
	atomic_t frm_sync_seq;
	int connect_id;
	struct list_head time_head;
	struct list_head gain_head;
	struct list_head effect_exp_head;
	u32 cur_time;
	u32 cur_gain;
	int one_to_multi_id;
	int port_count;
	int num_sensors;
};

extern struct platform_driver rkcif_subdev_driver;
void sditf_event_exposure_notifier(struct sditf_priv *priv,
					   struct sditf_effect_exp *effect_exp);
void sditf_event_inc_sof(struct sditf_priv *priv);
u32 sditf_get_sof(struct sditf_priv *priv);
void sditf_set_sof(struct sditf_priv *priv, u32 seq);
void sditf_get_default_exp(struct sditf_priv *sditf);

#endif
