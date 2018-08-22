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

#define JAX_DEBUG 1
#if JAX_DEBUG
#define EXTBRD_DEBUG(s, ...) printk("## " s, ##__VA_ARGS__)
#else
#define EXTBRD_DEBUG
#endif
#define EXTBRD_ERROR(s, ...) printk("** " s, ##__VA_ARGS__)

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

struct extgpio_desc
{
	int gpio;
	char tubename[12];
};

static struct extgpio_desc digit_gpios[] = {
	{RK_GPIO(2, 2), "TUBE_A"},	//GPIO2_A2
	{RK_GPIO(2, 3), "TUBE_B"},	//GPIO2_A3
	{RK_GPIO(2, 4), "TUBE_C"},	//GPIO2_A4
	{RK_GPIO(2, 5), "TUBE_D"},	//GPIO2_A5
	{RK_GPIO(2, 6), "TUBE_E"},	//GPIO2_A6
	{RK_GPIO(1, 23), "TUBE_F"},	//GPIO1_C7
	{RK_GPIO(1, 22), "TUBE_G"},	//GPIO1_C6
	{RK_GPIO(1, 24), "TUBE_DP"},//GPIO1_D0
};

#define ARR_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#define EXT_GPIO_NUM  	ARR_SIZE(digit_gpios)

static int tube_set_gpio(const char *name, int value)
{
	int i;

	for (i = 0; i < EXT_GPIO_NUM; i++) {
		if (!strcmp(digit_gpios[i].tubename, name)) {
			gpio_set_value(digit_gpios[i].gpio, value);
			break;
		}
	}

	return 0;
}

static int display_digit_tube(const char ch)
{
	switch (ch) {
		case '0':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_HIGH);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 0\n");
			break;
		case '1':
			tube_set_gpio("TUBE_A", GPIO_HIGH);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_HIGH);
			tube_set_gpio("TUBE_G", GPIO_HIGH);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 1\n");
			break;
		case '2':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_HIGH);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 2\n");
			break;
		case '3':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_HIGH);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 3\n");
			break;
		case '4':
			tube_set_gpio("TUBE_A", GPIO_HIGH);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 4\n");
			break;
		case '5':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_HIGH);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 5\n");
			break;
		case '6':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_HIGH);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 6\n");
			break;
		case '7':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_HIGH);
			tube_set_gpio("TUBE_G", GPIO_HIGH);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 7\n");
			break;
		case '8':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 8\n");
			break;
		case '9':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show digit 9\n");
			break;
		case '.':
			tube_set_gpio("TUBE_A", GPIO_HIGH);
			tube_set_gpio("TUBE_B", GPIO_HIGH);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_HIGH);
			tube_set_gpio("TUBE_G", GPIO_HIGH);
			tube_set_gpio("TUBE_DP", GPIO_LOW);
			EXTBRD_DEBUG("show DP !\n");
			break;
		case 'e':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show 'E'!\n");
			break;
		case 'E':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_HIGH);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show 'E'!\n");
			break;
		case 'f':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_HIGH);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show 'F'!\n");
			break;
		case 'o':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show 'o' !\n");
			break;
		case 'n':
			tube_set_gpio("TUBE_A", GPIO_LOW);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_HIGH);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show 'n' !\n");
			break;
		case 'u':
			tube_set_gpio("TUBE_A", GPIO_HIGH);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show 'u' !\n");
			break;
		case 'U':
			tube_set_gpio("TUBE_A", GPIO_HIGH);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_LOW);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_HIGH);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show 'U' !\n");
			break;
		case '-':
			tube_set_gpio("TUBE_A", GPIO_HIGH);
			tube_set_gpio("TUBE_B", GPIO_HIGH);
			tube_set_gpio("TUBE_C", GPIO_HIGH);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_HIGH);
			tube_set_gpio("TUBE_F", GPIO_HIGH);
			tube_set_gpio("TUBE_G", GPIO_HIGH);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("show no digit !\n");
			break;
		case 'h':
		default:
			tube_set_gpio("TUBE_A", GPIO_HIGH);
			tube_set_gpio("TUBE_B", GPIO_LOW);
			tube_set_gpio("TUBE_C", GPIO_LOW);
			tube_set_gpio("TUBE_D", GPIO_HIGH);
			tube_set_gpio("TUBE_E", GPIO_LOW);
			tube_set_gpio("TUBE_F", GPIO_LOW);
			tube_set_gpio("TUBE_G", GPIO_LOW);
			tube_set_gpio("TUBE_DP", GPIO_HIGH);
			EXTBRD_DEBUG("Not suppored Character !\n");
			break;
	}

	return 0;
}

static ssize_t show_digit_tube(struct device *dev,
    struct device_attribute *attr, char *buf)
{
    return snprintf(buf, 32, "echo [0-9]/-/. > digit_tube\n");
}

static ssize_t store_digit_tube(struct device *dev,
 	struct device_attribute *attr, const char *buf, size_t count)
{
	display_digit_tube(buf[0]);

	return count;
}

const struct device_attribute digit_tube_attrs = {
	.attr = {
		.name = "digit_tube",
		.mode = 0644,
	},
	.show = show_digit_tube,
	.store = store_digit_tube,
};

static int gpio_keys[] = {
	RK_GPIO(2, 12),
	RK_GPIO(4, 24),
};
#define EXT_KEY_NUM  	ARR_SIZE(gpio_keys)

#ifdef EXTKEY_IRQ
static irqreturn_t keys_isr(int irq, void *dev_id)
{
	//BUG_ON(irq != gpio_to_irq(button->gpio));
	EXTBRD_DEBUG("%s() irq: %d\n", __func__, irq);

	return IRQ_HANDLED;
}
#endif

#define ADC_VALUE_LOW		0
static struct iio_channel *adc_chan_map;

static int ext_gpio_leds[] = {
	RK_GPIO(4, 29), //GPIO4_D5
	RK_GPIO(4, 26), //GPIO4_D2
};

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
					gpio_set_value(ext_gpio_leds[i], GPIO_LOW);
				} else {
					gpio_set_value(ext_gpio_leds[i], GPIO_HIGH);
				}
			}
			ddata->result[i] = result;  //adc key button pressed, ground connect.
		}
	}

	schedule_delayed_work(&ddata->adc_poll_work, ADC_SAMPLE_JIFFIES);
}

static ssize_t show_measure(struct device *dev, struct device_attribute *attr, char *buf)
{
	size_t count = 0;
	int i;
	struct extbrd_drvdata *ddata = dev_get_drvdata(dev);

	for (i = 0; i < EXT_ADCCHAN_NUM; i++) {
		count += sprintf(&buf[count], "chan[%d] adc_value: %d\n", i, ddata->result[i]);
	}

	return count;
}

static struct device_attribute measure_attr =__ATTR(extadckey, S_IRUGO, show_measure, NULL);

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
	char gpiokey_name[16];
	int irq;
	struct extbrd_drvdata *ddata = NULL;

	EXTBRD_DEBUG("%s\n", __func__);

	ddata = devm_kzalloc(dev, sizeof(struct extbrd_drvdata), GFP_KERNEL);
	if (!ddata) {
		ret = -ENOMEM;
		return ret;
	}
	platform_set_drvdata(pdev, ddata);
	dev_set_drvdata(&pdev->dev, ddata);

	/**************** Parst ExtGPIO Begin ****************/
	for (i = 0; i < EXT_GPIO_NUM; i++) {
		if (!gpio_is_valid(digit_gpios[i].gpio)) {
			EXTBRD_ERROR("Invalid gpio : %d\n", digit_gpios[i].gpio);
			ret = -EINVAL;
			goto fail0;
		}

		ret = devm_gpio_request(dev, digit_gpios[i].gpio, digit_gpios[i].tubename);
		if (ret != 0) {
			EXTBRD_ERROR("Request gpio : %d fail\n", digit_gpios[i].gpio);
			ret = -EIO;
			goto fail0;
		}

		gpio_direction_output(digit_gpios[i].gpio, GPIO_HIGH);
	}

	if(device_create_file(&pdev->dev, &digit_tube_attrs)) {
		EXTBRD_ERROR("Device Create digit_tube_attrs file fail.\n");
		ret = -EEXIST;
		goto fail1;
	}

	/**************** Parst ExtGPIO End ****************/

	/**************** Parst ExtKEY Begin ****************/
	for (i = 0; i < EXT_KEY_NUM; i++) {
		if (!gpio_is_valid(gpio_keys[i])) {
			 EXTBRD_ERROR("Invalid gpio : %d\n", gpio_keys[i]);
			 ret = -EINVAL;
			 goto fail2;
		}

		snprintf(gpiokey_name, 16, "extkey%d", i);
		ret = devm_gpio_request(dev, gpio_keys[i], gpiokey_name);
		if (ret != 0) {
			EXTBRD_ERROR("gpio-keys: failed to request GPIO %d, error %d\n",
				                          gpio_keys[i], ret);
			ret = -EIO;
			goto fail2;
		}

		ret = gpio_direction_input(gpio_keys[i]);
		if (ret < 0) {
			EXTBRD_ERROR("gpio-keys: failed to configure input direction for GPIO %d, error %d\n",
				gpio_keys[i], ret);
			goto fail3;
		}

		irq = gpio_to_irq(gpio_keys[i]);
		if (irq < 0) {
			ret = irq;
			EXTBRD_ERROR("gpio-keys: Unable to get irq number for GPIO %d, error %d\n",
					gpio_keys[i], ret);
			goto fail3;
		}

#ifdef EXTKEY_IRQ
		ret = devm_request_irq(dev, irq, keys_isr, IRQF_TRIGGER_FALLING, gpiokey_name, NULL);
		if (ret < 0) {
			EXTBRD_ERROR("gpio-keys: Unable to claim irq %d; error %d\n", irq, ret);
			goto fail3;
		}
		EXTBRD_DEBUG("Request GPIO(%d) IRQ(%d) OK.\n", gpio_keys[i], irq);
#endif

		gpio_export(gpio_keys[i], false);
	}

	/**************** Parst ExtKEY End ****************/

	/**************** Parst ADC Begin ****************/
	adc_chan_map = iio_channel_get_all(&pdev->dev);
	if (IS_ERR(adc_chan_map)) {
		dev_info(&pdev->dev, "no io-channels defined\n");
		adc_chan_map = NULL;
		goto fail3;
	}

	ddata->chan[0] = &adc_chan_map[0];  //saradc channel 0
	ddata->chan[1] = &adc_chan_map[1];  //saradc channel 3

	if (device_create_file(&pdev->dev, &measure_attr)) {
		EXTBRD_ERROR(" device create file failed\n");
		goto fail3;
	}

	for (i = 0; i < ARR_SIZE(ext_gpio_leds); i++) {
		if (!gpio_is_valid(ext_gpio_leds[i])) {
			 EXTBRD_ERROR("Invalid Ext gpio leds Gpio : %d\n", ext_gpio_leds[i]);
			 ret = -EINVAL;
			 goto fail4;
		}

		ret = devm_gpio_request(dev, ext_gpio_leds[i], NULL);
		if (ret != 0) {
			EXTBRD_ERROR("gpio-keys: failed to request Ext Leds GPIO %d, error %d\n",
				                          ext_gpio_leds[i], ret);
			ret = -EIO;
			goto fail4;
		}
		gpio_direction_output(ext_gpio_leds[i], GPIO_HIGH);
	}

	/* adc polling work */
	if (ddata->chan[0] && ddata->chan[1]) {
		INIT_DELAYED_WORK(&ddata->adc_poll_work, adc_key_poll);
		schedule_delayed_work(&ddata->adc_poll_work,
				      ADC_SAMPLE_JIFFIES);
	}
	/**************** Parst ADC End ****************/

	return ret;

fail4:
	device_remove_file(&pdev->dev, &measure_attr);
fail3:
	while (--i >= 0)
		devm_gpio_free(dev, gpio_keys[i]);
fail2:
	device_remove_file(&pdev->dev, &digit_tube_attrs);
fail1:
	while (--i >= 0)
		devm_gpio_free(dev, digit_gpios[i].gpio);

fail0:
	return ret;
}

static int extbrd_remove(struct platform_device *pdev)
{
	struct extbrd_drvdata *ddata = platform_get_drvdata(pdev);
	struct device *dev = &pdev->dev;
	int i;

	EXTBRD_DEBUG(" %s\n", __func__);

	if (ddata->chan[0] && ddata->chan[1])
		cancel_delayed_work_sync(&ddata->adc_poll_work);

	for (i = 0; i < ARR_SIZE(ext_gpio_leds); i++) {
		devm_gpio_free(dev, ext_gpio_leds[i]);
	}

	device_remove_file(&pdev->dev, &measure_attr);

	for (i = 0; i < EXT_KEY_NUM; i++) {
#ifdef EXTKEY_IRQ
		devm_free_irq(dev, gpio_to_irq(gpio_keys[i]), NULL);
#endif
		devm_gpio_free(dev, gpio_keys[i]);
	}

	device_remove_file(&pdev->dev, &digit_tube_attrs);

	for (i = 0; i < EXT_GPIO_NUM; i++) {
		devm_gpio_free(dev, digit_gpios[i].gpio);
	}

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
