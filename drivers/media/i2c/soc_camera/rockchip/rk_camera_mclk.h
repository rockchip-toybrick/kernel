#ifndef __RK_CAMERA_MCLK_H__
#define __RK_CAMERA_MCLK_H__

int rk_camera_mclk_get(struct device *dev, const char *str);
int rk_camera_mclk_set_rate(struct device *dev, unsigned long rate);
int rk_camera_mclk_prepare_enable(struct device *dev);
int rk_camera_mclk_disable_unprepare(struct device *dev);
int rk_camera_mclk_put(struct device *dev);
int rk_camera_get_power(struct device *dev, struct device_node *np, const char *propname,
			   int index, enum of_gpio_flags *flags);
void rk_camera_set_power_value(struct device *dev, unsigned gpio, enum pltfrm_camera_module_pin_state state);
int rk_camera_get_power_value(struct device *dev, unsigned gpio);
void rk_camera_power_free(struct device *dev, unsigned gpio);

#endif
