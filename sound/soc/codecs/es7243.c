#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/i2c.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/of_device.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <sound/soc.h>
#include <linux/clk.h>
#include "es7243.h"

struct es7243_reg {
	u8 reg_index;
	u8 reg_value;
};

static struct snd_soc_codec *es7243_codec;
struct es7243_priv {
	struct clk *mclk;
};

static int count = 0;
struct i2c_client *es7243_i2c_client[4];
struct i2c_client *es724310_i2c_client;
static struct es7243_reg init_mode[] = {
	/* slave mode, software mode */
	{ES7243_MODECFG_REG00, 0x01},
};

#define ES7243_INIT_NUM ARRAY_SIZE(init_mode)

/* The Sequence for Startup – slave mode */
static struct es7243_reg startup_mode[] = {
	{ES7243_STATECTL_REG06, 0x18},
	{ES7243_SDPFMT_REG01, 0x0c},
	{ES7243_LRCDIV_REG02, 0x10},
	{ES7243_BCKDIV_REG03, 0x04},
	{ES7243_CLKDIV_REG04, 0x02},
	{ES7243_MUTECTL_REG05, 0x1A},
	{ES7243_ANACTL1_REG08, 0x43},//0x11
	{ES7243_ANACTL0_REG07, 0x80},
	{ES7243_ANACTL2_REG09, 0x00},
	{ES7243_STMOSR_REG0D, 0xa0},
	{ES7243_STATECTL_REG06, 0x00},
	{ES7243_MUTECTL_REG05, 0x13},

};
#define ES7243_STARTUP_NUM ARRAY_SIZE(startup_mode)

/* The sequence for Standby mode  */
static struct es7243_reg standby_mode[] = {
	{ES7243_STATECTL_REG06, 0x05},
	/* Mute ADC  */
	{ES7243_MUTECTL_REG05, 0x1B},
	{ES7243_STATECTL_REG06, 0x5C},
	/* {ES7243_ANACTL0_REG07, 0x3F}, */
	/* {ES7243_ANACTL1_REG08, 0x4B}, */
	{ES7243_ANACTL2_REG09, 0x9F},
};
#define ES7243_STANDBY_NUM ARRAY_SIZE(standby_mode)

static int es7243_i2c_write(struct i2c_client *client, u8 reg, u8 value)
{
	u8 data[2];

	data[0] = reg;
	data[1] = value;

	if (i2c_master_send(client, data, 2) == 2)
		return 0;
	else
		return -EIO;
}

static int es7243_i2c_read(struct i2c_client *client, u8 reg)
{
	struct i2c_msg xfer[2];
	u8 data;
	int ret;

	/* Write register */
	xfer[0].addr = client->addr;
	xfer[0].flags = 0;
	xfer[0].len = 1;
	xfer[0].buf = &reg;
	/* Read data */
	xfer[1].addr = client->addr;
	xfer[1].flags = I2C_M_RD;
	xfer[1].len = 2;
	xfer[1].buf = (u8 *)&data;

	ret = i2c_transfer(client->adapter, xfer, 2);
	if (ret != 2) {
		dev_err(&client->dev, "i2c_transfer() returned %d\n", ret);
		return 0;
	}

	return data;
}
int es7243_init_mode(struct i2c_client *client)
{
	int i = 0;
	int err = 0;
	printk("%s\n", __func__);
	for(i = 0; i < ES7243_INIT_NUM; i++) {
		err = es7243_i2c_write(client, init_mode[i].reg_index,
				init_mode[i].reg_value);
		if(err != 0 )
			dev_err(&client->dev, "i2c write 0x%0x failed\n",
					init_mode[i].reg_index);
	}
	return err;
}

int es7243_startup(struct i2c_client *client)
{
	int i = 0;
	int err = 0;
	printk("%s\n", __func__);
	for(i = 0; i < ES7243_STARTUP_NUM; i++) {
		err = es7243_i2c_write(client, startup_mode[i].reg_index,
				startup_mode[i].reg_value);
		if(err != 0 )
			dev_err(&client->dev, "i2c write 0x%0x failed\n",
					startup_mode[i].reg_index);
	}
	for(i = 0; i < 0xf; i++)
		dev_info(&client->dev, "0x%0x -- 0x%0x\n",
			 i, es7243_i2c_read(client, i));
	return 0;
}

int es7243_start(void)
{
	int i = 0;
	for(i = 0; i < count; i++)
		es7243_startup(es7243_i2c_client[i]);
	return 0;
}

EXPORT_SYMBOL(es7243_start);

int es7243_init(void)
{
	int i = 0;
	for(i = 0; i < count; i++)
		es7243_init_mode(es7243_i2c_client[i]);
	return 0;
}

EXPORT_SYMBOL(es7243_init);

int es7243_set_standby(struct i2c_client *client)
{
	int i = 0;
	int err = 0;
	printk("%s\n", __func__);
	for(i = 0; i < ES7243_STANDBY_NUM; i++) {
		err = es7243_i2c_write(client, standby_mode[i].reg_index,
				standby_mode[i].reg_value);
		if(err != 0 )
			dev_err(&client->dev, "i2c write 0x%0x failed\n",
					standby_mode[i].reg_index);
	}
	for(i = 0; i < 0xf; i++)
		dev_info(&client->dev, "0x%0x -- 0x%0x\n",
			 i, es7243_i2c_read(client, i));
	return 0;
}

int es7243_standby(void)
{
	int i = 0;
	for(i = 0; i < count; i++)
		es7243_set_standby(es7243_i2c_client[i]);
	return 0;
}
EXPORT_SYMBOL(es7243_standby);
static const struct snd_soc_dapm_widget es7243_widgets[] = {
		SND_SOC_DAPM_INPUT("RX"),
		SND_SOC_DAPM_OUTPUT("TX"),
};

static const struct snd_soc_dapm_route es7243_routes[] = {
	{ "Capture", NULL, "RX" },
	{ "TX", NULL, "Playback" },
};

static int es7243_dai_startup(struct snd_pcm_substream *substream,
		struct snd_soc_dai *dai){
	bool playback = (substream->stream == SNDRV_PCM_STREAM_PLAYBACK);
	if(!playback){
		es7243_start();
	}
	return 0;

}

static void es7243_dai_shutdown(struct snd_pcm_substream *substream,
		struct snd_soc_dai *dai){
	bool playback = (substream->stream == SNDRV_PCM_STREAM_PLAYBACK);
	if(!playback){
		es7243_standby();
	}
}

static const struct snd_soc_dai_ops es7243_dai_ops = {
	.startup   = es7243_dai_startup,
	.shutdown  = es7243_dai_shutdown,
};

static struct snd_soc_dai_driver es7243_dai = {
	.name = "es7243-mic-array",
	.capture = {
		.stream_name = "Capture",
		.channels_min = 2,
		.channels_max = 8,
		.rates = SNDRV_PCM_RATE_8000_96000,
		.formats = SNDRV_PCM_FMTBIT_S16_LE,
	},
	.ops = &es7243_dai_ops,
};



static const struct of_device_id of_es7243_match[] = {
	{ .compatible = "everest,es7243"},
	{},
};

MODULE_DEVICE_TABLE(of, of_es7243_match);

static int es7243_probe(struct snd_soc_codec *codec)
{
	struct es7243_priv *es7243 = snd_soc_codec_get_drvdata(codec);
	int ret = 0;
	es7243_codec = codec;
	printk("%s\n", __func__);
	es7243->mclk = devm_clk_get(codec->dev, "mclk");
	if (PTR_ERR(es7243->mclk) == -EPROBE_DEFER)
		return -EPROBE_DEFER;

	ret = clk_prepare_enable(es7243->mclk);
	if (ret)
		return ret;
	es7243_init();
	printk(" %s sucess!\n", __func__);
	return 0;

}

static int es7243_remove(struct snd_soc_codec *codec)
{
	return 0;
}

static int es7243_i2c_remove(struct i2c_client *client)
{
	snd_soc_unregister_codec(&client->dev);
	return 0;
}

static struct snd_soc_codec_driver soc_codec_dev_es7243 = {
	.probe =	es7243_probe,
	.remove =	es7243_remove,
	.dapm_widgets = es7243_widgets,
	.num_dapm_widgets = ARRAY_SIZE(es7243_widgets),
	.dapm_routes = es7243_routes,
	.num_dapm_routes = ARRAY_SIZE(es7243_routes),
};

static int es7243_i2c_probe(struct i2c_client *client,
		const struct i2c_device_id *id)
{
	const struct of_device_id *match;
	struct device *dev = &client->dev;
	int ret = 0;
	struct es7243_priv *es7243;

	es7243 = devm_kzalloc(&client->dev, sizeof(*es7243), GFP_KERNEL);
	if (!es7243)
		return -ENOMEM;
	i2c_set_clientdata(client, es7243);

	printk("%s\n", __func__);
	if (dev->of_node) {
		match = of_match_device(of_es7243_match, dev);
		if (!match) {
			dev_err(dev, "Failed to find matching dt id\n");
			return -EINVAL;
		}
	}
	es7243_i2c_client[count] = client;
	count++;
	ret = snd_soc_register_codec(&client->dev,
			&soc_codec_dev_es7243,
			&es7243_dai, 1);
	return ret;
}

static const struct i2c_device_id es7243_id[] = {
	{"es7243"},
	{}
};

MODULE_DEVICE_TABLE(i2c, es7243_id);

static struct i2c_driver es7243_driver = {
	.driver         = {
		.name   = "es7243",
		.of_match_table = of_es7243_match,
	},
	.probe          = es7243_i2c_probe,
	.remove         = es7243_i2c_remove,
	.id_table       = es7243_id,
};


static int __init es7243_driver_init(void)
{
	    return i2c_add_driver(&es7243_driver);
}
late_initcall_sync(es7243_driver_init);
static void __exit es7243_driver_exit(void)
{
	    return i2c_del_driver(&es7243_driver);
}
module_exit(es7243_driver_exit);


MODULE_AUTHOR("Xiaotan Luo <lxt@rock-chips.com>");
MODULE_DESCRIPTION("ES7243 I2C Codec Driver");
MODULE_LICENSE("GPL v2");
