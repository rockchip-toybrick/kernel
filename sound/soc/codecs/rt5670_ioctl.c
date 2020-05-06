/*
 * rt5670_ioctl.h  --  RT5670 ALSA SoC audio driver IO control
 *
 * Copyright 2012 Realtek Microelectronics
 * Author: Bard <bardliao@realtek.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/spi/spi.h>
#include <sound/soc.h>
#include "rt_codec_ioctl.h"
#include "rt5670_ioctl.h"
#include "rt5670.h"
#include "rt5670-dsp.h"

hweq_t hweq_param[] = {
	{/* NORMAL */
		{
			{0, 0},
		},
		0x0000,
	},
	{/* SPK */
{
    {0xA4, 0x13E6},
    {0xA5, 0x0000},
    {0xEB, 0x0267},
    {0xEC, 0x4E40},
    {0xED, 0x1E99},
    {0xEE, 0xD391},
    {0xE7, 0x1E0A},
    {0xE8, 0x9389},
    {0xE9, 0x00C5},
    {0xEA, 0x1EC4},
    {0xE5, 0x0274},
    {0xE6, 0x48B8},
    {0xAE, 0xD588},
    {0xAF, 0x1C10},
    {0xB0, 0x0000},
    {0xB4, 0xE904},
    {0xB5, 0x1C10},
    {0xB6, 0x0000},
    {0xBA, 0x0000},
    {0xBB, 0x1C10},
    {0xBC, 0x0000},
    {0xC0, 0x0436},
    {0xC1, 0x0000},
    {0xC4, 0x1E85},
    {0xC5, 0x016A},
    {0xC6, 0x1E8D},
    {0xCA, 0x0402},
    {0xCC, 0x0800},

    {0xA6, 0x13E6},
    {0xA7, 0x0000},
    {0xF5, 0x0267},
    {0xF6, 0x4E40},
    {0xF7, 0x1E99},
    {0xF8, 0xD391},
    {0xF1, 0x1E0A},
    {0xF2, 0x9389},
    {0xF3, 0x00C5},
    {0xF4, 0x1EC4},
    {0xEF, 0x0274},
    {0xF0, 0x48B8},
    {0xB1, 0xD588},
    {0xB2, 0x1C10},
    {0xB3, 0x0000},
    {0xB7, 0xE904},
    {0xB8, 0x1C10},
    {0xB9, 0x0000},
    {0xBD, 0x0000},
    {0xBE, 0x1C10},
    {0xBF, 0x0000},
    {0xC2, 0x0436},
    {0xC3, 0x0000},
    {0xC7, 0x1E85},
    {0xC8, 0x016A},
    {0xC9, 0x1E8D},
    {0xCB, 0x0402},
    {0xCD, 0x0800},
},
0x30C2,
	},
	{/* HP */
		{
			{0, 0},
		},
		0x0000,
	},
};
#define RT5670_HWEQ_LEN ARRAY_SIZE(hweq_param)

int rt5670_update_eqmode(
	struct snd_soc_codec *codec, int channel, int mode)
{
	struct rt_codec_ops *ioctl_ops = rt_codec_get_ioctl_ops();
	int i, upd_reg, reg, mask;

	if(codec == NULL ||  mode >= RT5670_HWEQ_LEN)
		return -EINVAL;

	dev_dbg(codec->dev, "%s(): mode=%d\n", __func__, mode);

	for (i = 0; i < EQ_REG_NUM; i++) {
		if(hweq_param[mode].par[i].reg)
				ioctl_ops->index_write(codec,
					hweq_param[mode].par[i].reg,
					hweq_param[mode].par[i].val);
		else
			break;
	}
	switch (channel) {
	case EQ_CH_DAC:
		reg = RT5670_EQ_CTRL2;
		mask = 0x33fe;
		upd_reg = RT5670_EQ_CTRL1;
		break;
	case EQ_CH_ADC:
		reg = RT5670_ADC_EQ_CTRL2;
		mask = 0x01bf;
		upd_reg = RT5670_ADC_EQ_CTRL1;
			break;
	default:
		printk("Invalid EQ channel\n");
		return -EINVAL;
	}
	snd_soc_update_bits(codec, reg, mask, hweq_param[mode].ctrl);
	snd_soc_update_bits(codec, upd_reg,
		RT5670_EQ_UPD, RT5670_EQ_UPD);
	snd_soc_update_bits(codec, upd_reg, RT5670_EQ_UPD, 0);

	return 0;
}

int rt5670_ioctl_common(struct snd_hwdep *hw, struct file *file,
			unsigned int cmd, unsigned long arg)
{
	struct snd_soc_codec *codec = hw->private_data;
	struct rt_codec_cmd __user *_rt_codec = (struct rt_codec_cmd *)arg;
	struct rt_codec_cmd rt_codec;
	int *buf;
	static int eq_mode[EQ_CH_NUM];

	if (copy_from_user(&rt_codec, _rt_codec, sizeof(rt_codec))) {
		dev_err(codec->dev,"copy_from_user faild\n");
		return -EFAULT;
	}
	dev_dbg(codec->dev, "%s(): rt_codec.number=%d, cmd=%d\n",
			__func__, (int)rt_codec.number,(int)cmd);
	buf = kmalloc(sizeof(*buf) * rt_codec.number, GFP_KERNEL);
	if (buf == NULL)
		return -ENOMEM;
	if (copy_from_user(buf, rt_codec.buf,
		sizeof(*buf) * rt_codec.number))
		goto err;

	switch (cmd) {
	case RT_SET_CODEC_HWEQ_IOCTL:
		if (*buf >= EQ_CH_NUM)
			break;
		if (eq_mode[*buf] == *(buf + 1))
			break;
		eq_mode[*buf] = *(buf + 1);
		rt5670_update_eqmode(codec, eq_mode[*buf], *buf);
		break;

	case RT_GET_CODEC_ID:
		*buf = snd_soc_read(codec, RT5670_VENDOR_ID2);
		if (copy_to_user(rt_codec.buf, buf,
			sizeof(*buf) * rt_codec.number))
			goto err;
		break;
	case RT_READ_CODEC_DSP_IOCTL:
	case RT_WRITE_CODEC_DSP_IOCTL:
	case RT_GET_CODEC_DSP_MODE_IOCTL:
		return rt5670_dsp_ioctl_common(hw, file, cmd, arg);
		break;
	default:
		break;
	}

	kfree(buf);
	return 0;

err:
	kfree(buf);
	return -EFAULT;
}
EXPORT_SYMBOL_GPL(rt5670_ioctl_common);
