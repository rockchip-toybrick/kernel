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

#define ARR_SIZE(a) (sizeof(a) / sizeof((a)[0]))

/* Board Resource definition */
static int board_type;
#define BOARD_EAI610 	0x1
#define BOARD_PROD		0x2
#define BOARD_PROP		0x4

#define EXT_DIGIT_GPIOS
#define EXT_GPIO_KEYS
#define EXT_ADC

static const struct of_device_id of_extbrd_match[] = {
	{ .compatible = "eai610-extboard", },
	{ .compatible = "prod-extboard", },
	{ .compatible = "prop-extboard", },
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
	{RK_GPIO(2, 2), "TUBE_A"},	//GPIO2_A2
	{RK_GPIO(2, 3), "TUBE_B"},	//GPIO2_A3
	{RK_GPIO(2, 4), "TUBE_C"},	//GPIO2_A4
	{RK_GPIO(2, 5), "TUBE_D"},	//GPIO2_A5
	{RK_GPIO(2, 6), "TUBE_E"},	//GPIO2_A6
	{RK_GPIO(1, 23), "TUBE_F"},	//GPIO1_C7
	{RK_GPIO(1, 22), "TUBE_G"},	//GPIO1_C6
	{RK_GPIO(1, 24), "TUBE_DP"},//GPIO1_D0
};

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
#endif /* End of EXT_DIGIT_GPIOS */

#ifdef EXT_GPIO_KEYS
static int *gpio_keys;

static int eai610_gpio_keys[] = {
	RK_GPIO(2, 12),
	RK_GPIO(4, 24),
};

#define EXT_KEY_NUM  	ARR_SIZE(eai610_gpio_keys)
#endif /* End of EXT_GPIO_KEYS */

#ifdef EXT_ADC
#define ADC_VALUE_LOW		0
static struct iio_channel *adc_chan_map;

static int *ext_gpio_leds;
static int ext_gpio_leds_num;

static int eai610_ext_gpio_leds[] = {
	RK_GPIO(4, 29), //GPIO4_D5
	RK_GPIO(4, 26), //GPIO4_D2
};

static int prod_ext_gpio_leds[] = {
	RK_GPIO(0, 5), //GPIO0_A5
	RK_GPIO(1, 9), //GPIO1_B1
	RK_GPIO(1, 10), //GPIO1_B2
	RK_GPIO(0, 6), //GPIO1_A6
};
static int prop_ext_gpio_leds[] = {
	RK_GPIO(1, 8), //GPIO1_B0
	RK_GPIO(1, 9), //GPIO1_B1
	RK_GPIO(1, 10), //GPIO1_B2
	RK_GPIO(1, 7),  //GPIO1_A7
};
#define GPIO_LEDS_NUM  ARR_SIZE(prod_ext_gpio_leds)

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
					if (board_type == BOARD_PROD || board_type == BOARD_PROP) {
						gpio_set_value(ext_gpio_leds[2 + i], GPIO_LOW);
					}
				} else {
					gpio_set_value(ext_gpio_leds[i], GPIO_HIGH);
					if (board_type == BOARD_PROD || board_type == BOARD_PROP) {
						gpio_set_value(ext_gpio_leds[2 + i], GPIO_HIGH);
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
	struct device_node *np;

	EXTBRD_DEBUG("%s\n", __func__);

	if (pdev->dev.of_node) {
		np = pdev->dev.of_node;
		if (of_device_is_compatible(np, "prod-extboard")) {
			EXTBRD_DEBUG("This is Prod extboard.\n");
			board_type = BOARD_PROD;
#ifdef EXT_GPIO_KEYS
			gpio_keys = NULL;
#endif
#ifdef EXT_ADC
			ext_gpio_leds = prod_ext_gpio_leds;
			ext_gpio_leds_num = ARR_SIZE(prod_ext_gpio_leds);
#endif
		} else if (of_device_is_compatible(np, "prop-extboard")) {
			EXTBRD_DEBUG("This is Prop extboard.\n");
			board_type = BOARD_PROP;
#ifdef EXT_GPIO_KEYS
			gpio_keys = NULL;
#endif
#ifdef EXT_ADC
			ext_gpio_leds = prop_ext_gpio_leds;
			ext_gpio_leds_num = ARR_SIZE(prop_ext_gpio_leds);
#endif
		} else if (of_device_is_compatible(np, "eai610-extboard")) {
			EXTBRD_DEBUG("This is EAI610 extboard.\n");
			board_type = BOARD_EAI610;
#ifdef EXT_GPIO_KEYS
			gpio_keys = eai610_gpio_keys;
#endif
#ifdef EXT_ADC
			ext_gpio_leds = eai610_ext_gpio_leds;
			ext_gpio_leds_num = ARR_SIZE(eai610_ext_gpio_leds);
#endif
		} else {
			EXTBRD_ERROR("Unsupport extbord!\n");
			ret = -EINVAL;
			goto fail;
		}
	}

	ddata = devm_kzalloc(dev, sizeof(struct extbrd_drvdata), GFP_KERNEL);
	if (!ddata) {
		ret = -ENOMEM;
		return ret;
	}
	platform_set_drvdata(pdev, ddata);
	dev_set_drvdata(&pdev->dev, ddata);

	/**************** Parst ExtGPIO Begin ****************/
#ifdef EXT_DIGIT_GPIOS
	if (board_type == BOARD_EAI610) {
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
			gpio_direction_output(digit_gpios[i].gpio, GPIO_HIGH);
		}
		if(device_create_file(&pdev->dev, &digit_tube_attrs)) {
			EXTBRD_ERROR("Device Create digit_tube_attrs file fail.\n");
			ret = -EEXIST;
			return ret;
		}
	}
#endif /* End of EXT_DIGIT_GPIOS */

	/**************** Parst ExtGPIO End ****************/

	/**************** Parst ExtKEY Begin ****************/
#ifdef EXT_GPIO_KEYS
	EXTBRD_DEBUG("%s %d\n", __func__, __LINE__);
	if (gpio_keys != NULL) {
		for (i = 0; i < EXT_KEY_NUM; i++) {
			if (board_type == BOARD_PROP || board_type == BOARD_PROD)
				break;
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

			gpio_export(gpio_keys[i], true);
		}
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

	for (i = 0; i < ext_gpio_leds_num; i++) {
		if (!gpio_is_valid(ext_gpio_leds[i])) {
			 EXTBRD_ERROR("Invalid Ext gpio leds Gpio : %d\n", ext_gpio_leds[i]);
			 ret = -EINVAL;
			 goto fail0;
		}

		ret = devm_gpio_request(dev, ext_gpio_leds[i], NULL);
		if (ret != 0) {
			EXTBRD_ERROR("gpio-keys: failed to request Ext Leds GPIO %d, error %d\n",
				                          ext_gpio_leds[i], ret);
			ret = -EIO;
			goto fail0;
		}
		gpio_direction_output(ext_gpio_leds[i], GPIO_HIGH);
		gpio_export(ext_gpio_leds[i], true);
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
fail:

	return ret;
}

static int extbrd_remove(struct platform_device *pdev)
{
#ifdef EXT_ADC
	struct extbrd_drvdata *ddata = platform_get_drvdata(pdev);
	struct device *dev = &pdev->dev;
	int i;
#endif

	EXTBRD_DEBUG(" %s\n", __func__);

#ifdef EXT_ADC
	if (ddata->chan[0] && ddata->chan[1])
		cancel_delayed_work_sync(&ddata->adc_poll_work);

	for (i = 0; i < GPIO_LEDS_NUM; i++) {
		devm_gpio_free(dev, ext_gpio_leds[i]);
	}

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
