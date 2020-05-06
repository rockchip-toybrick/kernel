/*
 * rk29_rt5670.c  --  SoC audio for rockchip
 *
 * Driver for rockchip rt5670 audio
 *
 *  This program is free software; you can redistribute  it and/or modify it
 *  under  the terms of  the GNU General  Public License as published by the
 *  Free Software Foundation;  either version 2 of the  License, or (at your
 *  option) any later version.
 *
 *
 */

#include <linux/module.h>
#include <linux/device.h>
#include <sound/core.h>
#include <sound/pcm.h>
#include <sound/soc.h>
#include <sound/soc-dapm.h>
#include <asm/io.h>
#include <linux/of.h>
#include <linux/of_gpio.h>

#include "../codecs/rt5670.h"
#include "card_info.h"
//#include "rk_pcm.h"
#include "rockchip_i2s.h"


#if 1
#define	DBG(x...)	printk(KERN_INFO x)
#else
#define	DBG(x...)
#endif

static int rockchip_rt5670_hifi_hw_params(struct snd_pcm_substream *substream,
	struct snd_pcm_hw_params *params)
{
	struct snd_soc_pcm_runtime *rtd = substream->private_data;
	struct snd_soc_dai *codec_dai = rtd->codec_dai;
	struct snd_soc_dai *cpu_dai = rtd->cpu_dai;
	unsigned int pll_out = 0, dai_fmt = rtd->dai_link->dai_fmt;
	int ret;

	DBG("Enter::%s----%d\n", __FUNCTION__, __LINE__);
   //printk("rockchip_rt5670_hifi_hw_params dai_fmt=%d\n",dai_fmt);
	/* set codec DAI configuration */
	ret = snd_soc_dai_set_fmt(codec_dai, dai_fmt);
	if (ret < 0) {
		printk("%s():failed to set the format for codec side\n", __FUNCTION__);
		return ret;
	}

	/* set cpu DAI configuration */
	ret = snd_soc_dai_set_fmt(cpu_dai, dai_fmt);
	if (ret < 0) {
		printk("%s():failed to set the format for cpu side\n", __FUNCTION__);
		return ret;
	}

	switch(params_rate(params)) {
		case 8000:
		case 16000:
		case 24000:
		case 32000:
		case 48000:
			pll_out = 12288000;
			break;
		case 11025:
		case 22050:
		case 44100:
			pll_out = 11289600;
			break;
		default:
			DBG("Enter:%s, %d, Error rate=%d\n", __FUNCTION__, __LINE__, params_rate(params));
			return -EINVAL;
			break;
	}

	DBG("Enter:%s, %d, rate=%d\n", __FUNCTION__, __LINE__, params_rate(params));

	/*Set the system clk for codec*/
/*	//snd_soc_dai_set_pll(codec_dai, 0, RT5670_PLL1_S_MCLK, pll_out, pll_out*2); //bard 8-29
	//ret = snd_soc_dai_set_sysclk(codec_dai, RT5670_SCLK_S_PLL1, pll_out*2, SND_SOC_CLOCK_IN); //bard 8-29
	snd_soc_dai_set_pll(codec_dai, 0, RT5670_PLL1_S_MCLK, pll_out, pll_out); 
//	ret = snd_soc_dai_set_sysclk(codec_dai, RT5670_SCLK_S_PLL1, pll_out, SND_SOC_CLOCK_IN); 
	ret = snd_soc_dai_set_sysclk(codec_dai, RT5670_SCLK_S_MCLK, pll_out, SND_SOC_CLOCK_IN); 
	if (ret < 0)
	{
		DBG("rk29_hw_params_rt5670:failed to set the sysclk for codec side\n"); 
		return ret;
	}
	
	snd_soc_dai_set_sysclk(cpu_dai, 0, pll_out, 0);
	snd_soc_dai_set_clkdiv(cpu_dai, ROCKCHIP_DIV_BCLK, (pll_out/4)/params_rate(params)-1);
	snd_soc_dai_set_clkdiv(cpu_dai, ROCKCHIP_DIV_MCLK, 3);// 256k = 48-1  3M=3

	DBG("Enter:%s, %d, pll_out/4/params_rate(params) = %d \n", __FUNCTION__, __LINE__, (pll_out/4)/params_rate(params));
	return 0;
*/
	ret = snd_soc_dai_set_sysclk(cpu_dai, 0, pll_out,
						 SND_SOC_CLOCK_OUT);
	if (ret < 0) {
		dev_err(codec_dai->dev, "Can't set codec clock %d\n", ret);
		return ret;
	}
	
	ret = snd_soc_dai_set_sysclk(codec_dai, 0, pll_out,
						 SND_SOC_CLOCK_IN);
	if (ret < 0) {
		dev_err(codec_dai->dev, "Can't set codec clock %d\n", ret);
		return ret;
	}

	return ret;
	
}

static int rockchip_rt5670_voice_hw_params(struct snd_pcm_substream *substream,
	struct snd_pcm_hw_params *params)
{
	struct snd_soc_pcm_runtime *rtd = substream->private_data;
	struct snd_soc_dai *codec_dai = rtd->codec_dai;
	struct snd_soc_dai *cpu_dai = rtd->cpu_dai;
	unsigned int pll_out = 0, dai_fmt = rtd->dai_link->dai_fmt;
	int ret;

	DBG("Enter::%s----%d\n", __FUNCTION__, __LINE__);

	/* set codec DAI configuration */
	ret = snd_soc_dai_set_fmt(codec_dai, dai_fmt);
	if (ret < 0) {
		printk("%s():failed to set the format for codec side\n", __FUNCTION__);
		return ret;
	}

	switch(params_rate(params)) {
		case 8000:
		case 16000:
		case 24000:
		case 32000:
		case 48000:
			pll_out = 12288000;
			break;
		case 11025:
		case 22050:
		case 44100:
			pll_out = 11289600;
			break;
		default:
			DBG("Enter:%s, %d, Error rate=%d\n", __FUNCTION__, __LINE__, params_rate(params));
			return -EINVAL;
			break;
	}

	DBG("Enter:%s, %d, rate=%d\n", __FUNCTION__, __LINE__, params_rate(params));

	/*Set the system clk for codec*/
	//snd_soc_dai_set_pll(codec_dai, 0, RT5670_PLL1_S_MCLK, pll_out, 512*8000); //bard 8-29
	//ret = snd_soc_dai_set_sysclk(codec_dai, RT5670_SCLK_S_PLL1, 512*8000, SND_SOC_CLOCK_IN); //bard 8-29
	snd_soc_dai_set_pll(codec_dai, 0, RT5670_PLL1_S_MCLK, pll_out, 12288000); //bard 8-29zzf
    	ret = snd_soc_dai_set_sysclk(codec_dai, RT5670_SCLK_S_PLL1, 12288000, SND_SOC_CLOCK_IN); //bard 8-29
	//snd_soc_dai_set_pll(codec_dai, 0, RT5670_PLL1_S_MCLK, pll_out, 24576000); //bard 8-29 zzf
    	//ret = snd_soc_dai_set_sysclk(codec_dai, RT5670_SCLK_S_PLL1, 24576000, SND_SOC_CLOCK_IN); //bard 8-29


	if (ret < 0) {
		printk("rk29_hw_params_rt5670:failed to set the sysclk for codec side\n"); 
		return ret;
	}

	snd_soc_dai_set_sysclk(cpu_dai, 0, pll_out, 0);
	//snd_soc_dai_set_clkdiv(cpu_dai, ROCKCHIP_DIV_BCLK, (pll_out/4)/params_rate(params)-1);
	//snd_soc_dai_set_clkdiv(cpu_dai, ROCKCHIP_DIV_MCLK, 3);

	DBG("Enter:%s, %d, pll_out/4/params_rate(params) = %d \n", __FUNCTION__, __LINE__, (pll_out/4)/params_rate(params));
 
	return 0;
}

static const struct snd_soc_dapm_widget rockchip_rt5670_dapm_widgets[] = {
	SND_SOC_DAPM_MIC("Mic Jack", NULL),
	SND_SOC_DAPM_MIC("Headset Jack", NULL),	
	SND_SOC_DAPM_SPK("Ext Spk", NULL),
	SND_SOC_DAPM_HP("Headphone Jack", NULL),
};

static const struct snd_soc_dapm_route audio_map[]={

	/* Mic Jack --> MIC_IN*/
	/*{"micbias2", NULL, "Mic Jack"},
	{"IN2P", NULL, "micbias2"},
	
	// HP MIC
	{"micbias2", NULL, "Headset Jack"},
    {"IN1P", NULL, "micbias2"},

	{"Ext Spk", NULL, "SPOL"},
	{"Ext Spk", NULL, "SPOR"},
	{"Headphone Jack", NULL, "HPOL"},
	{"Headphone Jack", NULL, "HPOR"},*/
} ;

static const struct snd_kcontrol_new rockchip_rt5670_controls[] = {
	SOC_DAPM_PIN_SWITCH("Mic Jack"),
	SOC_DAPM_PIN_SWITCH("Headset Jack"),
	SOC_DAPM_PIN_SWITCH("Ext Spk"),
	SOC_DAPM_PIN_SWITCH("Headphone Jack"),
};

/*
 * Logic for a rt5670 as connected on a rockchip board.
 */
static int rockchip_rt5670_init(struct snd_soc_pcm_runtime *rtd)
{
	//struct snd_soc_codec *codec = rtd->codec;
	//struct snd_soc_dapm_context *dapm = &codec->dapm;

	DBG("Enter::%s----%d\n",__FUNCTION__,__LINE__);

	/*mutex_lock(&dapm->card->dapm_mutex);

	snd_soc_dapm_enable_pin(dapm, "Mic Jack");
	snd_soc_dapm_enable_pin(dapm, "Headset Jack");
	snd_soc_dapm_enable_pin(dapm, "Ext Spk");
	snd_soc_dapm_enable_pin(dapm, "Headphone Jack");

	mutex_unlock(&dapm->card->dapm_mutex);

	snd_soc_dapm_sync(dapm);*/

	return 0;
}

static struct snd_soc_ops rockchip_rt5670_hifi_ops = {
	.hw_params = rockchip_rt5670_hifi_hw_params,
};

static struct snd_soc_ops rockchip_rt5670_voice_ops = {
	.hw_params = rockchip_rt5670_voice_hw_params,
};

static struct snd_soc_dai_link rockchip_rt5670_dai[] = {
	{
		.name = "RT5670 I2S1",
		.stream_name = "RT5670 PCM1",
		.codec_dai_name = "rt5670-aif1",
		.init = rockchip_rt5670_init,
		.ops = &rockchip_rt5670_hifi_ops,
	},
	{
		.name = "RT5670 I2S2",
		.stream_name = "RT5670 PCM2",
		.codec_dai_name = "rt5670-aif2",
		.ops = &rockchip_rt5670_voice_ops,
	},
};

static struct snd_soc_card rockchip_rt5670_snd_card = {
	.name = "RK_RT5670",
	.dai_link = rockchip_rt5670_dai,
	.num_links = 2,
	.controls = rockchip_rt5670_controls,
	.num_controls = ARRAY_SIZE(rockchip_rt5670_controls),
	.dapm_widgets    = rockchip_rt5670_dapm_widgets,
	.num_dapm_widgets = ARRAY_SIZE(rockchip_rt5670_dapm_widgets),
	.dapm_routes    = audio_map,
	.num_dapm_routes = ARRAY_SIZE(audio_map),
};

static int rockchip_rt5670_audio_probe(struct platform_device *pdev)
{
	int ret;
	struct snd_soc_card *card = &rockchip_rt5670_snd_card;

	printk("dbg: rt5670_audio_probe");
	
	card->dev = &pdev->dev;

	ret = rockchip_of_get_sound_card_info(card);
	if (ret) {
		printk("%s() get sound card info failed:%d\n", __FUNCTION__, ret);
		return ret;
	}

	ret = snd_soc_register_card(card);
	if (ret)
		printk("%s() register card failed:%d\n", __FUNCTION__, ret);
        else
                printk("*** %s() register card OK:%d\n", __FUNCTION__, ret);
	return ret;
}

static int rockchip_rt5670_audio_remove(struct platform_device *pdev)
{
	struct snd_soc_card *card = platform_get_drvdata(pdev);

	snd_soc_unregister_card(card);

	return 0;
}

#ifdef CONFIG_OF
static const struct of_device_id rockchip_rt5670_of_match[] = {
	{ .compatible = "rockchip-rt5670", },
	{},
};
MODULE_DEVICE_TABLE(of, rockchip_rt5670_of_match);
#endif /* CONFIG_OF */

static struct platform_driver rockchip_rt5670_audio_driver = {
	.driver         = {
		.name   = "rockchip-rt5670",
		.owner  = THIS_MODULE,
		.pm = &snd_soc_pm_ops,
		.of_match_table = of_match_ptr(rockchip_rt5670_of_match),
	},
	.probe          = rockchip_rt5670_audio_probe,
	.remove         = rockchip_rt5670_audio_remove,
};

module_platform_driver(rockchip_rt5670_audio_driver);

/* Module information */
MODULE_AUTHOR("rockchip");
MODULE_DESCRIPTION("ROCKCHIP i2s ASoC Interface");
MODULE_LICENSE("GPL");
