/*
 * drivers/misc/fan_gpio_test.c
 *
 * Copyright (C) 2012-2016 Rockchip Co.,Ltd.
 * Author: Bin Yang <yangbin@rock-chips.com>
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/miscdevice.h>
#include <linux/gpio.h>
#include <linux/uaccess.h>
#include <linux/atomic.h>
#include <linux/delay.h>
#include <linux/input.h>
#include <linux/freezer.h>
#include <linux/of_gpio.h>

static struct class *fan_gpio_test_class;

struct fan_gpio_test {
	struct device *dev;
	struct device sys_dev;

	struct gpio_desc *gpio_fan;
};

static ssize_t fan_test_show(struct device *sys_dev,
				 struct device_attribute *attr,
				 char *buf)
{
	struct fan_gpio_test *gpiod = container_of(sys_dev, struct fan_gpio_test,
						  sys_dev);

	return sprintf(buf, "%d\n", gpiod_get_value(gpiod->gpio_fan));
}

static ssize_t fan_test_store(struct device *sys_dev,
				  struct device_attribute *attr,
				  const char *buf, size_t count)
{
	struct fan_gpio_test *gpiod = container_of(sys_dev, struct fan_gpio_test,
						  sys_dev);
	int val = 0;
	int ret = 0;

	ret = kstrtoint(buf, 0, &val);
	if (ret < 0)
		return ret;
	if (val)
		val = 1;
	gpiod_set_value(gpiod->gpio_fan, val);

	return count;
}
static DEVICE_ATTR_RW(fan_test);

static struct attribute *fan_gpio_test_attrs[] = {
	&dev_attr_fan_test.attr,
	NULL,
};
ATTRIBUTE_GROUPS(fan_gpio_test);

static int fan_gpio_test_device_register(struct fan_gpio_test *gpiod)
{
	int ret;
	struct device *dev = &gpiod->sys_dev;
	const char *name = {"fan-gpio-test"};

	dev->class = fan_gpio_test_class;
	dev_set_name(dev, "%s", name);
	dev_set_drvdata(dev, gpiod);
	ret = device_register(dev);

	return ret;
}

static int fan_gpio_test_probe(struct platform_device *pdev)
{
	struct fan_gpio_test *gpiod;
	int ret = 0;

	fan_gpio_test_class = class_create(THIS_MODULE, "fan_gpio_test");
	if (IS_ERR(fan_gpio_test_class)) {
		pr_err("create fan-gpio class failed (%ld)\n",
		       PTR_ERR(fan_gpio_test_class));
		return PTR_ERR(fan_gpio_test_class);
	}
	fan_gpio_test_class->dev_groups = fan_gpio_test_groups;

	gpiod = devm_kzalloc(&pdev->dev, sizeof(*gpiod), GFP_KERNEL);
	if (!gpiod)
		return -ENOMEM;

	gpiod->dev = &pdev->dev;

	gpiod->gpio_fan = devm_gpiod_get_optional(gpiod->dev,
						     "fan-test", GPIOD_OUT_LOW);
	if (IS_ERR(gpiod->gpio_fan)) {
		dev_warn(gpiod->dev, "Could not get fan-test-gpios!\n");
		gpiod->gpio_fan = NULL;
	}

	ret = fan_gpio_test_device_register(gpiod);
	if (ret < 0) {
		dev_err(gpiod->dev, "fan_gpio_test device register fail\n");
		return ret;
	}

	dev_info(gpiod->dev, "fan_gpio_test_probe success\n");

	return 0;
}

static const struct of_device_id fan_gpio_test_match[] = {
	{ .compatible = "fan-gpio-test" },
	{ /* Sentinel */ }
};

static int fan_gpio_test_remove(struct platform_device *pdev)
{
	if (!IS_ERR(fan_gpio_test_class))
		class_destroy(fan_gpio_test_class);

	return 0;
}

static struct platform_driver fan_gpio_test_driver = {
	.probe = fan_gpio_test_probe,
	.remove = fan_gpio_test_remove,
	.driver = {
		.name = "fan_gpio_test_test",
		.owner = THIS_MODULE,
		.of_match_table	= fan_gpio_test_match,
	},
};

module_platform_driver(fan_gpio_test_driver);

MODULE_ALIAS("platform:fan_gpio_test");
MODULE_AUTHOR("<jax.fang@rock-chips.com>");
MODULE_LICENSE("GPL v2");
MODULE_DESCRIPTION("fan gpio test driver");
