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

struct device_info_node  {
	struct device *dev;
	struct list_head list;
};

struct run_mclk_node {
	const char		*clk_name;
	struct clk		*clk;
	unsigned long		rate;
	struct list_head	request;
	struct list_head	enable;
};

static DEFINE_MUTEX(mclk_mutex);

static struct run_mclk_node run_mclk;

static struct device_info_node *find_device_info_node(struct device *dev,
						      struct list_head *head)
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

int rk_camera_mclk_get(struct device *dev, const char *str)
{
	int ret = -1;
	struct device_info_node *node;

	mutex_lock(&mclk_mutex);
	if (!run_mclk.clk_name && !run_mclk.clk) {
		run_mclk.clk = clk_get(dev, str);
		if (!run_mclk.clk) {
			camera_error(dev, "get %s clock error!\n",  str);
			goto end;
		}
		camera_debug(dev, "clk_get %s ok\n", str);
		INIT_LIST_HEAD(&run_mclk.request);
		INIT_LIST_HEAD(&run_mclk.enable);
		run_mclk.clk_name =  str;
	} else if (strcmp(str, run_mclk.clk_name) != 0) {
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

	node = kzalloc(sizeof(*node), GFP_KERNEL);
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

	camera_debug(dev, "set rate = %lu!\n", rate);

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
			camera_error(dev, "rate not match, cur rate = %lu,"
				     "wanted rate = %lu\n",
				     run_mclk.rate, rate);
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
		node = kzalloc(sizeof(*node), GFP_KERNEL);
		node->dev = dev;
		list_add_tail(&node->list, &run_mclk.enable);
		camera_debug(dev, "mclk add to enable list\n");
	} else {
		camera_debug(dev, "mclk already in enable list\n");
	}

	if (enable_flag) {
		camera_debug(dev, "mclk start to enable!\n");
		clk_set_rate(run_mclk.clk, run_mclk.rate);
		clk_prepare_enable(run_mclk.clk);
	}

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
		camera_debug(dev, "%s clk_disable_unprepare\n",
			     run_mclk.clk_name);
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

