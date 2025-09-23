#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/thermal.h>
#include <linux/of.h>
#include <linux/of_device.h>
#include <linux/slab.h>

#include <linux/devfreq.h>
#if IS_ENABLED(CONFIG_DEVFREQ_THERMAL)
#include <linux/devfreq_cooling.h>
#endif

#include "../../devfreq/governor.h"
#include "../../opp/opp.h"

struct yw_opp {
	unsigned long freq;
	unsigned long u_volt;
};

struct yw_fake_gpu {
	struct device *dev;
	struct devfreq_dev_profile devfreq_profile;
	struct devfreq *devfreq;
	unsigned long freq_limit;

#if IS_ENABLED(CONFIG_DEVFREQ_THERMAL)
	struct devfreq_cooling_power dfc_power;
	struct thermal_cooling_device *devfreq_cooling;
#endif
};

static int yw_request_host_opp(struct yw_opp **yw_opps)
{
	int count, i;

	/* 此处请求host频率电压表, 以及条目数count, 如果失败, 返回-EPROBE_DEFER */
	count = 8;
	if (0)
		return -EPROBE_DEFER;

	*yw_opps = kzalloc(sizeof(struct yw_opp) * (count + 1), GFP_KERNEL);
	if (!*yw_opps)
		return -ENOMEM;

	for (i = 0; i < count; i++) {
		(*yw_opps)[i].freq = i * 100000000 + 300000000;
		(*yw_opps)[i].u_volt = 800000;
	}

	(*yw_opps)[i].freq = UINT_MAX;
	(*yw_opps)[i].u_volt = UINT_MAX;

	return 0;
}

static int yw_fake_gpu_calibrate_opp(struct yw_fake_gpu *gpu, struct yw_opp *yw_opps)
{
	struct opp_table *opp_table;
	struct dev_pm_opp *opp;
	int i;

	opp_table = dev_pm_opp_get_opp_table(gpu->dev);
	if (IS_ERR(opp_table))
		return PTR_ERR(opp_table);

	i = 0;
	mutex_lock(&opp_table->lock);
	list_for_each_entry(opp, &opp_table->opp_list, node) {
		if (!opp->available || !opp->supplies)
			continue;
		if (yw_opps[i].freq == UINT_MAX)
			break;

		if (opp->rate != yw_opps[i].freq)
			dev_warn(gpu->dev, "freq mismatch");
		opp->supplies[0].u_volt = yw_opps[i].u_volt;
		i++;
	}
	mutex_unlock(&opp_table->lock);
	dev_pm_opp_put_opp_table(opp_table);

	return 0;
}

static int yw_devfreq_init_freq_table(struct yw_fake_gpu *gpu, struct devfreq_dev_profile *dp)
{
	int count;
	unsigned int i = 0;
	unsigned long freq;
	struct dev_pm_opp *opp;

	count = dev_pm_opp_get_opp_count(gpu->dev);
	if (count < 0)
		return count;

	dp->freq_table = kmalloc_array((size_t)count, sizeof(dp->freq_table[0]), GFP_KERNEL);
	if (!dp->freq_table)
		return -ENOMEM;

	for (i = 0, freq = ULONG_MAX; i < (unsigned int)count; i++, freq--) {
		opp = dev_pm_opp_find_freq_floor(gpu->dev, &freq);
		if (IS_ERR(opp))
			break;
		dev_pm_opp_put(opp);

		dp->freq_table[i] = freq;
	}
	if ((unsigned int)count != i)
		dev_warn(gpu->dev, "Unable to enumerate all OPPs (%d!=%u\n", count, i);

	dp->max_state = i;

	return 0;
}

static int yw_devfreq_target(struct device *dev, unsigned long *freq, u32 flags)
{
	struct yw_fake_gpu *gpu = dev_get_drvdata(dev);
	struct dev_pm_opp *opp;

	opp = devfreq_recommended_opp(dev, freq, flags);
	if (IS_ERR(opp))
		return PTR_ERR(opp);
	dev_pm_opp_put(opp);

	if (*freq == gpu->freq_limit)
		return 0;

	gpu->freq_limit = *freq;
	/* 此处需要把freq_limit传递给host, 作为最高频率限制 */

	return 0;
}

static int yw_devfreq_status(struct device *dev, struct devfreq_dev_status *stat)
{
	struct yw_fake_gpu *gpu = dev_get_drvdata(dev);

	/* 此处需要获取host负载, 令busy_time=负载, total_time固定100 */
	stat->busy_time = (stat->busy_time < 100 ? stat->busy_time + 1 : 0);
	stat->total_time = 100;
	/* 此处需要获取host频率, 令current_frequency=频率 */
	stat->current_frequency = gpu->freq_limit;
	stat->private_data = NULL;

	return 0;
}

static int yw_devfreq_cur_freq(struct device *dev, unsigned long *freq)
{
	struct yw_fake_gpu *gpu = dev_get_drvdata(dev);

	*freq = gpu->freq_limit;

	return 0;
}

static int devfreq_fake_gpu_governor_func(struct devfreq *df, unsigned long *freq)
{
	*freq = df->profile->freq_table[0];
	devfreq_update_stats(df);

	return 0;
}

static int devfreq_fake_gpu_governor_handler(struct devfreq *devfreq,
					unsigned int event, void *data)
{
	switch (event) {
	case DEVFREQ_GOV_START:
		devfreq_monitor_start(devfreq);
		break;

	case DEVFREQ_GOV_STOP:
		devfreq_monitor_stop(devfreq);
		break;

	case DEVFREQ_GOV_UPDATE_INTERVAL:
		devfreq_update_interval(devfreq, (unsigned int *)data);
		break;

	case DEVFREQ_GOV_SUSPEND:
		devfreq_monitor_suspend(devfreq);
		break;

	case DEVFREQ_GOV_RESUME:
		devfreq_monitor_resume(devfreq);
		break;

	default:
		break;
	}

	return 0;
}

static struct devfreq_governor devfreq_fake_gpu_governor = {
	.name = "fake_gpu_gov",
	.get_target_freq = devfreq_fake_gpu_governor_func,
	.event_handler = devfreq_fake_gpu_governor_handler,
};

static int fake_gpu_probe(struct platform_device *pdev)
{
	struct yw_fake_gpu *gpu;
	struct devfreq_dev_profile *dp;
	struct yw_opp *yw_opps;
	int ret;

	gpu = devm_kzalloc(&pdev->dev, sizeof(*gpu), GFP_KERNEL);
	if (!gpu)
		return -ENOMEM;

	gpu->dev = &pdev->dev;
	platform_set_drvdata(pdev, gpu);

	ret = yw_request_host_opp(&yw_opps);
	if (ret) {
		dev_err(gpu->dev, "Fail to request host opp.\n");
		return ret;
	}

	ret = dev_pm_opp_of_add_table(gpu->dev);
	if (ret) {
		dev_err(gpu->dev, "Invalid operating-points in device tree.\n");
		return ret;
	}

	ret = yw_fake_gpu_calibrate_opp(gpu, yw_opps);
	if (ret) {
		dev_err(gpu->dev, "Fail to calibrate opp.\n");
		return ret;
	}
	kfree(yw_opps);

	dp = &gpu->devfreq_profile;
	ret = yw_devfreq_init_freq_table(gpu, dp);
	if (ret) {
		dev_err(gpu->dev, "Fail to init devfreq freq_table.\n");
		return ret;
	}

	gpu->freq_limit = dp->freq_table[0];
	dp->initial_freq =  gpu->freq_limit;
	dp->polling_ms = 100;
	dp->target = yw_devfreq_target;
	dp->get_dev_status = yw_devfreq_status;
	dp->get_cur_freq = yw_devfreq_cur_freq;

	ret = devfreq_add_governor(&devfreq_fake_gpu_governor);
	if (ret) {
		dev_err(gpu->dev, "Fail to add governor(%d)", ret);
		return ret;
	}

	gpu->devfreq = devm_devfreq_add_device(gpu->dev, dp,
					       devfreq_fake_gpu_governor.name,
					       NULL);
	if (IS_ERR(gpu->devfreq)) {
		dev_err(gpu->dev, "Fail to add devfreq device(%d)", ret);
		return PTR_ERR(gpu->devfreq);
	}

	devfreq_update_stats(gpu->devfreq);
	ret = devfreq_register_opp_notifier(gpu->dev, gpu->devfreq);
	if (ret) {
		dev_err(gpu->dev, "Failed to register OPP notifier (%d)", ret);
		return ret;
	}
#if IS_ENABLED(CONFIG_DEVFREQ_THERMAL)
	of_property_read_u32(gpu->dev->of_node, "dynamic-power-coefficient",
			     (u32 *)&gpu->dfc_power.dyn_power_coeff);
	gpu->devfreq_cooling = of_devfreq_cooling_register_power(gpu->dev->of_node,
								 gpu->devfreq,
								 &gpu->dfc_power);
	if (IS_ERR(gpu->devfreq_cooling)) {
		dev_err(gpu->dev, "failed to register cooling device\n");
		return PTR_ERR(gpu->devfreq_cooling);
	}
#endif
	return 0;

}

static int fake_gpu_remove(struct platform_device *pdev)
{
	struct yw_fake_gpu *gpu = platform_get_drvdata(pdev);

	dev_pm_opp_unregister_notifier(gpu->dev, &gpu->devfreq->nb);
	kfree(gpu->devfreq_profile.freq_table);
	devfreq_cooling_unregister(gpu->devfreq_cooling);
	dev_info(gpu->dev, "Fake GPU removed\n");

	return 0;
}

static const struct of_device_id fake_gpu_of_match[] = {
	{ .compatible = "rockchip,fake-gpu" },
	{ /* end */ },
};
MODULE_DEVICE_TABLE(of, fake_gpu_of_match);

static struct platform_driver fake_gpu_driver = {
	.probe = fake_gpu_probe,
	.remove = fake_gpu_remove,
	.driver = {
		.name = "fake-gpu",
		.of_match_table = fake_gpu_of_match,
	},
};
module_platform_driver(fake_gpu_driver);

MODULE_AUTHOR("Ye Zhang");
MODULE_DESCRIPTION("Fake GPU Driver with devfreq and thermal cooling support");
MODULE_LICENSE("GPL v2");
