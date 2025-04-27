// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2024 Rockchip Electronics Co., Ltd
 */

#include "linux/stddef.h"
#include <linux/acpi.h>
#include <linux/i2c.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/regmap.h>

#include "icm42680.h"

static int icm42680_i2c_bus_setup(struct icm42680_data *st)
{
	/* set slew rates for I2C and SPI */
	// TODO

	/* disable SPI bus */
	return regmap_update_bits(st->regmap, REG_INTF_CONFIG0,
				  BIT_FIFO_COUNT_REC_UI_SIFS_CFG_MASK,
				   BIT_FIFO_COUNT_REC_UI_SIFS_CFG_SPI_DIS);
}

static int icm42680_i2c_probe(struct i2c_client *client,
					const struct i2c_device_id *id)
{
	struct regmap *regmap;
	const char *name = NULL;
	int chip_type = 0;

	if (!i2c_check_functionality(client->adapter, I2C_FUNC_I2C)) {
		dev_err(&client->dev, "I2c function error\n");
		return -EOPNOTSUPP;
	}

	if (id) {
		chip_type = id->driver_data;
		name = id->name;
	}

	regmap = devm_regmap_init_i2c(client, &icm42680_regmap_config);
	if (IS_ERR(regmap)) {
		dev_err(&client->dev, "Failed to register i2c regmap %d\n",
			(int)PTR_ERR(regmap));
		return PTR_ERR(regmap);
	}

	dev_info(&client->dev, "chip_type = %d, name = %s\n", chip_type, name);

	return icm42680_core_probe(regmap, client->irq, name, chip_type, icm42680_i2c_bus_setup);
}

static int icm42680_i2c_remove(struct i2c_client *client)
{
	icm42680_core_remove(&client->dev);

	return 0;
}

static const struct i2c_device_id icm42680_i2c_id[] = {
	{"icm42680", 0},
	{}
};
MODULE_DEVICE_TABLE(i2c, icm42680_i2c_id);

#ifdef CONFIG_OF
static const struct of_device_id icm42680_of_match[] = {
	{ .compatible = "Invensense,icm42680" },
	{ },
};
MODULE_DEVICE_TABLE(of, icm42680_of_match);
#endif

static struct i2c_driver icm42680_i2c_driver = {
	.driver = {
		.name = "icm42680_i2c",
		.acpi_match_table = ACPI_PTR(icm42680_acpi_match),
		.of_match_table = of_match_ptr(icm42680_of_match),
		.pm = &icm42680_pm_ops,
	},
	.probe = icm42680_i2c_probe,
	.remove = icm42680_i2c_remove,
	.id_table = icm42680_i2c_id,
};
module_i2c_driver(icm42680_i2c_driver);

MODULE_AUTHOR("Hangyu Li <hangyu.li@rock-chips.com>");
MODULE_DESCRIPTION("ICM42680 I2C driver");
MODULE_LICENSE("GPL");
