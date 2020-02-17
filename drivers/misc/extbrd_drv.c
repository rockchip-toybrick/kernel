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
#define EXTBRD_DEBUG(s, ...) printk("### " s, ##__VA_ARGS__)
#else
#define EXTBRD_DEBUG(s, ...) do {} while(0)
#endif
#define EXTBRD_ERROR(s, ...) printk("*** " s, ##__VA_ARGS__)

/* Board Resource definition */
#define BOARD_UNKNOWN		0x0
#define BOARD_TOYBRICK		0x1
#define BOARD_EAI610 		0x2

#define DIGIT_TUBE_NUM		8
#define EXT_ITEM_MAX_NUM 	9

static const struct of_device_id of_extbrd_match[] = {
	{ .compatible = "toybrick-extboard", },
	{},
};
MODULE_DEVICE_TABLE(of, of_extbrd_match);

struct extbrd_drvdata
{
	int result[EXT_ADCCHAN_NUM];
	struct delayed_work adc_poll_work;
	struct iio_channel *chan[EXT_ADCCHAN_NUM];

	int *ext_gpios;
	int *ext_keys;
	int *ext_leds;

	int has_extgpios;
	int has_extkeys;
	int has_extleds;
	int has_adckeys;
	int gpio_num;
	int key_num;
	int led_num;

	int board_type;
};

static int tube_0[] = {
	GPIO_LOW, GPIO_LOW, GPIO_LOW, GPIO_LOW,
	GPIO_LOW, GPIO_LOW, GPIO_HIGH, GPIO_HIGH,
};

static int tube_1[] = {
	GPIO_HIGH, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
	GPIO_HIGH, GPIO_HIGH, GPIO_HIGH, GPIO_HIGH,
};

static int tube_2[] = {
	GPIO_LOW, GPIO_LOW, GPIO_HIGH, GPIO_LOW,
	GPIO_HIGH, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
};

static int tube_3[] = {
	GPIO_LOW, GPIO_LOW, GPIO_LOW, GPIO_LOW,
	GPIO_HIGH, GPIO_HIGH, GPIO_LOW, GPIO_HIGH,
};

static int tube_4[] = {
	GPIO_HIGH, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
	GPIO_HIGH, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
};

static int tube_5[] = {
	GPIO_LOW, GPIO_HIGH, GPIO_LOW, GPIO_LOW,
	GPIO_HIGH, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
};

static int tube_6[] = {
	GPIO_LOW, GPIO_HIGH, GPIO_LOW, GPIO_LOW,
	GPIO_LOW, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
};

static int tube_7[] = {
	GPIO_LOW, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
	GPIO_HIGH, GPIO_HIGH, GPIO_HIGH, GPIO_HIGH,
};

static int tube_8[] = {
	GPIO_LOW, GPIO_LOW, GPIO_LOW, GPIO_LOW,
	GPIO_LOW, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
};

static int tube_9[] = {
	GPIO_LOW, GPIO_LOW, GPIO_LOW, GPIO_LOW,
	GPIO_HIGH, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
};

static int tube_e[] = {
	GPIO_LOW, GPIO_LOW, GPIO_HIGH, GPIO_LOW,
	GPIO_LOW, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
};

static int tube_o[] = {
	GPIO_LOW, GPIO_LOW, GPIO_HIGH, GPIO_HIGH,
	GPIO_HIGH, GPIO_LOW, GPIO_LOW, GPIO_HIGH,
};

static int tube_set_gpio(struct device *dev, int *values)
{
	struct extbrd_drvdata *ddata = dev_get_drvdata(dev);
	int i;

	BUG_ON(ddata->gpio_num != DIGIT_TUBE_NUM);

	for (i = 0; i < ddata->gpio_num; i++) {
		gpio_set_value(ddata->ext_gpios[i], values[i]);
	}

	return 0;
}

static int display_digit_tube(struct device *dev, const char ch)
{
	switch (ch) {
		case '0':
			tube_set_gpio(dev, tube_0);
			EXTBRD_DEBUG("show digit 0\n");
			break;
		case '1':
			tube_set_gpio(dev, tube_1);
			EXTBRD_DEBUG("show digit 1\n");
			break;
		case '2':
			tube_set_gpio(dev, tube_2);
			EXTBRD_DEBUG("show digit 2\n");
			break;
		case '3':
			tube_set_gpio(dev, tube_3);
			EXTBRD_DEBUG("show digit 3\n");
			break;
		case '4':
			tube_set_gpio(dev, tube_4);
			EXTBRD_DEBUG("show digit 4\n");
			break;
		case '5':
			tube_set_gpio(dev, tube_5);
			EXTBRD_DEBUG("show digit 5\n");
			break;
		case '6':
			tube_set_gpio(dev, tube_6);
			EXTBRD_DEBUG("show digit 6\n");
			break;
		case '7':
			tube_set_gpio(dev, tube_7);
			EXTBRD_DEBUG("show digit 7\n");
			break;
		case '8':
			tube_set_gpio(dev, tube_8);
			EXTBRD_DEBUG("show digit 8\n");
			break;
		case '9':
			tube_set_gpio(dev, tube_9);
			EXTBRD_DEBUG("show digit 9\n");
			break;
		case 'o':
			tube_set_gpio(dev, tube_o);
			EXTBRD_DEBUG("show 'o' !\n");
			break;
		case 'e':
		default:
			tube_set_gpio(dev, tube_e);
			EXTBRD_ERROR("Not suppored Character !\n");
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
	display_digit_tube(dev, buf[0]);

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
	int board_type;
	int *ext_leds;

	ddata = container_of(work, struct extbrd_drvdata, adc_poll_work.work);
	board_type = ddata->board_type;
	ext_leds = ddata->ext_leds;

	for (i = 0; i < EXT_ADCCHAN_NUM; i++) {
		result = ext_keys_adc_iio_read(ddata, ddata->chan[i]);
		if (result > INVALID_ADVALUE && result < EMPTY_DEFAULT_ADVALUE) { //iio read invalid adc result, do nothing!
			if (ddata->result[i] != result) {
				//EXTBRD_DEBUG("Chan[%d] : %d\n", i, result);
				if (result >= ADC_VALUE_LOW && result < DRIFT_DEFAULT_ADVALUE) {
					gpio_set_value(ext_leds[i], GPIO_LOW);
					if (board_type == BOARD_TOYBRICK) {
						gpio_set_value(ext_leds[2 + i], GPIO_LOW);
					}
				} else {
					gpio_set_value(ext_leds[i], GPIO_HIGH);
					if (board_type == BOARD_TOYBRICK) {
						gpio_set_value(ext_leds[2 + i], GPIO_HIGH);
					}
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

/*
 ********************* DTS **********************
	extbrd: extbrd {
		compatible = "xxx-extboard";
		io-channels = <&saradc x>, <&saradc x>;

		ext-gpios = <&gpioX X GPIO_ACTIVE_HIGH>,
					<&gpioX X GPIO_ACTIVE_HIGH>,
					...
					<&gpioX X GPIO_ACTIVE_HIGH>;

		ext-keys = <&gpioX X GPIO_ACTIVE_HIGH>,
					<&gpioX X GPIO_ACTIVE_HIGH>;

		ext-leds = <&gpioX X GPIO_ACTIVE_HIGH>,
					<&gpioX X GPIO_ACTIVE_HIGH>;
	};
 */

static int extbrd_parse_dt(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct extbrd_drvdata *ddata = NULL;
	struct device_node *node = pdev->dev.of_node;
	enum of_gpio_flags flag;
	int ret = 0;
	int n, i;
	int *ext_gpios;
	int *ext_keys;
	int *ext_leds;

	ddata = platform_get_drvdata(pdev);
	if (!ddata) {
		EXTBRD_ERROR("No drvdata\n");
		return -ENOMEM;
	}

	/* Get ExtGpio Property */
	n = of_gpio_named_count(node, "ext-gpios");
	if (n > 0 && n < EXT_ITEM_MAX_NUM) {
		ddata->ext_gpios = devm_kzalloc(dev, n * sizeof(int), GFP_KERNEL);
		if (!ddata) {
			EXTBRD_ERROR("fail to alloc.\n");
			ret = -ENOMEM;
			return ret;
		}

		ext_gpios = ddata->ext_gpios;
		for (i = 0; i < n; i++) {
            ext_gpios[i] = of_get_named_gpio_flags(node, "ext-gpios", i,
                                 &flag);
            if (!gpio_is_valid(ext_gpios[i])) {
            	EXTBRD_ERROR("EXT GPIO(%d) is invalid\n", ext_gpios[i]);
                ret = -EINVAL;
                return ret;
            }
        }
	}

	ddata->gpio_num = n;
	if (ddata->gpio_num <= 0) {
		EXTBRD_ERROR("no ext gpio defined\n");
		ddata->has_extgpios = 0;
	} else {
		ddata->has_extgpios = 1;
	}

	/* Get ExtKey Property */
	n = of_gpio_named_count(node, "ext-keys");
	if (n > 0 && n < EXT_ITEM_MAX_NUM) {
		ddata->ext_keys = devm_kzalloc(dev, n * sizeof(int), GFP_KERNEL);
		if (!ddata) {
			EXTBRD_ERROR("fail to alloc.\n");
			ret = -ENOMEM;
			return ret;
		}

		ext_keys = ddata->ext_keys;
		for (i = 0; i < n; i++) {
            ext_keys[i] = of_get_named_gpio_flags(node, "ext-keys", i,
                                 &flag);
            if (!gpio_is_valid(ext_keys[i])) {
                EXTBRD_ERROR("EXT Key(%d) is invalid\n", ext_keys[i]);
                ret = -EINVAL;
                return ret;
            }
        }
	}

	ddata->key_num = n;
	if (ddata->key_num <= 0) {
		EXTBRD_ERROR("no ext key defined\n");
		ddata->has_extkeys = 0;
	} else {
		ddata->has_extkeys = 1;
	}

	/* Get ExtLeds Property */
	n = of_gpio_named_count(node, "ext-leds");
	if (n > 0 && n < EXT_ITEM_MAX_NUM) {
		ddata->ext_leds = devm_kzalloc(dev, n * sizeof(int), GFP_KERNEL);
		if (!ddata) {
			EXTBRD_ERROR("fail to alloc.\n");
			ret = -ENOMEM;
			return ret;
		}

		ext_leds = ddata->ext_leds;
		for (i = 0; i < n; i++) {
            ext_leds[i] = of_get_named_gpio_flags(node, "ext-leds", i,
                                 &flag);
            if (!gpio_is_valid(ext_leds[i])) {
                EXTBRD_ERROR("EXT Led(%d) is invalid\n", ext_leds[i]);
                ret = -EINVAL;
                return ret;
            }
        }
	}

	ddata->led_num = n;
	if (ddata->led_num <= 0) {
		EXTBRD_ERROR("no ext led defined\n");
		ddata->has_extleds = 0;
	} else {
		ddata->has_extleds = 1;
	}

	return ret;
}

static int get_board_type(struct platform_device *pdev)
{
	struct device_node *np;
	int board_type;

	if (pdev->dev.of_node) {
		np = pdev->dev.of_node;
		if (of_device_is_compatible(np, "toybrick-extboard")) {
			EXTBRD_DEBUG("This is Prod / Prop extboard.\n");
			board_type = BOARD_TOYBRICK;
		} else if (of_device_is_compatible(np, "eai610-extboard")) {
			EXTBRD_DEBUG("This is EAI610 extboard.\n");
			board_type = BOARD_EAI610;
		} else {
			EXTBRD_ERROR("This is Unsupport extbord!\n");
			board_type = BOARD_UNKNOWN;
		}
	}

	return board_type;
}

static int extbrd_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	int ret = 0;
	int i;
	char gpiokey_name[16];
	int irq;
	struct extbrd_drvdata *ddata = NULL;
	int *ext_gpios;
	int *ext_keys;
	int *ext_leds;
	int board_type;

	EXTBRD_DEBUG("%s\n", __func__);

	ddata = devm_kzalloc(dev, sizeof(struct extbrd_drvdata), GFP_KERNEL);
	if (!ddata) {
		ret = -ENOMEM;
		return ret;
	}
	platform_set_drvdata(pdev, ddata);
	dev_set_drvdata(&pdev->dev, ddata);

	board_type = get_board_type(pdev);
	if (board_type <= 0) {
		ret = -EINVAL;
		return ret;
	}
	ddata->board_type = board_type;

	ret = extbrd_parse_dt(pdev);
	if (ret < 0) {
		EXTBRD_ERROR("Extbrd parse dt error\n");
		ret = -EINVAL;
		return ret;
	}

	EXTBRD_DEBUG("Num of GPIO: %d, KEY: %d, LED: %d\n", ddata->gpio_num,
		ddata->key_num, ddata->led_num);

	if (ddata->has_extgpios) {
		ext_gpios = ddata->ext_gpios;
		for (i = 0; i < ddata->gpio_num; i++) {
			ret = devm_gpio_request(dev, ext_gpios[i], NULL);
			if (ret != 0) {
				EXTBRD_ERROR("Request gpio : %d fail\n", ext_gpios[i]);
				ret = -EIO;
				return ret;
			}

			//low : light on, high: light off
			gpio_direction_output(ext_gpios[i], GPIO_HIGH);
			gpio_export(ext_gpios[i], true);
		}

		if (board_type == BOARD_EAI610 && ddata->gpio_num == DIGIT_TUBE_NUM) {
			if(device_create_file(&pdev->dev, &digit_tube_attrs)) {
				EXTBRD_ERROR("Device Create digit_tube_attrs file fail.\n");
				ret = -EEXIST;
				return ret;
			}
		}
	} else {
		EXTBRD_ERROR("Have No Ext Gpios.\n");
	}

	if (ddata->has_extkeys) {
		ext_keys = ddata->ext_keys;
		for (i = 0; i < ddata->key_num; i++) {
			if (board_type == BOARD_TOYBRICK)
				break;
			if (!gpio_is_valid(ext_keys[i])) {
				EXTBRD_ERROR("Invalid gpio : %d\n", ext_keys[i]);
				ret = -EINVAL;
				return ret;
			}

			snprintf(gpiokey_name, 16, "extkey%d", i);
			ret = devm_gpio_request(dev, ext_keys[i], gpiokey_name);
			if (ret != 0) {
				EXTBRD_ERROR("gpio-keys: failed to request GPIO %d, error %d\n",
											  ext_keys[i], ret);
				ret = -EIO;
				return ret;
			}

			ret = gpio_direction_input(ext_keys[i]);
			if (ret < 0) {
				EXTBRD_ERROR("gpio-keys: failed to configure input direction for GPIO %d, error %d\n",
					ext_keys[i], ret);
				return ret;
			}

			irq = gpio_to_irq(ext_keys[i]);
			if (irq < 0) {
				ret = irq;
				EXTBRD_ERROR("gpio-keys: Unable to get irq number for GPIO %d, error %d\n",
						ext_keys[i], ret);
				return ret;
			}

			gpio_export(ext_keys[i], true);
		}
	} else {
		EXTBRD_ERROR("Have No Ext Key.\n");
	}

	adc_chan_map = iio_channel_get_all(&pdev->dev);
	if (IS_ERR(adc_chan_map)) {
		EXTBRD_ERROR("no io-channels defined\n");
		adc_chan_map = NULL;
		return -EIO;
	} else {
		ddata->has_adckeys = 1;
	}

	if (ddata->has_adckeys == 1 && ddata->has_extleds == 1) {
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

		ext_leds = ddata->ext_leds;
		for (i = 0; i < ddata->led_num; i++) {
			if (!gpio_is_valid(ext_leds[i])) {
			 	EXTBRD_ERROR("Invalid Ext gpio leds Gpio : %d\n", ext_leds[i]);
			 	ret = -EINVAL;
			 	goto fail1;
			}

			ret = devm_gpio_request(dev, ext_leds[i], NULL);
			if (ret != 0) {
				EXTBRD_ERROR("gpio-keys: failed to request Ext Leds GPIO %d, error %d\n",
							ext_leds[i], ret);
				ret = -EIO;
				goto fail1;
			}
			gpio_direction_output(ext_leds[i], GPIO_HIGH);
			gpio_export(ext_leds[i], true);
		}

		/* adc polling work */
		if (ddata->chan[0] && ddata->chan[1]) {
			INIT_DELAYED_WORK(&ddata->adc_poll_work, adc_key_poll);
			schedule_delayed_work(&ddata->adc_poll_work,
				      ADC_SAMPLE_JIFFIES);
		}
	} else {
		EXTBRD_ERROR("Have No Ext adc and No leds\n");
	}

	return ret;
fail1:
	device_remove_file(&pdev->dev, &measure0_attr);
		device_remove_file(&pdev->dev, &measure1_attr);

fail0:
	iio_channel_release_all(adc_chan_map);

	return ret;
}

static int extbrd_remove(struct platform_device *pdev)
{
	struct extbrd_drvdata *ddata = platform_get_drvdata(pdev);

	EXTBRD_DEBUG(" %s\n", __func__);

	if (ddata->chan[0] && ddata->chan[1])
		cancel_delayed_work_sync(&ddata->adc_poll_work);

	device_remove_file(&pdev->dev, &measure0_attr);
	device_remove_file(&pdev->dev, &measure1_attr);

	iio_channel_release_all(adc_chan_map);

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
		.name	= "extboard",
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
MODULE_DESCRIPTION("ExtBoard Driver");
MODULE_LICENSE("GPL");
MODULE_ALIAS("platform:extboard");
