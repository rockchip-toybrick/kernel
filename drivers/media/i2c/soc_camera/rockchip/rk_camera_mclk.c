//#define DEBUG
#include <media/v4l2-subdev.h>
#include <linux/i2c.h>
#include <linux/slab.h>
#include <linux/delay.h>
#include <linux/string.h>
#include <linux/clk.h>
#include <linux/device.h>
#include <linux/printk.h>
#include <linux/list.h>
#include <linux/mutex.h>
#include <linux/of_gpio.h>
#include <linux/platform_data/rk_isp10_platform_camera_module.h>
#include <linux/platform_data/rk_isp10_platform.h>

#include "rk_camera_mclk.h"

#define camera_debug(dev, fmt, arg...) \
		pr_debug("%s.%s: " fmt, \
			dev_driver_string(dev), __func__, ## arg)
#define camera_info(dev, fmt, arg...) \
		pr_info("%s.%s: " fmt, \
				dev_driver_string(dev), __func__, ## arg)
#define camera_warn(dev, fmt, arg...) \
		pr_warn("%s.%s WARN: " fmt, \
				dev_driver_string(dev), __func__, ## arg)
#define camera_error(dev, fmt, arg...) \
		pr_err("%s.%s(%d) ERR: " fmt, \
				dev_driver_string(dev), __func__, __LINE__, \
				## arg)

#define CAMERA_OV_GPIO_PWR "rockchip,pwr-gpio"
#define CAMERA_OV_GPIO_PWR_2ND "rockchip,pwr-2nd-gpio"
#define CAMERA_OV_GPIO_PWR_3RD "rockchip,pwr-3rd-gpio"

#define GPIO_PWR_INDEX 0
#define GPIO_PWR_2ND_INDEX 1
#define GPIO_PWR_3RD_INDEX 2

struct device_info_node  {
	struct device *dev;
	struct list_head list;
};

struct run_mclk_node {
	const char * clk_name;
	struct clk *   clk;
	unsigned long rate;
	struct list_head request;
	struct list_head enable;
};

struct run_power_node {
	int pltfrm_gpio;
	const char *label;
	enum of_gpio_flags active_low;
	struct list_head request;
	struct list_head enable;
};

static DEFINE_MUTEX(mclk_mutex);

static struct run_mclk_node run_mclk;

static struct run_power_node run_power[3];

static struct device_info_node *find_device_info_node(struct device *dev, struct list_head *head)
{
	struct list_head *pos;
	struct device_info_node *node = NULL;

	list_for_each(pos, head) {
		node = list_entry(pos, struct device_info_node, list);
		if (node->dev == dev) {
			camera_debug(dev, "find device info node ok!\n");
			goto end;
		}
	}

	node = NULL;
end:
	return node;
}

static int find_power_index(unsigned gpio)
{
	int i;
	for (i=0; i<ARRAY_SIZE(run_power); i++) {
		if (gpio == run_power[i].pltfrm_gpio)
			return i;
	}

	return -1;
}

int rk_camera_mclk_get(struct device *dev, const char *str)
{
	int ret = -1;
	struct device_info_node *node;

	mutex_lock(&mclk_mutex);
	if (run_mclk.clk_name == NULL && run_mclk.clk == NULL) {
		run_mclk.clk = clk_get(dev, str);
		if (!run_mclk.clk) {
			camera_error(dev, "get %s clock error!\n",  str);
			goto end;
		}
		camera_debug(dev, "clk_get %s ok\n", str);
		INIT_LIST_HEAD(&run_mclk.request);
		INIT_LIST_HEAD(&run_mclk.enable);
		run_mclk.clk_name =  str;
	} else if (0 != strcmp(str, run_mclk.clk_name)) {
		camera_error(dev, "mclk can't reuse %s\n", str);
		goto end;
	} else {
		camera_debug(dev, "mclk %s reuse\n", str);
	}

	node = find_device_info_node(dev, &run_mclk.request);
	if (node) {
		camera_debug(dev, "mclk is already requesed\n");
		ret = 0;
		goto end;
	}

	node = kzalloc(sizeof(struct device_info_node ), GFP_KERNEL);
	node->dev = dev;
	list_add_tail(&node->list, &run_mclk.request);

	ret = 0;

end:
	mutex_unlock(&mclk_mutex);

	return ret;
}

int rk_camera_mclk_set_rate(struct device *dev, unsigned long rate)
{
	int ret = -1;
	struct device_info_node *node;

	camera_debug(dev, "set rate!\n");

	mutex_lock(&mclk_mutex);

	node = find_device_info_node(dev, &run_mclk.request);
	if (!node)
		goto end;

	if (run_mclk.rate == 0 && list_empty(&run_mclk.enable)) {
		run_mclk.rate = rate;
		ret = 0;
		camera_debug(dev, "set rate ok!\n");
	} else {
		if (run_mclk.rate != rate)
			camera_error(dev, "rate not match, cur rate = %lu, wanted rate = %lu\n", run_mclk.rate, rate);
	}

end:
	mutex_unlock(&mclk_mutex);
	return ret;
}

int rk_camera_mclk_prepare_enable(struct device *dev)
{
	int ret, enable_flag = 0;
	struct device_info_node *node;

	mutex_lock(&mclk_mutex);

	node = find_device_info_node(dev, &run_mclk.request);
	if (!node) {
		camera_error(dev, "mclk haven't requested!\n");
		goto end;
	}

	node = find_device_info_node(dev, &run_mclk.enable);
	if (!node) {
		if (list_empty(&run_mclk.enable))
			enable_flag = 1;
		node = kzalloc(sizeof(struct device_info_node), GFP_KERNEL);
		node->dev = dev;
		list_add_tail(&node->list, &run_mclk.enable);
		camera_debug(dev, "mclk add to enable list\n");
	} else {
		camera_debug(dev, "mclk already in enable list\n");
	}

	if (enable_flag)
		clk_prepare_enable(run_mclk.clk);

	ret = 0;
end:
	mutex_unlock(&mclk_mutex);
	return ret;
}

int rk_camera_mclk_disable_unprepare(struct device *dev)
{
	int ret;
	struct device_info_node *node;

	mutex_lock(&mclk_mutex);

	node = find_device_info_node(dev, &run_mclk.request);
	if (!node) {
		camera_error(dev, "mclk haven't requested!\n");
		goto end;
	}

	node = find_device_info_node(dev, &run_mclk.enable);
	if (node) {
		list_del(&node->list);
		kfree(node);
		camera_debug(dev, "mclk drop from enable list\n");
	} else {
		camera_debug(dev, "mclk is not enable list\n");
	}

	if (list_empty(&run_mclk.enable)) {
		clk_disable_unprepare(run_mclk.clk);
		camera_debug(dev, "%s clk_disable_unprepare\n", run_mclk.clk_name);
	}

	ret = 0;
end:
	mutex_unlock(&mclk_mutex);
	return ret;
}


int rk_camera_mclk_put(struct device *dev)
{
	int ret = -1;
	struct device_info_node *node;

	mutex_lock(&mclk_mutex);

	node = find_device_info_node(dev, &run_mclk.request);
	if (!node) {
		camera_error(dev, "mclk is not requesed\n");
		goto end;
	}

	list_del(&node->list);
	kfree(node);

	if (list_empty(&run_mclk.request)) {
		camera_debug(dev, "%s clk_put\n", run_mclk.clk_name);
		clk_put(run_mclk.clk);
		memset(&run_mclk, 0x00, sizeof(run_mclk));
	}

end:
	mutex_unlock(&mclk_mutex);
	return ret;
}

int rk_camera_get_power(struct device *dev, struct device_node *np, const char *propname,
			   int index_0, enum of_gpio_flags *flags)
{
	int ret = -1, index = 0;
	struct device_info_node *node;

	if (0 != strcmp(propname, CAMERA_OV_GPIO_PWR)
		&& 0 != strcmp(propname, CAMERA_OV_GPIO_PWR_2ND)
		&& 0 != strcmp(propname, CAMERA_OV_GPIO_PWR_2ND)) {
		camera_error(dev, "power name error! name is %s\n", propname);
		return -1;
	}

	if (0 == strcmp(propname, CAMERA_OV_GPIO_PWR))
		index = GPIO_PWR_INDEX;
	else if (0 == strcmp(propname, CAMERA_OV_GPIO_PWR_2ND))
		index = GPIO_PWR_2ND_INDEX;
	else
		index = GPIO_PWR_3RD_INDEX;

	mutex_lock(&mclk_mutex);

	if (run_power[index].pltfrm_gpio == 0 && run_power[index].label == NULL) {
		run_power[index].pltfrm_gpio = of_get_named_gpio_flags(np, propname, index_0, flags);

		if (!gpio_is_valid(run_power[index].pltfrm_gpio))
			goto end;

		ret = gpio_request_one(
				run_power[index].pltfrm_gpio,
				GPIOF_DIR_OUT,
				propname);

		if (IS_ERR_VALUE(ret))
			goto end;

		camera_debug(dev, "request %s, gpio is %d\n", propname, run_power[index].pltfrm_gpio);
		INIT_LIST_HEAD(&run_power[index].enable);
		INIT_LIST_HEAD(&run_power[index].request);
		run_power[index].label = propname;
		run_power[index].active_low = *flags;
	} else if (0 != strcmp(run_power[index].label, propname) || *flags != run_power[index].active_low) {
		camera_error(dev, "gpio can't reuse %s, gpio is %d\n", propname, run_power[index].pltfrm_gpio);
		goto end;
	} else {
		camera_debug(dev, "reuse %s, gpio is %d\n", propname, run_power[index].pltfrm_gpio);
	}

	node = find_device_info_node(dev, &run_power[index].request);
	if (node) {
		camera_debug(dev, "gpio is already requesed\n");
		ret = run_power[index].pltfrm_gpio;
		goto end;
	}

	camera_debug(dev, "add dev = %p to request list\n", dev);
	node = kzalloc(sizeof(struct device_info_node ), GFP_KERNEL);
	node->dev = dev;
	list_add_tail(&node->list, &run_power[index].request);

	ret = run_power[index].pltfrm_gpio>0?run_power[index].pltfrm_gpio:-1;

end:
	mutex_unlock(&mclk_mutex);

	return ret;
}

void rk_camera_set_power_value(struct device *dev, unsigned gpio, enum pltfrm_camera_module_pin_state state)
{
	int gpio_val, index;
	struct device_info_node *node;

	mutex_lock(&mclk_mutex);

	index = find_power_index(gpio);
	if (index < 0) {
		camera_error(dev, "no power index found\n");
		goto end;
	}

	if (gpio != run_power[index].pltfrm_gpio) {
		camera_error(dev, "gpio = %d is not match pltfrm_gpio = %d\n", gpio, run_power[index].pltfrm_gpio);
		goto end;
	}
	if (!gpio_is_valid(run_power[index].pltfrm_gpio))
		goto end;

	node = find_device_info_node(dev, &run_power[index].enable);
	if (node) {
		if (state == PLTFRM_CAMERA_MODULE_PIN_STATE_ACTIVE) {
			camera_debug(dev, "gpio is already enabled\n");
			goto end;
		} else {
			list_del(&node->list);
			kfree(node);
			camera_debug(dev, "power delete form enable list\n");
		}
	} else {
		if (state == PLTFRM_CAMERA_MODULE_PIN_STATE_ACTIVE) {
			node = kzalloc(sizeof(struct device_info_node ), GFP_KERNEL);
			node->dev = dev;
			list_add_tail(&node->list, &run_power[index].enable);
			camera_debug(dev, "power add to enable list\n");
		}
	}

	if (!list_empty(&run_power[index].enable))
		gpio_val = (run_power[index].active_low == OF_GPIO_ACTIVE_LOW) ? 0 : 1;
	else
		gpio_val = (run_power[index].active_low == OF_GPIO_ACTIVE_LOW) ? 1 : 0;

	gpio_set_value(run_power[index].pltfrm_gpio, gpio_val);

	camera_debug(dev,
			"set GPIO #%d ('%s') to %s\n",
			run_power[index].pltfrm_gpio,
			run_power[index].label,
			gpio_val ? "HIGH" : "LOW");

end:
	mutex_unlock(&mclk_mutex);
}

int rk_camera_get_power_value(struct device *dev, unsigned gpio)
{
	int gpio_val = 0, index;

	mutex_lock(&mclk_mutex);

	index = find_power_index(gpio);
	if (index < 0) {
		camera_error(dev, "no power index found\n");
		goto end;
	}

	if (!gpio_is_valid(run_power[index].pltfrm_gpio))
		goto end;

	gpio_val = gpio_get_value(run_power[index].pltfrm_gpio);
	camera_debug(
		dev,
		"get GPIO #%d ('%s') is %s\n",
		run_power[index].pltfrm_gpio,
		run_power[index].label,
		gpio_val ? "HIGH" : "LOW");

end:
	mutex_unlock(&mclk_mutex);
	return gpio_val;
}

void rk_camera_power_free(struct device *dev, unsigned gpio)
{
	int index;
	struct device_info_node *node;

	mutex_lock(&mclk_mutex);

	camera_debug(dev, "...");

	index = find_power_index(gpio);
	if (index < 0) {
		camera_error(dev, "no power index found\n");
		goto end;
	}

	node = find_device_info_node(dev, &run_power[index].request);
	if (!node) {
		camera_error(dev, "gpio is not requesed\n");
		goto end;
	}

	camera_debug(dev, "drop dev = %p power from request list\n", dev);
	list_del(&node->list);
	kfree(node);

	if (list_empty(&run_power[index].request)) {
		camera_debug(dev, "request list is empty\n");
		if (gpio_is_valid(run_power[index].pltfrm_gpio))
			gpio_free(run_power[index].pltfrm_gpio);
		memset(&run_power[index], 0x00, sizeof(run_power[0]));
	}

end:
	mutex_unlock(&mclk_mutex);
}


