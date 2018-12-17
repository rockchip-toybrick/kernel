#include <linux/err.h>
#include <linux/gpio.h>
#include <linux/gpio/consumer.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/property.h>
#include <linux/slab.h>
#include <linux/workqueue.h>
#include <linux/delay.h>
#include <linux/interrupt.h>

#include <linux/iio/iio.h>
#include <linux/iio/machine.h>
#include <linux/iio/driver.h>
#include <linux/iio/consumer.h>
#include <linux/reboot.h>

#ifdef CONFIG_OF
#include <linux/of.h>
#include <linux/of_gpio.h>
#include <linux/of_platform.h>
#endif

#define GPIO_LOW 0
#define GPIO_HIGH 1


static const struct of_device_id of_uhrst_match[] = {
	{ .compatible = "usbhub-reset", },
	{},
};
MODULE_DEVICE_TABLE(of, of_uhrst_match);

struct uhrst_drvdata {
	struct notifier_block reboot_notifier;
	int uhrst_gpio;
};

static int reboot_notifier_handler(struct notifier_block *nb,
					 unsigned long action, void *cmd)
{
	struct uhrst_drvdata *ddata = container_of(nb, struct uhrst_drvdata, reboot_notifier);

	gpio_set_value(ddata->uhrst_gpio, GPIO_LOW);

	return 0;
}

static int uhrst_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	int ret = 0;
	struct uhrst_drvdata *ddata = NULL;
	struct device_node *node = pdev->dev.of_node;
	enum of_gpio_flags flag;
	int uhrst_gpio;

	ddata = devm_kzalloc(dev, sizeof(struct uhrst_drvdata), GFP_KERNEL);
	if (!ddata) {
		ret = -ENOMEM;
		return ret;
	}

	platform_set_drvdata(pdev, ddata);
	dev_set_drvdata(&pdev->dev, ddata);
	ddata->reboot_notifier.notifier_call = reboot_notifier_handler;
	ret = register_reboot_notifier(&ddata->reboot_notifier);
	if (ret) {
		printk("Failed to register reboot notifier\n");
		return ret;
	}

	ddata->uhrst_gpio = of_get_named_gpio_flags(node, "uhrst-gpio", 0, &flag);
	if (uhrst_gpio < 0) {
		printk("%s() Can not read property uhrst_gpio\n", __FUNCTION__);
		ret = -EIO;
		goto fail0;
	}
	uhrst_gpio = ddata->uhrst_gpio;

	ret = devm_gpio_request(dev, uhrst_gpio, "usbhub-reset");
	if (ret != 0) {
		printk("Request gpio : %d fail\n", uhrst_gpio);
		return ret;
	}

	gpio_direction_output(uhrst_gpio, GPIO_HIGH);

	return ret;

fail0:
	unregister_reboot_notifier(&ddata->reboot_notifier);

	return ret;
}

static int uhrst_remove(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct uhrst_drvdata *ddata = dev_get_drvdata(dev);

	devm_gpio_free(dev, ddata->uhrst_gpio);
	unregister_reboot_notifier(&ddata->reboot_notifier);
	devm_kfree(dev, ddata);
	return 0;
}

static void uhrst_shutdown(struct platform_device *pdev)
{
	uhrst_remove(pdev);
}

static struct platform_driver uhrst_driver = {
	.probe		= uhrst_probe,
	.remove		= uhrst_remove,
	.shutdown	= uhrst_shutdown,
	.driver		= {
		.name	= "usbhub-reset",
		.of_match_table = of_uhrst_match,
	},
};

#if 0  /* Use this function when driver module loaded */
module_platform_driver(uhrst_driver);
#else  /* Build in kernel, because saradc driver must be early loaded than this driver */
static __init int uhrst_modinit(void)
{
	return platform_driver_register(&uhrst_driver);
}
late_initcall(uhrst_modinit);

/*
static __exit void uhrst_exit(void)
{
	platform_driver_unregister(&uhrst_driver);
}
*/
#endif

MODULE_DESCRIPTION("USB Hub Reset Driver");
MODULE_LICENSE("GPL");
