#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/i2c.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/of_device.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/clk.h>
#include <linux/delay.h>
struct tda7719_priv {
	struct clk *mclk;
};

struct tda7719_reg {
	u8 reg_index;
	u8 reg_value;
};

/* The Sequence for Startup  slave mode */
static struct tda7719_reg default_mode[] = {
		{0x00,0x22},		//0x82
		{0x01,0xe1},
		{0x02,0x30},
		
		{0x03,0x10},	
		{0x04,0xff},
	
#if 1
		{0x5,0x00},
		{0x6,0xf8},
		{0x7,0x70}, 	//0x7a
		{0x8,0x10}, 	//0x041
		{0x9,0x1b},
		{0xa,0x6f},
		{0xb,0x79}, 	//0x19
		{0xc,0x4d},
		{0xd,0x2a},
		{0xe,0x2a},
		{0xf,0x32},
		{0x10,0x32},
		{0x11,0x32},
		{0x12,0x32},
		{0x13,0x42},
		{0x14,0x42},
		
#else
		
		{0x05,0xff},
		{0x06,0xff},
		{0x07,0xf7},
		{0x08,0x10},
	
		{0x09,0xe0},
		{0x0a,0xe0},
		{0x0b,0xe0},
		{0x0c,0xe0},
		
		{0x0d,0x00},
		{0x0e,0x00},
		{0x0f,0xff},
		{0x10,0xff},
		{0x11,0xff},
		{0x12,0xff},
		{0x13,0x00},
		{0x14,0xfe},
#endif


};
#define TDA7719_STARTUP_NUM ARRAY_SIZE(default_mode)

static int tda7719_i2c_read(struct i2c_client *client, u8 reg)
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
	xfer[1].len = 1;
	xfer[1].buf = (u8 *)&data;

	ret = i2c_transfer(client->adapter, xfer, 2);
	if (ret != 2) {
		dev_err(&client->dev, "i2c_transfer() returned %d\n", ret);
		return 0;
	}

	return data;
}

static int tda7719_i2c_write(struct i2c_client *client, u8 reg, u8 value)
{
	u8 data[2];

	data[0] = reg;
	data[1] = value;

	if (i2c_master_send(client, data, 2) == 2)
		return 0;
	else
		return -EIO;
}

int tda7719_startup(struct i2c_client *client)
{
	int i = 0;
	int err = 0;
	printk("%s\n", __func__);
	for(i = 0; i < TDA7719_STARTUP_NUM; i++) {
		err = tda7719_i2c_write(client, default_mode[i].reg_index,
				default_mode[i].reg_value);
		if(err != 0 )
			dev_err(&client->dev, "csq i2c write 0x%0x failed\n",
					default_mode[i].reg_index);
	}
	
	for(i = 0; i < TDA7719_STARTUP_NUM; i++) {
		dev_info(&client->dev, "csq 0x%0x -- 0x%0x\n", i, tda7719_i2c_read(client, i));
	}
	mdelay(50);
	return 0;
}

static int tda7719_i2c_remove(struct i2c_client *client)
{
	return 0;
}

static int tda7719_i2c_probe(struct i2c_client *client,
		const struct i2c_device_id *id)
{
	int ret = 0;
	struct tda7719_priv *tda7719;
	printk(KERN_ERR "tda7719_i2c_probe\n");
	tda7719 = devm_kzalloc(&client->dev, sizeof(*tda7719), GFP_KERNEL);
	if (!tda7719)
		return -ENOMEM;
	i2c_set_clientdata(client, tda7719);
	tda7719_startup(client);
	return ret;
}

static const struct i2c_device_id tda7719_id[] = {
	{"tda7719"},
	{}
};

MODULE_DEVICE_TABLE(i2c, tda7719_id);

static struct i2c_driver tda7719_driver = {
	.driver         = {
		.name   = "tda7719",
		.of_match_table = NULL,
	},
	.probe          = tda7719_i2c_probe,
	.remove         = tda7719_i2c_remove,
	.id_table       = tda7719_id,
};


static int __init tda7719_driver_init(void)
{
	printk(KERN_ERR "tda7719_driver_init\n");
	return i2c_add_driver(&tda7719_driver);
}

late_initcall_sync(tda7719_driver_init);

static void __exit tda7719_driver_exit(void)
{
	    return i2c_del_driver(&tda7719_driver);
}
module_exit(tda7719_driver_exit);


MODULE_AUTHOR("Shiqin Chen <chensq@rock-chips.com>");
MODULE_DESCRIPTION("TDA7719 I2C Driver");
MODULE_LICENSE("GPL v2");
