#ifndef __RK_CAMERA_MCLK_H__
#define __RK_CAMERA_MCLK_H__

int rk_camera_mclk_get(struct device *dev, const char *str);
int rk_camera_mclk_set_rate(struct device *dev, unsigned long rate);
int rk_camera_mclk_prepare_enable(struct device *dev);
int rk_camera_mclk_disable_unprepare(struct device *dev);
int rk_camera_mclk_put(struct device *dev);

#endif
