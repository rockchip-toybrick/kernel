// SPDX-License-Identifier: GPL-2.0
/*
 * Rockchip CIF Driver
 *
 * Copyright (C) 2020 Rockchip Electronics Co., Ltd.
 */
#include <linux/clk.h>
#include <linux/delay.h>
#include <linux/interrupt.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/of_gpio.h>
#include <linux/of_graph.h>
#include <linux/of_platform.h>
#include <linux/of_reserved_mem.h>
#include <linux/reset.h>
#include <linux/pm_runtime.h>
#include <linux/pinctrl/consumer.h>
#include <linux/regmap.h>
#include <media/videobuf2-dma-contig.h>
#include <media/v4l2-fwnode.h>
#include <media/v4l2-event.h>
#include "dev.h"

struct sensor_async_subdev {
	struct v4l2_async_subdev asd;
	struct v4l2_mbus_config mbus;
	int lanes;
};

static inline struct sditf_priv *to_sditf_priv(struct v4l2_subdev *subdev)
{
	return container_of(subdev, struct sditf_priv, sd);
}

void sditf_event_inc_sof(struct sditf_priv *priv)
{
	if (priv) {
		struct v4l2_event event = {
			.type = V4L2_EVENT_FRAME_SYNC,
			.u.frame_sync.frame_sequence =
				atomic_inc_return(&priv->frm_sync_seq) - 1,
		};
		v4l2_event_queue(priv->sd.devnode, &event);
		dev_err(priv->dev, "sof %d\n", atomic_read(&priv->frm_sync_seq) - 1);
	}
}

void sditf_event_exposure_notifier(struct sditf_priv *priv,
					   struct sditf_effect_exp *effect_exp)
{
	if (priv) {
		struct v4l2_event event = {
			.type = V4L2_EVENT_EXPOSURE,
		};
		v4l2_event_queue(priv->sd.devnode, &event);
	}
}

u32 sditf_get_sof(struct sditf_priv *priv)
{
	if (priv)
		return atomic_read(&priv->frm_sync_seq) - 1;

	return 0;
}

void sditf_set_sof(struct sditf_priv *priv, u32 seq)
{
	if (priv)
		atomic_set(&priv->frm_sync_seq, seq);
}

static int sditf_subscribe_event(struct v4l2_subdev *sd, struct v4l2_fh *fh,
					     struct v4l2_event_subscription *sub)
{
	if (sub->type == V4L2_EVENT_FRAME_SYNC || sub->type == V4L2_EVENT_EXPOSURE)
		return v4l2_event_subscribe(fh, sub, 0, NULL);
	else
		return -EINVAL;
}

static int sditf_g_frame_interval(struct v4l2_subdev *sd,
				  struct v4l2_subdev_frame_interval *fi)
{
	struct sditf_priv *priv = to_sditf_priv(sd);
	struct rkcif_device *cif_dev = priv->cif_dev;
	struct v4l2_subdev *sensor_sd;

	if (!cif_dev->terminal_sensor.sd)
		rkcif_update_sensor_info(&cif_dev->stream[0]);

	if (cif_dev->terminal_sensor.sd) {
		sensor_sd = cif_dev->terminal_sensor.sd;
		return v4l2_subdev_call(sensor_sd, video, g_frame_interval, fi);
	}

	return -EINVAL;
}

static int sditf_g_mbus_config(struct v4l2_subdev *sd,
			       struct v4l2_mbus_config *config)
{
	struct sditf_priv *priv = to_sditf_priv(sd);
	struct rkcif_device *cif_dev = priv->cif_dev;
	struct v4l2_subdev *sensor_sd;

	if (!cif_dev->active_sensor)
		rkcif_update_sensor_info(&cif_dev->stream[0]);

	if (cif_dev->active_sensor) {
		sensor_sd = cif_dev->active_sensor->sd;
		return v4l2_subdev_call(sensor_sd, video, g_mbus_config, config);
	}

	return -EINVAL;
}

static int sditf_get_set_fmt(struct v4l2_subdev *sd,
			     struct v4l2_subdev_pad_config *cfg,
			     struct v4l2_subdev_format *fmt)
{
	struct sditf_priv *priv = to_sditf_priv(sd);
	struct rkcif_device *cif_dev = priv->cif_dev;
	struct v4l2_subdev_selection input_sel;
	int ret = -EINVAL;

	if (!cif_dev->terminal_sensor.sd)
		rkcif_update_sensor_info(&cif_dev->stream[0]);

	if (cif_dev->terminal_sensor.sd) {
		ret = v4l2_subdev_call(cif_dev->terminal_sensor.sd, pad, get_fmt, NULL, fmt);
		if (ret) {
			v4l2_err(&priv->sd,
				 "%s: get sensor format failed\n", __func__);
			return ret;
		}

		input_sel.target = V4L2_SEL_TGT_CROP_BOUNDS;
		ret = v4l2_subdev_call(cif_dev->terminal_sensor.sd,
				       pad, get_selection, NULL,
				       &input_sel);
		if (!ret) {
			fmt->format.width = input_sel.r.width;
			fmt->format.height = input_sel.r.height;
		}
	}

	return 0;
}

static int sditf_get_selection(struct v4l2_subdev *sd,
			       struct v4l2_subdev_pad_config *cfg,
			       struct v4l2_subdev_selection *sel)
{
	return -EINVAL;
}

static long sditf_ioctl(struct v4l2_subdev *sd, unsigned int cmd, void *arg)
{
	struct sditf_priv *priv = to_sditf_priv(sd);
	struct rkcif_device *cif_dev = priv->cif_dev;
	struct v4l2_subdev *sensor_sd;
	struct rkcif_exp *exp;
	struct rkcif_effect_exp *effect_exposure;
	struct sditf_time *time;
	struct sditf_gain *gain;
	struct sditf_effect_exp *effect_exp;
	int *connect_id = NULL;
	int ret = 0;

	if (!cif_dev->terminal_sensor.sd)
		rkcif_update_sensor_info(&cif_dev->stream[0]);

	switch (cmd) {
	case RKCIF_CMD_SET_EXPOSURE:
		exp = (struct rkcif_exp *)arg;
		time = kzalloc(sizeof(*time), GFP_KERNEL);
		if (!time) {
			ret = -ENOMEM;
			return ret;
		}
		gain = kzalloc(sizeof(*gain), GFP_KERNEL);
		if (!gain) {
			ret = -ENOMEM;
			kfree(time);
			return ret;
		}
		time->time = exp->time;
		gain->gain = exp->gain;
		mutex_lock(&priv->mutex);
		list_add_tail(&time->list, &priv->time_head);
		list_add_tail(&gain->list, &priv->gain_head);
		mutex_unlock(&priv->mutex);
		if (cif_dev->exp_dbg)
			dev_info(priv->dev, "RKCIF_CMD_SET_EXPOSURE %d\n", ret);
		return ret;
	case RKCIF_CMD_GET_EFFECT_EXPOSURE:
		if (!list_empty(&priv->effect_exp_head)) {
			effect_exp = list_first_entry(&priv->effect_exp_head,
						      struct sditf_effect_exp,
						      list);
			if (effect_exp) {
				effect_exposure = (struct rkcif_effect_exp *)arg;
				mutex_lock(&priv->mutex);
				list_del(&effect_exp->list);
				mutex_unlock(&priv->mutex);
				*effect_exposure = effect_exp->exp;
				kfree(effect_exp);
			}
		} else {
			ret = -EINVAL;
		}
		if (cif_dev->exp_dbg)
			dev_info(priv->dev, "RKCIF_CMD_GET_EFFECT_EXPOSURE %d\n", ret);
		return ret;
	case RKCIF_CMD_GET_CONNECT_ID:
		connect_id = (int *)arg;
		*connect_id = priv->connect_id;
		return ret;
	default:
		if (cif_dev->terminal_sensor.sd) {
			sensor_sd = cif_dev->terminal_sensor.sd;
			return v4l2_subdev_call(sensor_sd, core, ioctl, cmd, arg);
		}
	}

	return -EINVAL;
}

#ifdef CONFIG_COMPAT
static long sditf_compat_ioctl32(struct v4l2_subdev *sd,
				  unsigned int cmd, unsigned long arg)
{
	struct sditf_priv *priv = to_sditf_priv(sd);
	struct rkcif_device *cif_dev = priv->cif_dev;
	struct v4l2_subdev *sensor_sd;
	struct rkcif_exp *exp;
	struct rkcif_effect_exp *effect_expsure;
	int connect_id = 0;
	int ret = 0;

	if (!cif_dev->terminal_sensor.sd)
		rkcif_update_sensor_info(&cif_dev->stream[0]);

	switch (cmd) {
	case RKCIF_CMD_SET_EXPOSURE:
		exp = kzalloc(sizeof(*exp), GFP_KERNEL);
		if (!exp) {
			ret = -ENOMEM;
			return ret;
		}
		if (copy_from_user(exp, up, sizeof(*exp))) {
			kfree(exp);
			return -EFAULT;
		}
		ret = sditf_ioctl(sd, cmd, exp);
		kfree(exp);
		return ret;
	case RKCIF_CMD_GET_EFFECT_EXPOSURE:
		effect_expsure = kzalloc(sizeof(*effect_expsure), GFP_KERNEL);
		if (!effect_expsure) {
			ret = -ENOMEM;
			return ret;
		}
		ret = sditf_ioctl(sd, cmd, effect_expsure);
		if (!ret) {
			ret = copy_to_user(up, effect_expsure, sizeof(*effect_expsure));
			if (ret)
				ret = -EFAULT;
		}
		kfree(effect_expsure);
		return ret;
	case RKCIF_CMD_GET_CONNECT_ID:
		ret = sditf_ioctl(sd, cmd, &connect_id);
		if (!ret) {
			ret = copy_to_user(up, &connect_id, sizeof(int));
			if (ret)
				ret = -EFAULT;
		}
		return ret;
	default:
		if (cif_dev->terminal_sensor.sd) {
			sensor_sd = cif_dev->terminal_sensor.sd;
			return v4l2_subdev_call(sensor_sd, core, compat_ioctl32, cmd, arg);
		}
	}
	return -EINVAL;
}
#endif

static const struct v4l2_subdev_pad_ops sditf_subdev_pad_ops = {
	.set_fmt = sditf_get_set_fmt,
	.get_fmt = sditf_get_set_fmt,
	.get_selection = sditf_get_selection,
};

static const struct v4l2_subdev_video_ops sditf_video_ops = {
	.g_frame_interval = sditf_g_frame_interval,
	.g_mbus_config = sditf_g_mbus_config,
};

static const struct v4l2_subdev_core_ops sditf_core_ops = {
	.subscribe_event = sditf_subscribe_event,
	.unsubscribe_event = v4l2_event_subdev_unsubscribe,
	.ioctl = sditf_ioctl,
#ifdef CONFIG_COMPAT
	.compat_ioctl32 = sditf_compat_ioctl32,
#endif
};

static const struct v4l2_subdev_ops sditf_subdev_ops = {
	.core = &sditf_core_ops,
	.video = &sditf_video_ops,
	.pad = &sditf_subdev_pad_ops,
};

void sditf_get_default_exp(struct sditf_priv *sditf)
{
	struct v4l2_ctrl *ctrl = NULL;
	struct rkcif_device *dev = sditf->cif_dev;

	if (dev->terminal_sensor.sd == NULL)
		return;
	ctrl = v4l2_ctrl_find(dev->terminal_sensor.sd->ctrl_handler,
			      V4L2_CID_EXPOSURE);
	if (ctrl)
		sditf->cur_time = ctrl->default_value;
	else
		sditf->cur_time = 16;

	ctrl = v4l2_ctrl_find(dev->terminal_sensor.sd->ctrl_handler,
			      V4L2_CID_ANALOGUE_GAIN);
	if (ctrl)
		sditf->cur_gain = ctrl->default_value;
	else
		sditf->cur_gain = 16;

	if (dev->exp_dbg)
		dev_info(sditf->dev, "get default time 0x%x gain 0x%x\n",
			 sditf->cur_time, sditf->cur_gain);
}

static int rkcif_sditf_attach_cifdev(struct sditf_priv *sditf)
{
	struct device_node *np;
	struct platform_device *pdev;
	struct rkcif_device *cif_dev;

	np = of_parse_phandle(sditf->dev->of_node, "rockchip,cif", 0);
	if (!np || !of_device_is_available(np)) {
		dev_err(sditf->dev, "failed to get cif dev node\n");
		return -ENODEV;
	}

	pdev = of_find_device_by_node(np);
	of_node_put(np);
	if (!pdev) {
		dev_err(sditf->dev, "failed to get cif dev from node\n");
		return -ENODEV;
	}

	cif_dev = platform_get_drvdata(pdev);
	if (!cif_dev) {
		dev_err(sditf->dev, "failed attach cif dev\n");
		return -EINVAL;
	}

	cif_dev->sditf[cif_dev->sditf_cnt] = sditf;
	sditf->cif_dev = cif_dev;
	sditf->connect_id = cif_dev->sditf_cnt;
	cif_dev->sditf_cnt++;

	return 0;
}

static int sditf_fwnode_parse(struct device *dev,
					  struct v4l2_fwnode_endpoint *vep,
					  struct v4l2_async_subdev *asd)
{
	struct sensor_async_subdev *s_asd =
			container_of(asd, struct sensor_async_subdev, asd);
	struct v4l2_mbus_config *config = &s_asd->mbus;

	if (vep->base.port != 0) {
		dev_err(dev, "sditf has only port 0\n");
		return -EINVAL;
	}

	if (vep->bus_type == V4L2_MBUS_CSI2) {
		config->type = vep->bus_type;
		config->flags = vep->bus.mipi_csi2.flags;
		s_asd->lanes = vep->bus.mipi_csi2.num_data_lanes;
	} else if (vep->bus_type == V4L2_MBUS_CCP2) {
		config->type = vep->bus_type;
		s_asd->lanes = vep->bus.mipi_csi1.data_lane;
	} else {
		dev_err(dev, "type is not supported\n");
		return -EINVAL;
	}

	switch (s_asd->lanes) {
	case 1:
		config->flags |= V4L2_MBUS_CSI2_1_LANE;
		break;
	case 2:
		config->flags |= V4L2_MBUS_CSI2_2_LANE;
		break;
	case 3:
		config->flags |= V4L2_MBUS_CSI2_3_LANE;
		break;
	case 4:
		config->flags |= V4L2_MBUS_CSI2_4_LANE;
		break;
	default:
		return -EINVAL;
	}

	return 0;
}

static int sditf_notifier_bound(struct v4l2_async_notifier *notifier,
				 struct v4l2_subdev *subdev,
				 struct v4l2_async_subdev *asd)
{
	struct sditf_priv *sditf = container_of(notifier,
					struct sditf_priv, notifier);
	struct media_entity *source_entity, *sink_entity;
	int ret = 0;

	sditf->sensor_sd = subdev;

	if (sditf->num_sensors == 1) {
		v4l2_err(subdev,
			 "%s: the num of subdev is beyond %d\n",
			 __func__, sditf->num_sensors);
		return -EBUSY;
	}

	if (sditf->sd.entity.pads[0].flags & MEDIA_PAD_FL_SINK) {
		source_entity = &subdev->entity;
		sink_entity = &sditf->sd.entity;

		ret = media_create_pad_link(source_entity,
					    0,
					    sink_entity,
					    0,
					    MEDIA_LNK_FL_ENABLED);
		if (ret)
			v4l2_err(&sditf->sd, "failed to create link for %s\n",
				 sditf->sensor_sd->name);
	}
	sditf->sensor_sd = subdev;
	++sditf->num_sensors;

	v4l2_err(subdev, "Async registered subdev\n");

	return 0;
}

static void sditf_notifier_unbind(struct v4l2_async_notifier *notifier,
				       struct v4l2_subdev *sd,
				       struct v4l2_async_subdev *asd)
{
	struct sditf_priv *sditf = container_of(notifier,
						struct sditf_priv,
						notifier);

	sditf->sensor_sd = NULL;
}

static const struct v4l2_async_notifier_operations sditf_notifier_ops = {
	.bound = sditf_notifier_bound,
	.unbind = sditf_notifier_unbind,
};

static int sditf_subdev_notifier(struct sditf_priv *sditf)
{
	int ret;

	ret = v4l2_async_notifier_parse_fwnode_endpoints_by_port(
			sditf->dev, &sditf->notifier,
			sizeof(struct sensor_async_subdev), 0,
			sditf_fwnode_parse);
		if (ret < 0)
			return ret;

	sditf->sd.subdev_notifier = &sditf->notifier;
	sditf->notifier.ops = &sditf_notifier_ops;

	ret = v4l2_async_subdev_notifier_register(&sditf->sd, &sditf->notifier);
	if (ret) {
		v4l2_err(&sditf->sd,
			 "failed to register async notifier : %d\n",
			 ret);
		v4l2_async_notifier_cleanup(&sditf->notifier);
		return ret;
	}

	return v4l2_async_register_subdev(&sditf->sd);
}

static int sditf_count_port_nodes(struct device_node *root_node)
{
	int count = 0;
	struct device_node *node = NULL;

	for_each_child_of_node(root_node, node) {
		if (of_node_cmp(node->name, "port") == 0)
			count++;
		count += sditf_count_port_nodes(node);
	}
	return count;
}

static int rkcif_subdev_media_init(struct sditf_priv *priv)
{
	struct rkcif_device *cif_dev = priv->cif_dev;
	int ret;
	int pad_num = 0;

	priv->port_count = sditf_count_port_nodes(priv->dev->of_node);
	if (priv->port_count > 1) {
		priv->pads[0].flags = MEDIA_PAD_FL_SINK;
		priv->pads[1].flags = MEDIA_PAD_FL_SOURCE;
		pad_num = 2;
	} else {
		priv->pads[0].flags = MEDIA_PAD_FL_SOURCE;
		pad_num = 1;
	}
	priv->sd.entity.function = MEDIA_ENT_F_PROC_VIDEO_COMPOSER;
	ret = media_entity_pads_init(&priv->sd.entity, pad_num, priv->pads);
	if (ret < 0)
		return ret;

	strncpy(priv->sd.name, dev_name(cif_dev->dev), sizeof(priv->sd.name));
	INIT_LIST_HEAD(&priv->time_head);
	INIT_LIST_HEAD(&priv->gain_head);
	INIT_LIST_HEAD(&priv->effect_exp_head);
	priv->frame_idx.cur_frame_idx = 0;
	atomic_set(&priv->frm_sync_seq, 0);
	mutex_init(&priv->mutex);
	if (priv->port_count > 1)
		sditf_subdev_notifier(priv);

	return 0;
}

static int rkcif_subdev_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct v4l2_subdev *sd;
	struct sditf_priv *priv;
	int ret;

	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
	if (!priv)
		return -ENOMEM;
	priv->dev = dev;

	sd = &priv->sd;
	v4l2_subdev_init(sd, &sditf_subdev_ops);
	sd->owner = THIS_MODULE;
	sd->flags |= V4L2_SUBDEV_FL_HAS_DEVNODE | V4L2_SUBDEV_FL_HAS_EVENTS;
	snprintf(sd->name, sizeof(sd->name), "rockchip-cif-sditf");
	sd->dev = dev;

	platform_set_drvdata(pdev, &sd->entity);

	rkcif_sditf_attach_cifdev(priv);
	ret = rkcif_subdev_media_init(priv);
	if (ret < 0)
		return ret;

	pm_runtime_enable(&pdev->dev);
	return 0;
}

static int rkcif_subdev_remove(struct platform_device *pdev)
{
	struct media_entity *me = platform_get_drvdata(pdev);
	struct v4l2_subdev *sd = media_entity_to_v4l2_subdev(me);

	media_entity_cleanup(&sd->entity);

	pm_runtime_disable(&pdev->dev);
	return 0;
}

static int sditf_runtime_suspend(struct device *dev)
{
	return 0;
}

static int sditf_runtime_resume(struct device *dev)
{
	return 0;
}

static const struct dev_pm_ops rkcif_subdev_pm_ops = {
	SET_RUNTIME_PM_OPS(sditf_runtime_suspend,
			   sditf_runtime_resume, NULL)
};

static const struct of_device_id rkcif_subdev_match_id[] = {
	{
		.compatible = "rockchip,rkcif-sditf",
	},
	{}
};
MODULE_DEVICE_TABLE(of, rkcif_subdev_match_id);

struct platform_driver rkcif_subdev_driver = {
	.probe = rkcif_subdev_probe,
	.remove = rkcif_subdev_remove,
	.driver = {
		.name = "rkcif_sditf",
		.pm = &rkcif_subdev_pm_ops,
		.of_match_table = rkcif_subdev_match_id,
	},
};
EXPORT_SYMBOL(rkcif_subdev_driver);

MODULE_AUTHOR("Rockchip Camera/ISP team");
MODULE_DESCRIPTION("Rockchip CIF platform driver");
MODULE_LICENSE("GPL v2");
