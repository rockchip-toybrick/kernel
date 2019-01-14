#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/i2c.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/of_device.h>

#include "es7243.h"

struct es7243_reg {
	u8 reg_index;
	u8 reg_value;
};

static int count = 0;
struct i2c_client *es7243_i2c_client[4];

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
	//xfer[0].scl_rate = 100 * 1000;// csqerr

	/* Read data */
	xfer[1].addr = client->addr;
	xfer[1].flags = I2C_M_RD;
	xfer[1].len = 2;
	xfer[1].buf = (u8 *)&data;
	//xfer[1].scl_rate = 100 * 1000;// csqerr

	ret = i2c_transfer(client->adapter, xfer, 2);
	if (ret != 2) {
		printk(KERN_DEBUG "%s:i2c_transfer() returned %d\n",__FUNCTION__,ret);
		return 0;
	}

	return data;
}

static struct es7243_reg init_mode[] = {
	/* slave mode, software mode */
	{ES7243_MODECFG_REG00, 0x41},
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
	{ES7243_ANACTL1_REG08, 0x43},//0x11},
	{ES7243_ANACTL0_REG07, 0x80},
	{ES7243_ANACTL2_REG09, 0x00},
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

int es7243_init_mode(struct i2c_client *client)
{
	int i = 0;
	int err = 0;
	for(i = 0; i < ES7243_INIT_NUM; i++) {
		err = es7243_i2c_write(client, init_mode[i].reg_index,
				init_mode[i].reg_value);
		if(err != 0 ) {
			printk(KERN_DEBUG "%s:i2c write 0x%0x failed\n",__FUNCTION__,init_mode[i].reg_index);
			//return err;
		}
	}
	return err;
}

int es7243_startup(struct i2c_client *client)
{
	int i = 0;
	int err = 0;
	for(i = 0; i < ES7243_STARTUP_NUM; i++) {
		err = es7243_i2c_write(client, startup_mode[i].reg_index,
				startup_mode[i].reg_value);
		if(err != 0 ) {
			dev_err(&client->dev, "i2c write 0x%0x failed\n",
					startup_mode[i].reg_index);
			//return err;
		}
	}
	for(i = 0; i < 0xf; i++) {
		printk(KERN_DEBUG  "%s:0x%0x -- 0x%0x\n",
			 __func__,i, es7243_i2c_read(client, i));
	}
	return 0;
}

int es7243_start(void)
{
	int i = 0;
	printk("es7243_start\n");
	for(i = 0; i < count; i++)
		es7243_startup(es7243_i2c_client[i]);
	return 0;
}

EXPORT_SYMBOL(es7243_start);

int es7243_init(void)
{
	int i = 0,ret=0;
	for(i = 0; i < count; i++) {
		ret=es7243_init_mode(es7243_i2c_client[i]);
		if (ret!=0) {
			//return ret;
		}
	}
	return 0;
}

EXPORT_SYMBOL(es7243_init);

int es7243_set_standby(struct i2c_client *client)
{
	int i = 0;
	int err = 0;
	for(i = 0; i < ES7243_STANDBY_NUM; i++) {
		err = es7243_i2c_write(client, standby_mode[i].reg_index,
				standby_mode[i].reg_value);
		if(err != 0 )
			dev_err(&client->dev, "i2c write 0x%0x failed\n",
					standby_mode[i].reg_index);
	}
	for(i = 0; i < 0xf; i++)
		printk(KERN_DEBUG  "%s:0x%0x -- 0x%0x\n",
			 __func__,i, es7243_i2c_read(client, i));
	return 0;
}

int es7243_standby(void)
{
	int i = 0;
	printk("es7243_standby\n");
	for(i = 0; i < count; i++)
		es7243_set_standby(es7243_i2c_client[i]);
	return 0;
}
EXPORT_SYMBOL(es7243_standby);

static const struct of_device_id of_es7243_match[] = {
	{ .compatible = "everest,es7243"},
	{},
};

MODULE_DEVICE_TABLE(of, of_es7243_match);

static int es7243_i2c_probe(struct i2c_client *client,
		const struct i2c_device_id *id)
{
	const struct of_device_id *match;
	struct device *dev = &client->dev;
	printk("es7243_i2c_probe\n");
	if (dev->of_node) {
		match = of_match_device(of_es7243_match, dev);
		if (!match) {
			dev_err(dev, "Failed to find matching dt id\n");
			return -EINVAL;
		}
	}
	es7243_i2c_client[count] = client;
	count++;
	es7243_init();
	es7243_start();
	printk("es7243_i2c_probe finish\n");
	return 0;
}

static int es7243_i2c_remove(struct i2c_client *client)
{
	es7243_standby();
	return 0;
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

module_i2c_driver(es7243_driver);
MODULE_AUTHOR("Shiqin Chen <chensq@rock-chips.com>");
MODULE_DESCRIPTION("ES7243 I2C Driver");
MODULE_LICENSE("GPL v2");
