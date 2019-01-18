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

#ifdef CONFIG_OF
#include <linux/of.h>
#include <linux/of_gpio.h>
#include <linux/of_platform.h>
#endif

#define GPIO_LOW 0
#define GPIO_HIGH 1

#define INVALID_ADVALUE			-1
#define EMPTY_DEFAULT_ADVALUE		1024
#define DRIFT_DEFAULT_ADVALUE		70
#define DEBOUNCE_JIFFIES	(10 / (MSEC_PER_SEC / HZ))	/* 10ms */
#define ADC_SAMPLE_JIFFIES	(100 / (MSEC_PER_SEC / HZ))	/* 100ms */

#define EXT_ADCCHAN_NUM 2

#define GPIO_BANK	32
#define RK_GPIO(chip, offset)		(chip * GPIO_BANK + offset)

#define JAX_DEBUG 0
#if JAX_DEBUG
#define EXTBRD_DEBUG(s, ...) printk("### jaxx " s, ##__VA_ARGS__)
#else
#define EXTBRD_DEBUG(s, ...) do {} while(0)
#endif
#define EXTBRD_ERROR(s, ...) printk("*** jaxx " s, ##__VA_ARGS__)

/* Board Resource definition */
#define TB_PROD
#define EXT_DIGIT_GPIOS
//define EXT_GPIO_KEYS
#define EXT_ADC

static const struct of_device_id of_extbrd_match[] = {
	{ .compatible = "eaidk-extboard", },
	{},
};
MODULE_DEVICE_TABLE(of, of_extbrd_match);

struct extbrd_drvdata
{
	int result[EXT_ADCCHAN_NUM];
	struct delayed_work adc_poll_work;
	struct iio_channel *chan[EXT_ADCCHAN_NUM];
};

#ifdef EXT_DIGIT_GPIOS
struct extgpio_desc
{
	int gpio;
	char tubename[12];
};

static struct extgpio_desc digit_gpios[] = {
#ifdef TB_PROD
	{RK_GPIO(0, 5), "TUBE_A"},
	{RK_GPIO(0, 6), "TUBE_B"},
	{RK_GPIO(1, 9), "TUBE_C"},
	{RK_GPIO(1, 10), "TUBE_D"},
#else
	{RK_GPIO(1, 7), "TUBE_A"},
	{RK_GPIO(1, 8), "TUBE_B"},
	{RK_GPIO(1, 9), "TUBE_C"},
	{RK_GPIO(1, 10), "TUBE_D"},
#endif
};

#define ARR_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#define EXT_GPIO_NUM  	ARR_SIZE(digit_gpios)
#endif /* End of EXT_DIGIT_GPIOS */

#ifdef EXT_GPIO_KEYS
static int gpio_keys[] = {
#ifdef TB_PROD
	RK_GPIO(0, 5),  //GPIO_B1
	RK_GPIO(0, 6), //GPIO1_B2
	RK_GPIO(1, 9),  //GPIO1_B1
	RK_GPIO(1, 10), //GPIO1_B2
#else
	RK_GPIO(1, 7),  //GPIO1_A7
	RK_GPIO(1, 8),  //GPIO1_B0
	RK_GPIO(1, 9),  //GPIO1_B1
	RK_GPIO(1, 10), //GPIO1_B2
#endif
};
#define EXT_KEY_NUM  	ARR_SIZE(gpio_keys)
#endif /* End of EXT_GPIO_KEYS */

#ifdef EXT_ADC
#define ADC_VALUE_LOW		0
static struct iio_channel *adc_chan_map;

static int ext_keys_adc_iio_read(struct extbrd_drvdata *data, struct iio_channel *channel)
{
	int val, ret;

	if (!channel)
		return INVALID_ADVALUE;
	ret = iio_read_channel_raw(channel, &val);
	if (ret < 0) {
		EXTBRD_ERROR("read channel() error: %d\n", ret);
		return ret;
	}
	return val;
}

static void adc_key_poll(struct work_struct *work)
{
	struct extbrd_drvdata *ddata;
	int i, result = -1;

	ddata = container_of(work, struct extbrd_drvdata, adc_poll_work.work);

	for (i = 0; i < EXT_ADCCHAN_NUM; i++) {
		result = ext_keys_adc_iio_read(ddata, ddata->chan[i]);
		if (result > INVALID_ADVALUE && result < EMPTY_DEFAULT_ADVALUE) { //iio read invalid adc result, do nothing!
			if (ddata->result[i] != result) {
				//EXTBRD_DEBUG("Chan[%d] : %d\n", i, result);
				if (result >= ADC_VALUE_LOW && result < DRIFT_DEFAULT_ADVALUE) {
					printk("## ADC Chan[%d] val: %d, pressed.\n", i, result);
				}
			}
			ddata->result[i] = result;  //adc key button pressed, ground connect.
		}
	}

	schedule_delayed_work(&ddata->adc_poll_work, ADC_SAMPLE_JIFFIES);
}

static ssize_t show_chan0_measure(struct device *dev, struct device_attribute *attr, char *buf)
{
	size_t count = 0;
	struct extbrd_drvdata *ddata = dev_get_drvdata(dev);

	count += sprintf(&buf[count], "%d", ddata->result[0]);

	return count;
}

static struct device_attribute measure0_attr =__ATTR(extadckey0, S_IRUGO, show_chan0_measure, NULL);

static ssize_t show_chan1_measure(struct device *dev, struct device_attribute *attr, char *buf)
{
	size_t count = 0;
	struct extbrd_drvdata *ddata = dev_get_drvdata(dev);

	count += sprintf(&buf[count], "%d", ddata->result[1]);

	return count;
}

static struct device_attribute measure1_attr =__ATTR(extadckey1, S_IRUGO, show_chan1_measure, NULL);
#endif /* End of EXT_ADC */

/*
 ********************* DTS **********************
	extbrd: extbrd {
		compatible = "eaidk-extboard";
		io-channels = <&saradc 0>, <&saradc 3>;

		ext_gpios {
			pinctrl-names = "default";
			ext_gpioA = <&gpio1 0 GPIO_ACTIVE_HIGH>;
			ext_gpioB = <&gpio1 1 GPIO_ACTIVE_HIGH>;
			// ...
		};

		ext_keys {
			power-key {
				gpios = <&gpio0 5 GPIO_ACTIVE_LOW>;
				linux,code = <116>;
				label = "power";
			};

			menu-key {
				linux,code = <59>;
				label = "menu";
				rockchip,adc_value = <746>;
			};
			// ...
		};
	};
 */

static int extbrd_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	int ret = 0;
	int i;
#ifdef EXT_GPIO_KEYS
	char gpiokey_name[16];
	int irq;
#endif
	struct extbrd_drvdata *ddata = NULL;
	//u32 val;

	EXTBRD_DEBUG("%s\n", __func__);

	ddata = devm_kzalloc(dev, sizeof(struct extbrd_drvdata), GFP_KERNEL);
	if (!ddata) {
		ret = -ENOMEM;
		return ret;
	}
	platform_set_drvdata(pdev, ddata);
	dev_set_drvdata(&pdev->dev, ddata);

	/**************** Parst ExtGPIO Begin ****************/
#ifdef EXT_DIGIT_GPIOS
	for (i = 0; i < EXT_GPIO_NUM; i++) {
		if (!gpio_is_valid(digit_gpios[i].gpio)) {
			EXTBRD_ERROR("Invalid gpio : %d\n", digit_gpios[i].gpio);
			ret = -EINVAL;
			return ret;
		}

		ret = devm_gpio_request(dev, digit_gpios[i].gpio, digit_gpios[i].tubename);
		if (ret != 0) {
			EXTBRD_ERROR("Request gpio : %d fail\n", digit_gpios[i].gpio);
			ret = -EIO;
			return ret;
		}

		//low : light on, high: light off
		gpio_direction_output(digit_gpios[i].gpio, GPIO_LOW);
		gpio_export(digit_gpios[i].gpio, true);
	}
#endif /* End of EXT_DIGIT_GPIOS */

	/**************** Parst ExtGPIO End ****************/

	/**************** Parst ExtKEY Begin ****************/
#ifdef EXT_GPIO_KEYS
	EXTBRD_DEBUG("%s %d\n", __func__, __LINE__);
	for (i = 0; i < EXT_KEY_NUM; i++) {
		if (!gpio_is_valid(gpio_keys[i])) {
			EXTBRD_ERROR("Invalid gpio : %d\n", gpio_keys[i]);
			ret = -EINVAL;
			return ret;
		}

		snprintf(gpiokey_name, 16, "extkey%d", i);
		ret = devm_gpio_request(dev, gpio_keys[i], gpiokey_name);
		if (ret != 0) {
			EXTBRD_ERROR("gpio-keys: failed to request GPIO %d, error %d\n",
				                          gpio_keys[i], ret);
			ret = -EIO;
			return ret;
		}

		ret = gpio_direction_input(gpio_keys[i]);
		if (ret < 0) {
			EXTBRD_ERROR("gpio-keys: failed to configure input direction for GPIO %d, error %d\n",
				gpio_keys[i], ret);
			return ret;
		}

		irq = gpio_to_irq(gpio_keys[i]);
		if (irq < 0) {
			ret = irq;
			EXTBRD_ERROR("gpio-keys: Unable to get irq number for GPIO %d, error %d\n",
					gpio_keys[i], ret);
			return ret;
		}

		EXTBRD_DEBUG("Request GPIO(%d) IRQ(%d) OK.\n", gpio_keys[i], irq);
		gpio_export(gpio_keys[i], true);
	}
#endif

	/**************** Parst ExtKEY End ****************/

	/**************** Parst ADC Begin ****************/
#ifdef EXT_ADC
	adc_chan_map = iio_channel_get_all(&pdev->dev);
	if (IS_ERR(adc_chan_map)) {
		dev_info(&pdev->dev, "no io-channels defined\n");
		adc_chan_map = NULL;
		return -EIO;
	}

	ddata->chan[0] = &adc_chan_map[0];  //saradc channel 0
	ddata->chan[1] = &adc_chan_map[1];  //saradc channel 3

	if (device_create_file(&pdev->dev, &measure0_attr)) {
		EXTBRD_ERROR(" device create chan0 file failed\n");
		goto fail0;
	}
	if (device_create_file(&pdev->dev, &measure1_attr)) {
		EXTBRD_ERROR(" device create chan1 file failed\n");
		goto fail0;
	}

	/* adc polling work */
	if (ddata->chan[0] && ddata->chan[1]) {
		INIT_DELAYED_WORK(&ddata->adc_poll_work, adc_key_poll);
		schedule_delayed_work(&ddata->adc_poll_work,
				      ADC_SAMPLE_JIFFIES);
	}
#endif
	/**************** Parst ADC End ****************/

	return ret;

#ifdef EXT_ADC
fail0:
	device_remove_file(&pdev->dev, &measure0_attr);
	device_remove_file(&pdev->dev, &measure1_attr);

	iio_channel_release_all(adc_chan_map);
#endif

	return ret;
}

static int extbrd_remove(struct platform_device *pdev)
{
#ifdef EXT_ADC
	struct extbrd_drvdata *ddata = platform_get_drvdata(pdev);
#endif

	EXTBRD_DEBUG(" %s\n", __func__);

#ifdef EXT_ADC
	if (ddata->chan[0] && ddata->chan[1])
		cancel_delayed_work_sync(&ddata->adc_poll_work);

	device_remove_file(&pdev->dev, &measure0_attr);
	device_remove_file(&pdev->dev, &measure1_attr);

	iio_channel_release_all(adc_chan_map);
#endif

	return 0;
}

static void extbrd_shutdown(struct platform_device *pdev)
{
	EXTBRD_DEBUG(" %s\n", __func__);
	extbrd_remove(pdev);
}

static struct platform_driver extbrd_driver = {
	.probe		= extbrd_probe,
	.remove		= extbrd_remove,
	.shutdown	= extbrd_shutdown,
	.driver		= {
		.name	= "eaidk-extboard",
		.of_match_table = of_extbrd_match,
	},
};

#if 0  /* Use this function when driver module loaded */
module_platform_driver(extbrd_driver);
#else  /* Build in kernel, because saradc driver must be early loaded than this driver */
static __init int extbrd_modinit(void)
{
	return platform_driver_register(&extbrd_driver);
}
late_initcall(extbrd_modinit);

static __exit void extbrd_exit(void)
{
	platform_driver_unregister(&extbrd_driver);
}
#endif

MODULE_AUTHOR(" <jax.fang@rock-chips.com>");
MODULE_DESCRIPTION("EAIDK ExtBoard Driver");
MODULE_LICENSE("GPL");
MODULE_ALIAS("platform:eaidk-extboard");
