/*
 * System Control Driver
 *
 * Copyright (C) 2012 Freescale Semiconductor, Inc.
 * Copyright (C) 2012 Linaro Ltd.
 *
 * Author: Dong Aisheng <dong.aisheng@linaro.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#include <linux/err.h>
#include <linux/io.h>
#include <linux/module.h>
#include <linux/list.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/of_platform.h>
#include <linux/platform_data/syscon.h>
#include <linux/platform_device.h>
#include <linux/regmap.h>
#include <linux/mfd/syscon.h>
#include <linux/slab.h>

static struct platform_driver msch_driver;


struct syscon {
	struct device_node *np;
	struct regmap *regmap;
	struct list_head list;
	void __iomem *base;
};

static int msch_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	//struct syscon_platform_data *pdata = dev_get_platdata(dev);
	struct syscon *syscon;
	struct resource *res;
	void __iomem *base;

	syscon = devm_kzalloc(dev, sizeof(*syscon), GFP_KERNEL);
	if (!syscon)
		return -ENOMEM;

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!res)
		return -ENOENT;
	base = devm_ioremap_resource(dev, res);
	syscon->base = base;
	platform_set_drvdata(pdev, syscon);

	writel(0x00000004, syscon->base + 0);
	printk("write the MSCH_AgingX0 to 0x00000004\n");
	return 0;
}
static const struct of_device_id msch_of_match[] = {
	{ .compatible = "msch-agingx0", },
	{ }
};
MODULE_DEVICE_TABLE(of, xxxx_of_match);

static const struct platform_device_id msch_ids[] = {
	{ "msch-agingx0", 0},
	{ }
};

static struct platform_driver msch_driver = {
	.driver = {
		.name = "msch-agingx0",
		.of_match_table = of_match_ptr(msch_of_match),
	},
	.probe		= msch_probe,
	.id_table	= msch_ids,
};

static int __init syscon_init(void)
{
	return platform_driver_register(&msch_driver);
}
postcore_initcall(syscon_init);

static void __exit msch_exit(void)
{
	platform_driver_unregister(&msch_driver);
}
module_exit(msch_exit);

MODULE_AUTHOR("chenyifu <chenyf@rock-chips>");
MODULE_DESCRIPTION("System Control driver");
MODULE_LICENSE("GPL v2");
