/*
 * rk29_sph0645lm4h.c  --  SoC audio for rockchip
 *
 * Driver for rockchip msm261s4030h0 audio  
 *
 *  This program is free software; you can redistribute  it and/or modify it
 *  under  the terms of  the GNU General  Public License as published by the
 *  Free Software Foundation;  either version 2 of the  License, or (at your
 *  option) any later version.
 *
 *
 */

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/gpio.h>
#include <linux/of_gpio.h>
#include <linux/delay.h>
#include <sound/core.h>
#include <sound/jack.h>
#include <sound/pcm.h>
#include <sound/pcm_params.h>
#include <sound/soc.h>

#include "rockchip_i2s.h"

#ifdef CONFIG_MACH_RK_FAC
#include <plat/config.h>
extern int codec_type;
#endif

#if 1
#define	DBG(x...)	printk(KERN_INFO x)
#else
#define	DBG(x...)
#endif


static int rk3399_hw_params(struct snd_pcm_substream *substream,
	struct snd_pcm_hw_params *params)
{
	struct snd_soc_pcm_runtime *rtd = substream->private_data;
	struct snd_soc_dai *cpu_dai = rtd->cpu_dai;
	struct snd_soc_dai *codec_dai = rtd->codec_dai;
	int mclk, ret;

	/* in bypass mode, the mclk has to be one of the frequencies below */
	switch (params_rate(params)) {
	case 8000:
	case 16000:
	case 24000:
	case 32000:
	case 48000:
	case 64000:
	case 96000:
		mclk = 12288000;
		break;
	case 11025:
	case 22050:
	case 44100:
	case 88200:
		mclk = 11289600;
		break;
	default:
		return -EINVAL;
	}

	ret = snd_soc_dai_set_sysclk(cpu_dai, 0, mclk, SND_SOC_CLOCK_OUT);
	if (ret < 0) {
		dev_err(codec_dai->dev, "Can't set cpu clock out %d\n", ret);
		return ret;
	}

	return 0;
}

/*
 * Logic for a msm261s4030h0 as connected on a rockchip board.
 */
static int rk3399_msm261s4030h0_init(struct snd_soc_pcm_runtime *rtd)
{
    return 0;
}

static struct snd_soc_ops rk29_ops = {
	  .hw_params = rk3399_hw_params,
};

static struct snd_soc_dai_link rk29_dai = {
	.name = "msm261s4030h0",
	.stream_name = "msm261s4030h0 PCM",
	.codec_dai_name = "rockchip-msm261s4030h0-card-hifi",
	.init = rk3399_msm261s4030h0_init,
	.ops = &rk29_ops,
};

static struct snd_soc_card rockchip_msm261s4030h0_snd_card = {
	.name = "RK_msm261s4030h0",
	.dai_link = &rk29_dai,
	.num_links = 1,
};

static int rockchip_msm261s4030h0_audio_probe(struct platform_device *pdev)
{
	int ret;
	struct device_node *cpu_node;
	
	struct snd_soc_card *card = &rockchip_msm261s4030h0_snd_card;
    printk("csq00 %s---------------%d\n", __func__,__LINE__);
	card->dev = &pdev->dev;

	cpu_node = of_parse_phandle(pdev->dev.of_node, "rockchip,cpu", 0);
	if (!cpu_node) {
		dev_err(&pdev->dev,"Property 'rockchip,cpu' failed\n");
		return -EINVAL;
	}


	rk29_dai.platform_of_node = cpu_node;
	rk29_dai.cpu_of_node = cpu_node;

	rk29_dai.codec_of_node = of_parse_phandle(pdev->dev.of_node,"rockchip,codec",0);
	if (!rk29_dai.codec_of_node) {
		dev_err(&pdev->dev,"RK_msm261s4030h0 failed\n");
		return -EINVAL;
	}

	card->dev = &pdev->dev;
	platform_set_drvdata(pdev, card);

	ret = devm_snd_soc_register_card(&pdev->dev, card);
	if (ret)
		dev_err(&pdev->dev, "%s register card failed %d\n",
			__func__, ret);

	dev_info(&pdev->dev, "snd_soc_register_card successful\n");
	return ret;
}

static int rockchip_msm261s4030h0_audio_remove(struct platform_device *pdev)
{
	struct snd_soc_card *card = platform_get_drvdata(pdev);

	snd_soc_unregister_card(card);

	return 0;
}

#ifdef CONFIG_OF
static const struct of_device_id rockchip_msm261s4030h0_of_match[] = {
	{ .compatible = "rockchip-msm261s4030h0", },
	{},
};
MODULE_DEVICE_TABLE(of, rockchip_msm261s4030h0_of_match);
#endif /* CONFIG_OF */

static struct platform_driver rockchip_msm261s4030h0_audio_driver = {
	.driver         = {
		.name   = "rockchip-msm261s4030h0",
		.owner  = THIS_MODULE,
		.pm = &snd_soc_pm_ops,
		.of_match_table = of_match_ptr(rockchip_msm261s4030h0_of_match),
	},
	.probe          = rockchip_msm261s4030h0_audio_probe,
	.remove         = rockchip_msm261s4030h0_audio_remove,
};

static __init int rockchip_msm261s4030h0_modinit(void)
{
	return platform_driver_register(&rockchip_msm261s4030h0_audio_driver);
}

late_initcall(rockchip_msm261s4030h0_modinit);

static __exit void rockchip_msm261s4030h0_exit(void)
{
	platform_driver_unregister(&rockchip_msm261s4030h0_audio_driver);
}

module_exit(rockchip_msm261s4030h0_exit);
MODULE_DESCRIPTION("ROCKCHIP i2s ASoC Interface");
MODULE_AUTHOR("Shiqin chen <chensq@rock-chips.com>");
MODULE_LICENSE("GPL v2");
