/*
 * rk_pcm_codec.c  --  Rockchip PCM codecs driver
 *
 * Copyright (c) 2016, ROCKCHIP CORPORATION.  All rights reserved.
 * Author: Xiaotan Luo <lxt@rock-chips.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/slab.h>
#include <linux/of.h>
#include <linux/of_gpio.h>
#include <sound/soc.h>
#include <sound/pcm.h>
#include <sound/initval.h>

#if 1
#define DBG(x...) printk(KERN_INFO "rk_pcm_codec :"x)
#else
#define DBG(x...) do { } while (0)
#endif
#define FORMATS (SNDRV_PCM_FMTBIT_S16_LE | SNDRV_PCM_FMTBIT_S20_3LE |\
	SNDRV_PCM_FMTBIT_S24_LE)
struct snd_soc_dai_driver msm261s4030h0_card_dai = {
	.name = "rockchip-msm261s4030h0-card-hifi",	
	.capture = {
		.stream_name = "HiFi Capture",
		.channels_min = 2,
		.channels_max = 8,
		.rates = (
			SNDRV_PCM_RATE_8000|
			SNDRV_PCM_RATE_16000|
			SNDRV_PCM_RATE_32000 |
			SNDRV_PCM_RATE_44100 |
			SNDRV_PCM_RATE_48000 |
			SNDRV_PCM_RATE_96000 |
			SNDRV_PCM_RATE_192000),
		.formats = FORMATS,
	},

};

static struct snd_soc_codec_driver soc_codec_dev_msm261s4030h0_card;

static int rockchip_msm261s4030h0_card_audio_probe(struct platform_device *pdev)
{
	int ret;

	//set dev name to driver->name for sound card register
	printk("%s,%s\n",__FILE__,__FUNCTION__);
	dev_set_name(&pdev->dev, "%s", pdev->dev.driver->name);

	ret = snd_soc_register_codec(&pdev->dev,
		&soc_codec_dev_msm261s4030h0_card,
		&msm261s4030h0_card_dai, 1);

	if (ret)
		printk("%s() register card failed:%d\n", __FUNCTION__, ret);
	printk("---------------------rockchip_pcm_card_audio_probe-------------------\n");
	return ret;
}

static int rockchip_msm261s4030h0_card_audio_remove(struct platform_device *pdev)
{
	snd_soc_unregister_codec(&pdev->dev);
	return 0;
}

#ifdef CONFIG_OF
static const struct of_device_id rockchip_msm261s4030h0_card_of_match[] = {
        { .compatible = "rockchip-msm261s4030h0-codec", },
        {},
};
MODULE_DEVICE_TABLE(of, rockchip_msm261s4030h0_card_of_match);
#endif /* CONFIG_OF */

static struct platform_driver rockchip_msm261s4030h0_card_audio_driver = {
        .driver         = {
                .name   = "rockchip-msm261s4030h0-codec",
                .owner  = THIS_MODULE,
                .of_match_table = of_match_ptr(rockchip_msm261s4030h0_card_of_match),
        },
        .probe          = rockchip_msm261s4030h0_card_audio_probe,
        .remove         = rockchip_msm261s4030h0_card_audio_remove,
};

static __init int rk3399_msm261s4030h0_modinit(void)
{
	return platform_driver_register(&rockchip_msm261s4030h0_card_audio_driver);
}

late_initcall(rk3399_msm261s4030h0_modinit);

static __exit void rk3399_msm261s4030h0_exit(void)
{
	platform_driver_unregister(&rockchip_msm261s4030h0_card_audio_driver);
}

module_exit(rk3399_msm261s4030h0_exit);
MODULE_DESCRIPTION("ASoC Rockchip PCM codec driver");
MODULE_AUTHOR("Shiqin chen <chensq@rock-chips.com>");
MODULE_LICENSE("GPL v2");
