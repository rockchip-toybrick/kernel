// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2024 Rockchip Electronics Co., Ltd
 */

#include <linux/module.h>
#include <linux/regmap.h>
#include <linux/acpi.h>
#include <linux/delay.h>

#include <linux/iio/iio.h>
#include <linux/iio/triggered_buffer.h>
#include <linux/iio/trigger_consumer.h>
#include <linux/iio/buffer.h>
#include <linux/iio/sysfs.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/of_gpio.h>
#include <linux/regulator/consumer.h>
#include <linux/pm_runtime.h>

#include "icm42680.h"

static int icm42680_read_raw(struct iio_dev *indio_dev,
					struct iio_chan_spec const *chan,
					int *val, int *val2, long mask);

static int icm42680_write_raw_get_fmt(struct iio_dev *indio_dev,
					struct iio_chan_spec const *chan,
					long mask);

static int icm42680_set_scale(struct icm42680_data *data,
					enum icm42680_sensor_type t,
					int scale, int uscale);

static int icm42680_write_raw(struct iio_dev *indio_dev,
					struct iio_chan_spec const *chan,
					int val, int val2, long mask);

static int icm42680_set_odr(struct icm42680_data *data,
					enum icm42680_sensor_type t,
					int odr);

#define ICM42680_CHANNEL(_type, _axis, _index) {		\
	.type = _type,						\
	.modified = 1,						\
	.channel2 = _axis,					\
	.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),		\
	.info_mask_shared_by_type = BIT(IIO_CHAN_INFO_SCALE) |  \
		BIT(IIO_CHAN_INFO_SAMP_FREQ),			\
	.scan_index = _index,					\
	.scan_type = {						\
		.sign = 's',					\
		.realbits = 16,					\
		.storagebits = 16,				\
		.endianness = IIO_BE,				\
	},							\
}

#define ICM42680_TEMP_CHANNEL(_type, _index) {			\
	.type = _type,						\
	.channel = -1,						\
	.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),		\
	.scan_index = _index,					\
	.scan_type = {						\
		.sign = 's',					\
		.realbits = 8,					\
		.storagebits = 8,				\
		.endianness = IIO_BE,				\
	},							\
}

static const struct iio_chan_spec icm42680_channels[] = {
	ICM42680_CHANNEL(IIO_ACCEL, IIO_MOD_X, ICM42680_SCAN_ACCEL_X),
	ICM42680_CHANNEL(IIO_ACCEL, IIO_MOD_Y, ICM42680_SCAN_ACCEL_Y),
	ICM42680_CHANNEL(IIO_ACCEL, IIO_MOD_Z, ICM42680_SCAN_ACCEL_Z),
	ICM42680_CHANNEL(IIO_ANGL_VEL, IIO_MOD_X, ICM42680_SCAN_GYRO_X),
	ICM42680_CHANNEL(IIO_ANGL_VEL, IIO_MOD_Y, ICM42680_SCAN_GYRO_Y),
	ICM42680_CHANNEL(IIO_ANGL_VEL, IIO_MOD_Z, ICM42680_SCAN_GYRO_Z),
	ICM42680_TEMP_CHANNEL(IIO_TEMP, ICM42680_SCAN_TEMP),
	IIO_CHAN_SOFT_TIMESTAMP(ICM42680_SCAN_TIMESTAMP),
};

static const unsigned long icm42680_scan_masks[] = {
	/* 3-axis accel + temp */
	BIT(ICM42680_SCAN_ACCEL_X)
		| BIT(ICM42680_SCAN_ACCEL_Y)
		| BIT(ICM42680_SCAN_ACCEL_Z)
		| BIT(ICM42680_SCAN_TEMP),
	/* 3-axis gyro + temp */
	BIT(ICM42680_SCAN_GYRO_X)
		| BIT(ICM42680_SCAN_GYRO_Y)
		| BIT(ICM42680_SCAN_GYRO_Z)
		| BIT(ICM42680_SCAN_TEMP),
	/* 6-axis accel + gyro + temp */
	BIT(ICM42680_SCAN_ACCEL_X)
		| BIT(ICM42680_SCAN_ACCEL_Y)
		| BIT(ICM42680_SCAN_ACCEL_Z)
		| BIT(ICM42680_SCAN_GYRO_X)
		| BIT(ICM42680_SCAN_GYRO_Y)
		| BIT(ICM42680_SCAN_GYRO_Z)
		| BIT(ICM42680_SCAN_TEMP),
	0,
};

struct icm42680_regs {
	u8 data;
	u8 config;
	u8 config_odr_mask;
	u8 config_fsr_mask;
};

static struct icm42680_regs icm42680_regs[] = {
	[ICM42680_ACCEL] = {
		.data	= REG_ACCEL_DATA_X0_UI,
		.config	= REG_ACCEL_CONFIG0,
		.config_odr_mask = BIT_ACCEL_ODR_MASK,
		.config_fsr_mask = BIT_ACCEL_UI_FS_SEL_MASK,
	},
	[ICM42680_GYRO] = {
		.data	= REG_GYRO_DATA_X0_UI,
		.config	= REG_GYRO_CONFIG0,
		.config_odr_mask = BIT_GYRO_ODR_MASK,
		.config_fsr_mask = BIT_GYRO_UI_FS_SEL_MASK,
	},
	[ICM42680_TEMP] = {
		.data = REG_TEMP_DATA0_UI,
		.config = REG_TEMP_CONFIG0,
		.config_odr_mask = 0,
		.config_fsr_mask = 0,
	},
};

static IIO_CONST_ATTR(in_accel_sampling_frequency_available,
			"1 3 6 12 25 50 100 200 400 800");
static IIO_CONST_ATTR(in_anglvel_sampling_frequency_available,
			"12 25 50 100 200 400 800");
static IIO_CONST_ATTR(in_accel_scale_available,
			"0.000598 0.001196 0.002393 0.004785");
static IIO_CONST_ATTR(in_anglvel_scale_available,
			"0.000133231 0.000266462 0.000532113 0.001064225");

static struct attribute *icm42680_attrs[] = {
	&iio_const_attr_in_accel_sampling_frequency_available.dev_attr.attr,
	&iio_const_attr_in_anglvel_sampling_frequency_available.dev_attr.attr,
	&iio_const_attr_in_accel_scale_available.dev_attr.attr,
	&iio_const_attr_in_anglvel_scale_available.dev_attr.attr,
	NULL,
};

static const struct attribute_group icm42680_attrs_group = {
	.attrs = icm42680_attrs,
};

static const struct iio_info icm42680_info = {
	.read_raw = icm42680_read_raw,
	.write_raw = icm42680_write_raw,
	.write_raw_get_fmt = &icm42680_write_raw_get_fmt,
	.attrs = &icm42680_attrs_group,
};

struct icm42680_odr {
	u8 bits;
	int odr;
	int divider;		//us
};

struct icm42680_odr_item {
	const struct icm42680_odr *tbl;
	int num;
};

static const struct icm42680_odr icm42680_accel_odr[] = {
	{BIT_SENSOR_ODR_1600HZ, 1600, 1600},
	{BIT_SENSOR_ODR_800HZ, 800, -1250},
	{BIT_SENSOR_ODR_400HZ, 400, -2500},
	{BIT_SENSOR_ODR_200HZ, 200, -5000},
	{BIT_SENSOR_ODR_100HZ, 100, -10000},
	{BIT_SENSOR_ODR_50HZ, 50, -20000},
	{BIT_SENSOR_ODR_25HZ, 25, -40000},
	{BIT_SENSOR_ODR_12HZ, 12, -80000},
	{BIT_SENSOR_ODR_6HZ, 6, -160000},
	{BIT_SENSOR_ODR_3HZ, 3, -320000},
	{BIT_SENSOR_ODR_1HZ, 1, -640000},
};

static const struct icm42680_odr icm42680_gyro_odr[] = {
	{BIT_SENSOR_ODR_1600HZ, 1600, 1600},
	{BIT_SENSOR_ODR_800HZ, 800, -1250},
	{BIT_SENSOR_ODR_400HZ, 400, -2500},
	{BIT_SENSOR_ODR_200HZ, 200, -5000},
	{BIT_SENSOR_ODR_100HZ, 100, -10000},
	{BIT_SENSOR_ODR_50HZ, 50, -20000},
	{BIT_SENSOR_ODR_25HZ, 25, -40000},
	{BIT_SENSOR_ODR_12HZ, 12, -80000},
};

static const struct  icm42680_odr_item icm42680_odr_table[] = {
	[ICM42680_ACCEL] = {
		.tbl	= icm42680_accel_odr,
		.num	= ARRAY_SIZE(icm42680_accel_odr),
	},
	[ICM42680_GYRO] = {
		.tbl	= icm42680_gyro_odr,
		.num	= ARRAY_SIZE(icm42680_gyro_odr),
	},
};

struct icm42680_scale {
	u8 bits;
	int scale;
	int uscale;
};

struct icm42680_scale_item {
	const struct icm42680_scale *tbl;
	int num;
	int format;
};

/*
 * this is the accel scale translated from dynamic range plus/minus
 * {2, 4, 8, 16} to m/s^2
 * Formula: Range / Sampling Accuracy * Gravity Acceleration
 * For ±2g full scale, 598 = 4(-2g, -1g, 1g, 2g) / 2^16 * 9.8(1g) * 1000000
 * For ±4g full scale, 1196 = 8 / 2^16 * 9.8 * 1000000
 */
static const struct icm42680_scale icm42680_accel_scale[] = {
	{BIT_ACCEL_FSR_2G, 0, 598},
	{BIT_ACCEL_FSR_4G, 0, 1196},
	{BIT_ACCEL_FSR_8G, 0, 2393},
	{BIT_ACCEL_FSR_16G, 0, 4785},
};

/*
 * this is the gyro scale translated from dynamic range plus/minus
 * {250, 500, 1000, 2000} to rad/s
 * Formula: Range / sampling accuracy * Radians
 * For ±2000DPS full scale, 1064225 = 4000 / 2^16 * (π/180) * 1000000000
 */
static const struct icm42680_scale icm42680_gyro_scale[] = {
	{ BIT_GYRO_FSR_250DPS, 0, 133231},
	{ BIT_GYRO_FSR_500DPS, 0, 266462},
	{ BIT_GYRO_FSR_1000DPS, 0, 532113},
	{ BIT_GYRO_FSR_2000DPS, 0, 1064225},
};

static const struct  icm42680_scale_item icm42680_scale_table[] = {
	[ICM42680_ACCEL] = {
		.tbl	= icm42680_accel_scale,
		.num	= ARRAY_SIZE(icm42680_accel_scale),
		.format = IIO_VAL_INT_PLUS_MICRO,
	},
	[ICM42680_GYRO] = {
		.tbl	= icm42680_gyro_scale,
		.num	= ARRAY_SIZE(icm42680_gyro_scale),
		.format = IIO_VAL_INT_PLUS_NANO,
	},
};

const struct regmap_config icm42680_regmap_config = {
	.reg_bits = 8,
	.val_bits = 8,
};
EXPORT_SYMBOL(icm42680_regmap_config);

static enum icm42680_sensor_type icm42680_to_sensor(enum iio_chan_type iio_type)
{
	switch (iio_type) {
	case IIO_ACCEL:
		return ICM42680_ACCEL;
	case IIO_ANGL_VEL:
		return ICM42680_GYRO;
	case IIO_TEMP:
		return ICM42680_TEMP;
	default:
		return -EINVAL;
	}
}

static int icm42680_get_scale(struct icm42680_data *data,
					enum icm42680_sensor_type t,
					int *scale, int *uscale)
{
	int i, ret, val;

	if (t < 0 || (t >= ARRAY_SIZE(icm42680_scale_table)))
		return -EINVAL;

	ret = regmap_read(data->regmap, icm42680_regs[t].config, &val);
	if (ret < 0)
		return ret;

	val = ((val) & (icm42680_regs[t].config_fsr_mask)) >>
		__builtin_ctzl(icm42680_regs[t].config_fsr_mask);

	for (i = 0; i < icm42680_scale_table[t].num; i++)
		if (icm42680_scale_table[t].tbl[i].bits == val) {

			*scale = icm42680_scale_table[t].tbl[i].scale;
			*uscale = icm42680_scale_table[t].tbl[i].uscale;

			return icm42680_scale_table[t].format;
		}

	return -EINVAL;
}

static int icm42680_get_odr(struct icm42680_data *data,
					enum icm42680_sensor_type t,
					int *odr)
{
	int i, val, ret;

	if (t < 0 || t >= ARRAY_SIZE(icm42680_odr_table))
		return 0;

	ret = regmap_read(data->regmap, icm42680_regs[t].config, &val);
	if (ret < 0)
		return ret;

	val = ((val) & (icm42680_regs[t].config_odr_mask)) >>
		__builtin_ctzl(icm42680_regs[t].config_odr_mask);

	for (i = 0; i < icm42680_odr_table[t].num; i++)
		if (val == icm42680_odr_table[t].tbl[i].bits)
			break;

	if (i >= icm42680_odr_table[t].num)
		return -EINVAL;

	*odr = icm42680_odr_table[t].tbl[i].odr;

	return 0;
}

static int icm42680_get_data(struct icm42680_data *data,
					enum icm42680_sensor_type t,
					int axis, int *val)
{
	u8 reg;
	int ret;
	__be16 sample;

	if (t == ICM42680_TEMP)
		reg = icm42680_regs[t].data;
	else
		reg = icm42680_regs[t].data + (axis - IIO_MOD_X) * sizeof(sample);

	ret = regmap_bulk_read(data->regmap, reg, (u8 *)&sample, 2);
	if (ret)
		return -EINVAL;

	*val = (short)be16_to_cpup(&sample);
	dev_info(regmap_get_device(data->regmap),
			"icm42680get_data: ch: %d, aix: %d, reg: %x, val: %x\n",
			t, axis, sample, *val);

	return ret;
}

static int icm42680_read_raw(struct iio_dev *indio_dev,
				 struct iio_chan_spec const *chan,
				 int *val, int *val2, long mask)
{
	int ret;
	struct icm42680_data *data = iio_priv(indio_dev);

	switch (mask) {
	case IIO_CHAN_INFO_RAW:
		ret = iio_device_claim_direct_mode(indio_dev);
		if (ret)
			return ret;
		mutex_lock(&data->lock);
		icm42680_get_data(data, icm42680_to_sensor(chan->type), chan->channel2, val);
		mutex_unlock(&data->lock);
		iio_device_release_direct_mode(indio_dev);
		return IIO_VAL_INT;
	case IIO_CHAN_INFO_SCALE:
		mutex_lock(&data->lock);
		ret = icm42680_get_scale(data, icm42680_to_sensor(chan->type), val, val2);
		mutex_unlock(&data->lock);
		return ret;
	case IIO_CHAN_INFO_SAMP_FREQ:
		mutex_lock(&data->lock);
		ret = icm42680_get_odr(data, icm42680_to_sensor(chan->type), val);
		mutex_unlock(&data->lock);
		return ret < 0 ? ret : IIO_VAL_INT;
	default:
		return -EINVAL;
	}

	return 0;
}

static int icm42680_write_raw(struct iio_dev *indio_dev,
					struct iio_chan_spec const *chan,
					int val, int val2, long mask)
{
	int ret = 0;
	struct icm42680_data *data = iio_priv(indio_dev);

	mutex_lock(&data->lock);
	ret = iio_device_claim_direct_mode(indio_dev);
	if (ret)
		goto error_write_raw_unlock;

	switch (mask) {
	case IIO_CHAN_INFO_SCALE:
		ret = icm42680_set_scale(data,
					 icm42680_to_sensor(chan->type),
					 val,
					 val2);
		break;
	case IIO_CHAN_INFO_SAMP_FREQ:
		ret = icm42680_set_odr(data,
					icm42680_to_sensor(chan->type),
					val);
		break;
	default:
		ret = -EINVAL;
	}

error_write_raw_unlock:
	iio_device_release_direct_mode(indio_dev);
	mutex_unlock(&data->lock);
	return ret;
}

static int icm42680_write_raw_get_fmt(struct iio_dev *indio_dev,
					struct iio_chan_spec const *chan,
					long mask)
{
	switch (mask) {
	case IIO_CHAN_INFO_SCALE:
		switch (chan->type) {
		case IIO_ANGL_VEL:
			return IIO_VAL_INT_PLUS_NANO;
		default:
			return IIO_VAL_INT_PLUS_MICRO;
		}
	default:
		return IIO_VAL_INT_PLUS_MICRO;
	}

	return -EINVAL;
}

static const char *icm42680_match_acpi_device(struct device *dev)
{
	const struct acpi_device_id *id;

	id = acpi_match_device(dev->driver->acpi_match_table, dev);
	if (!id)
		return NULL;

	return dev_name(dev);
}

static void icm42680_chip_uninit(struct icm42680_data *data)
{
	icm42680_set_mode(data, ICM42680_GYRO, false);
	icm42680_set_mode(data, ICM42680_ACCEL, false);
}

static void icm42680_disable_vdd_reg(void *_data)
{
	struct icm42680_data *st = _data;
	const struct device *dev = regmap_get_device(st->regmap);
	int ret;

	ret = regulator_disable(st->vdd_supply);
	if (ret)
		dev_err(dev, "failed to disable vdd error %d\n", ret);
}

static int icm42680_gyro_on(struct icm42680_data *data)
{
	int ret;
	unsigned int cmd;

	// Enable Gyro
	ret = regmap_read(data->regmap, REG_PWR_MGMT_0, &cmd);
	if (ret < 0)
		return ret;

	cmd |= BIT_PWR_MGMT0_GYRO(INV_ICM42680_SENSOR_MODE_LOW_NOISE);  // Gyro on in LNM
	usleep_range(50, 51);
	ret = regmap_write(data->regmap, REG_PWR_MGMT_0, cmd);
	if (ret < 0)
		return ret;
	usleep_range(200, 201);

	return ret;
}

static int icm42680_gyro_off(struct icm42680_data *data)
{
	int ret;
	unsigned int cmd;

	ret = regmap_read(data->regmap, REG_PWR_MGMT_0, &cmd);
	if (ret < 0)
		return ret;

	cmd &= (~(BIT_PWR_MGMT0_GYRO(INV_ICM42680_SENSOR_MODE_LOW_NOISE)));	 // Gyro off
	msleep(80);
	ret = regmap_write(data->regmap, REG_PWR_MGMT_0, cmd);
	if (ret < 0)
		return ret;
	msleep(200);
	return ret;
}

static int icm42680_accel_on(struct icm42680_data *data)
{
	int ret;
	unsigned int cmd;

	ret = regmap_read(data->regmap, REG_PWR_MGMT_0, &cmd);
	if (ret < 0)
		return ret;
	cmd |= (BIT_PWR_MGMT0_ACCEL(INV_ICM42680_SENSOR_MODE_LOW_NOISE));	  // Accel on in LNM
	ret = regmap_write(data->regmap, REG_PWR_MGMT_0, cmd);
	if (ret < 0)
		return ret;
	usleep_range(200, 201);

	return ret;
}

static int __icm42680_set_fsr(struct icm42680_data *data,
							 enum icm42680_sensor_type t, int sel)
{
	int ret;
	unsigned int cmd;

	if (t == ICM42680_ACCEL) {
		ret = regmap_read(data->regmap, REG_ACCEL_CONFIG0, &cmd);
		if (ret < 0)
			return ret;

		if (FIELD_GET(BIT_ACCEL_UI_FS_SEL_MASK, cmd) == sel)
			return 0;

		ret = regmap_update_bits(data->regmap, REG_ACCEL_CONFIG0,
							BIT_ACCEL_UI_FS_SEL_MASK,
							FIELD_PREP(BIT_ACCEL_UI_FS_SEL_MASK, sel));
	} else if (t == ICM42680_GYRO) {
		ret = regmap_read(data->regmap, REG_GYRO_CONFIG0, &cmd);
		if (ret < 0)
			return ret;

		if (FIELD_GET(BIT_GYRO_UI_FS_SEL_MASK, cmd) == sel)
			return 0;

		ret = regmap_update_bits(data->regmap, REG_GYRO_CONFIG0,
							BIT_GYRO_UI_FS_SEL_MASK,
							FIELD_PREP(BIT_GYRO_UI_FS_SEL_MASK, sel));
	} else {
		return -EINVAL;
	}

	return ret;
}

static int icm42680_set_scale(struct icm42680_data *data,
					enum icm42680_sensor_type t,
					int scale, int uscale)
{
	int i;

	if (t >= ARRAY_SIZE(icm42680_scale_table))
		return -EINVAL;

	for (i = 0; i < icm42680_scale_table[t].num; i++)
		if (icm42680_scale_table[t].tbl[i].uscale == uscale &&
			icm42680_scale_table[t].tbl[i].scale == scale)
			break;

	if (i == icm42680_scale_table[t].num)
		return -EINVAL;

	dev_info(regmap_get_device(data->regmap), "set scale t: %d, bit: %x\n",
		 t, icm42680_scale_table[t].tbl[i].bits);
	return __icm42680_set_fsr(data, t, icm42680_scale_table[t].tbl[i].bits);
}

static int __icm42680_set_odr(struct icm42680_data *data,
						enum icm42680_sensor_type t,
						int sel, int divider)
{
	int ret;
	unsigned int cmd;

	if (t == ICM42680_ACCEL) {
		ret = regmap_read(data->regmap, REG_ACCEL_CONFIG0, &cmd);
		if (ret < 0)
			return ret;

		if (FIELD_GET(BIT_ACCEL_ODR_MASK, cmd) == sel)
			return 0;

		cmd &= (~BIT_ACCEL_ODR_MASK);
		cmd |= sel;
		ret = regmap_write(data->regmap, REG_ACCEL_CONFIG0, cmd);
		if (!ret) {
			data->chip_config.accel_odr = sel;
			/* Select the largest of multiple sampling periods */
			data->period_divider =
				(data->period_divider && data->period_divider > divider) ?
			data->period_divider : divider;
		}
	} else if (t == ICM42680_GYRO) {
		ret = regmap_read(data->regmap, REG_GYRO_CONFIG0, &cmd);
		if (ret < 0)
			return ret;

		if (FIELD_GET(BIT_GYRO_ODR_MASK, cmd) == sel)
			return 0;

		cmd &= (~BIT_GYRO_ODR_MASK);
		cmd |= sel;
		ret = regmap_write(data->regmap, REG_GYRO_CONFIG0, cmd);
		if (!ret) {
			data->chip_config.gyro_odr = sel;
			/* Select the largest of multiple sampling periods */
			data->period_divider =
				(data->period_divider && data->period_divider > divider) ?
			data->period_divider : divider;
		}
	} else {
		return -EINVAL;
	}

	return ret;
}

static int icm42680_set_odr(struct icm42680_data *data,
					enum icm42680_sensor_type t,
					int odr)
{
	int i;

	if (t == ICM42680_ACCEL)
		data->accel_frequency = odr;

	if (t == ICM42680_GYRO)
		data->gyro_frequency = odr;

	if (t >= ARRAY_SIZE(icm42680_odr_table))
		return -EINVAL;

	for (i = 0; i < icm42680_odr_table[t].num; i++)
		if (icm42680_odr_table[t].tbl[i].odr == odr)
			break;

	if (i >= icm42680_odr_table[t].num)
		return -EINVAL;

	dev_info(regmap_get_device(data->regmap), "set odr t: %d, bit: %x\n", t,
		 icm42680_odr_table[t].tbl[i].bits);

	return __icm42680_set_odr(data, t, icm42680_odr_table[t].tbl[i].bits,
						icm42680_odr_table[t].tbl[i].divider);
}

static int icm42680_accel_off(struct icm42680_data *data)
{
	int ret;
	unsigned int cmd;

	ret = regmap_read(data->regmap, REG_PWR_MGMT_0, &cmd);
	if (ret < 0)
		return ret;
	cmd &= (~(BIT_PWR_MGMT0_ACCEL(INV_ICM42680_SENSOR_MODE_LOW_NOISE)));	  // Accel on in LNM
	usleep_range(50, 51);
	ret = regmap_write(data->regmap, REG_PWR_MGMT_0, cmd);
	if (ret < 0)
		return ret;
	usleep_range(200, 201);
	return ret;
}

static int icm42680_chip_init(struct icm42680_data *data, icm42680_bus_setup bus_setup)
{
	int ret;
	unsigned int regval;
	struct device *dev = regmap_get_device(data->regmap);

	// who am i
	ret = regmap_read(data->regmap, REG_WHO_AM_I, &regval);
	if (ret)
		return ret;
	dev_info(dev, "i am: %x, icm42680: %x\n", regval, BIT_I_AM_ICM42680);
	if (regval != BIT_I_AM_ICM42680)
		return -EINVAL;

	// reset
	ret = regmap_write(data->regmap, REG_SIGNAL_PATH_RESET, BIT_SOFT_RESET_CHIP_CONFIG);
	if (ret < 0)
		return ret;

	usleep_range(1000, 2000);

	/* check reset done bit in interrupt status */
	ret = regmap_read(data->regmap, REG_INT_STATUS, &regval);
	if (ret)
		return ret;
	if (!(regval & BIT_INT_STATUS_RESET_DONE)) {
		dev_err(dev, "reset done status bit missing (%x)\n", regval);
		return -ENODEV;
	}
	// Configure the INT1 GPIO as input
	ret = gpio_direction_input(data->int1_gpio);
	if (ret < 0)
		dev_err(dev, "gpio_direction_input  failed!\r\n");

	/* set chip bus configuration */
	ret = bus_setup(data);
	if (ret) {
		dev_err(dev, "bus_setup failed!\r\n");
		return ret;
	}

	/* FIFO count is reported in records (1 record = 16 bytes for gyro+accel+tempsensor data) */
	ret = regmap_update_bits(data->regmap, REG_INTF_CONFIG0,
				BIT_FIFO_COUNT_REC_FIFO_COUNT_REC,
					BIT_FIFO_COUNT_REC_FIFO_COUNT_REC);
	if (ret)
		return ret;

	/* FIFO data in big-endian (default) */
	ret = regmap_update_bits(data->regmap, REG_INTF_CONFIG0,
				BIT_FIFO_COUNT_REC_FIFO_COUNT_ENDIAN,
				BIT_FIFO_COUNT_REC_FIFO_COUNT_ENDIAN);
	if (ret)
		return ret;

	/* sensor data in big-endian (default) */
	ret = regmap_update_bits(data->regmap, REG_INTF_CONFIG0,
				BIT_FIFO_COUNT_REC_SENSOR_DATA_ENDIAN,
				BIT_FIFO_COUNT_REC_SENSOR_DATA_ENDIAN);
	if (ret)
		return ret;

	ret = icm42680_set_mode(data, ICM42680_ACCEL, true);
	if (ret < 0) {
		dev_err(dev, "icm42680_set_mode ICM42680_ACCEL failed!\r\n");
		return ret;
	}

	ret = icm42680_set_mode(data, ICM42680_GYRO, true);
	if (ret < 0) {
		dev_err(dev, "icm42680_set_mode ICM42680_GYRO failed!\r\n");
		return ret;
	}

	// init gyro and accel para
	ret = icm42680_set_odr(data, ICM42680_ACCEL, icm42680_accel_odr[0].odr);
	if (ret < 0) {
		dev_err(dev, "icm42680_set_odr ICM42680_ACCEL failed!\r\n");
		return ret;
	}

	ret = icm42680_set_odr(data, ICM42680_GYRO, icm42680_gyro_odr[0].odr);
	if (ret < 0) {
		dev_err(dev, "icm42680_set_odr ICM42680_GYRO failed!\r\n");
		return ret;
	}

	ret = icm42680_set_scale(data, ICM42680_ACCEL,
					icm42680_accel_scale[0].scale,
					icm42680_accel_scale[0].uscale);
	if (ret < 0) {
		dev_err(dev, "icm42680_set_scale ICM42680_ACCEL failed!\r\n");
		return ret;
	}

	ret = icm42680_set_scale(data, ICM42680_GYRO,
					icm42680_gyro_scale[0].scale,
					icm42680_gyro_scale[0].uscale);
	if (ret < 0) {
		dev_err(dev, "icm42680_set_scale ICM42680_GYRO failed!\r\n");
		return ret;
	}

	ret = regmap_write(data->regmap, REG_INT_CONFIG_REG, data->irq_mask);
	if (ret < 0)
		return ret;

	dev_info(dev, "icm42680_init success!\r\n");

	return ret;
}

/**
 * icm42680_mreg_single_write() - Single byte write to MREG area.
 * @st: struct icm42680_data.
 * @addr: MREG register address including bank in upper byte.
 * @data: data to write.
 *
 * Return: 0 when successful.
 */
int icm42680_mreg_single_write(struct icm42680_data *st, int addr, u32 data)
{
	int ret;
	u32 reg_pwr_mgmt_0;

	ret = regmap_read(st->regmap, REG_PWR_MGMT_0, &reg_pwr_mgmt_0);
	if (ret)
		return ret;

	//TODO: set idle

	ret = regmap_write(st->regmap, REG_BLK_SEL_W, (addr >> 8) & 0xff);
	usleep_range(ICM42680_BLK_SEL_WAIT_US,
			ICM42680_BLK_SEL_WAIT_US + 1);
	if (ret)
		goto restore_bank;

	ret = regmap_write(st->regmap, REG_MADDR_W, addr & 0xff);
	usleep_range(ICM42680_MADDR_WAIT_US,
			ICM42680_MADDR_WAIT_US + 1);
	if (ret)
		goto restore_bank;

	ret = regmap_write(st->regmap, REG_M_W, data);
	usleep_range(ICM42680_M_RW_WAIT_US,
			ICM42680_M_RW_WAIT_US + 1);
	if (ret)
		goto restore_bank;

restore_bank:
	ret |= regmap_write(st->regmap, REG_BLK_SEL_W, 0);
	usleep_range(ICM42680_BLK_SEL_WAIT_US,
			ICM42680_BLK_SEL_WAIT_US + 1);

	ret |= regmap_write(st->regmap, REG_PWR_MGMT_0, reg_pwr_mgmt_0);

	return ret;
}

/**
 * icm42680_mreg_read() - Multiple byte read from MREG area.
 * @st: struct icm42680_data.
 * @addr: MREG register start address including bank in upper byte.
 * @len: length to read in byte.
 * @data: pointer to store read data.
 *
 * Return: 0 when successful.
 */
int icm42680_mreg_read(struct icm42680_data *st, int addr, int len, u32 *data)
{
	int ret;
	u32 reg_pwr_mgmt_0;

	ret = regmap_read(st->regmap, REG_PWR_MGMT_0, &reg_pwr_mgmt_0);
	if (ret)
		return ret;

	//TODO: set idle

	ret = regmap_write(st->regmap, REG_BLK_SEL_R, (addr >> 8) & 0xff);
	usleep_range(ICM42680_BLK_SEL_WAIT_US,
			ICM42680_BLK_SEL_WAIT_US + 1);
	if (ret)
		goto restore_bank;

	ret = regmap_write(st->regmap, REG_MADDR_R, addr & 0xff);
	usleep_range(ICM42680_MADDR_WAIT_US,
			ICM42680_MADDR_WAIT_US + 1);
	if (ret)
		goto restore_bank;

	ret = regmap_read(st->regmap, REG_M_R, data);
	usleep_range(ICM42680_M_RW_WAIT_US,
			ICM42680_M_RW_WAIT_US + 1);
	if (ret)
		goto restore_bank;

restore_bank:
	ret |= regmap_write(st->regmap, REG_BLK_SEL_R, 0);
	usleep_range(ICM42680_BLK_SEL_WAIT_US,
			ICM42680_BLK_SEL_WAIT_US + 1);

	ret |= regmap_write(st->regmap, REG_PWR_MGMT_0, reg_pwr_mgmt_0);

	return ret;
}

int icm42680_set_mode(struct icm42680_data *data,
				enum icm42680_sensor_type t,
				bool mode)
{
	int ret;

	if (t == ICM42680_GYRO) {
		if (mode)
			ret = icm42680_gyro_on(data);
		else
			ret = icm42680_gyro_off(data);
	} else if (t == ICM42680_ACCEL) {
		if (mode)
			ret = icm42680_accel_on(data);
		else
			ret = icm42680_accel_off(data);
	} else {
		return -EINVAL;
	}

	return ret;
}

int icm42680_core_probe(struct regmap *regmap,
						int irq, const char *name,
						int chip_type, icm42680_bus_setup bus_setup)
{
	struct iio_dev *indio_dev;
	struct icm42680_data *data;
	struct device *dev = regmap_get_device(regmap);
	int ret;
	struct irq_data *desc;
	int irq_type;

	indio_dev = devm_iio_device_alloc(dev, sizeof(*data));
	if (!indio_dev)
		return -ENOMEM;

	data = iio_priv(indio_dev);
	memset(data, 0, sizeof(struct icm42680_data));
	mutex_init(&data->lock);
	data->chip_type = chip_type;
	data->powerup_count = 0;
	data->irq = irq;
	data->regmap = regmap;

	/* get the node */
	data->node = of_find_node_by_name(NULL, "icm42680");
	if (data->node == NULL)
		dev_err(dev, "ic2 node not find!\n");

	data->int1_gpio = of_get_named_gpio(data->node, "int1-gpio", 0);
	if (data->int1_gpio < 0) {
		dev_err(dev, "Could not get int1_gpio!\n");
		return -EINVAL;
	}

	desc = irq_get_irq_data(irq);
	if (!desc) {
		dev_err(dev, "Could not find IRQ %d\n", irq);
		return -EINVAL;
	}

	irq_type = irqd_get_trigger_type(desc);
	if (!irq_type)
		irq_type = IRQF_TRIGGER_RISING;

	if (irq_type == IRQF_TRIGGER_RISING) {
		data->irq_mask = BIT_ONLY_INT1_ACTIVE_HIGH;
	} else if (irq_type == IRQF_TRIGGER_FALLING) {
		data->irq_mask = BIT_ONLY_INT1_ACTIVE_LOW;
	} else {
		dev_err(dev, "Invalid interrupt type 0x%x specified\n",
			irq_type);
		return -EINVAL;
	}

	data->vdd_supply = devm_regulator_get(dev, "vcc_avdd");
	if (IS_ERR(data->vdd_supply)) {
		dev_err(dev, "Could not find vdd_avdd!\n");
		return PTR_ERR(data->vdd_supply);
	}

	ret = regulator_enable(data->vdd_supply);
	if (ret) {
		dev_err(dev, "regulator_enable failed!\n");
		return ret;
	}

	ret = devm_add_action_or_reset(dev, icm42680_disable_vdd_reg, data);
	if (ret) {
		dev_err(dev, "devm_add_action_or_reset failed!\n");
		return ret;
	}

	ret = icm42680_chip_init(data, bus_setup);
	if (ret < 0) {
		dev_err(dev, "icm42680_chip_init fail\n");
		return ret;
	}

	dev_set_drvdata(dev, indio_dev);
	if (!name && ACPI_HANDLE(dev))
		name = icm42680_match_acpi_device(dev);

	indio_dev->dev.parent = dev;
	indio_dev->channels = icm42680_channels;
	indio_dev->num_channels = ARRAY_SIZE(icm42680_channels);
	indio_dev->available_scan_masks = icm42680_scan_masks;
	indio_dev->name = name;
	indio_dev->info = &icm42680_info;
	indio_dev->modes = INDIO_BUFFER_TRIGGERED;

	ret = devm_iio_triggered_buffer_setup(dev, indio_dev, iio_pollfunc_store_time,
						  icm42680_read_fifo, NULL);
	if (ret < 0)
		goto uninit;

	ret = icm42680_probe_trigger(indio_dev, irq_type);
	if (ret) {
		dev_err(dev, "trigger probe fail %d\n", ret);
		goto uninit;
	}

	ret = devm_iio_device_register(dev, indio_dev);
	if (ret < 0) {
		dev_err(dev, "devm_iio_device_register fail\n");
		goto uninit;
	}

	ret = pm_runtime_set_active(dev);
	if (ret)
		return ret;

	return 0;
uninit:
	icm42680_chip_uninit(data);
	return ret;
}
EXPORT_SYMBOL_GPL(icm42680_core_probe);

/*
 * System resume gets the system back on and restores the sensors state.
 * Manually put runtime power management in system active state.
 */
static int __maybe_unused sleep_icm42680_resume(struct device *dev)
{
	struct icm42680_data *st =  iio_priv(dev_get_drvdata(dev));
	struct iio_dev *indio_dev = dev_get_drvdata(dev);
	int ret;

	mutex_lock(&st->lock);

	ret = regulator_enable(st->vdd_supply);
	if (ret)
		goto out_unlock;

	usleep_range(3000, 4000);

	pm_runtime_disable(dev);

	pm_runtime_set_active(dev);

	pm_runtime_enable(dev);

	icm42680_set_odr(st, ICM42680_GYRO, st->gyro_frequency_buff);

	icm42680_set_odr(st, ICM42680_ACCEL, st->accel_frequency_buff);

	ret = icm42680_set_enable(indio_dev, 1);
	if (ret)
		goto out_unlock;

	devm_regulator_put(st->vdd_supply);
out_unlock:
	mutex_unlock(&st->lock);
	return ret;
}

/*
 * Suspend saves sensors state and turns everything off.
 * Check first if runtime suspend has not already done the job.
 */
static int __maybe_unused sleep_icm42680_suspend(struct device *dev)
{
	struct icm42680_data *st =  iio_priv(dev_get_drvdata(dev));
	struct iio_dev *indio_dev = dev_get_drvdata(dev);
	int ret;

	mutex_lock(&st->lock);

	st->gyro_frequency_buff = st->gyro_frequency;

	st->accel_frequency_buff = st->accel_frequency;

	if (pm_runtime_suspended(dev)) {
		ret = 0;
		goto out_unlock;
	}

	ret = icm42680_set_enable(indio_dev, 0);
	if (ret)
		goto out_unlock;

	regulator_disable(st->vdd_supply);

	devm_regulator_put(st->vdd_supply);

out_unlock:
	mutex_unlock(&st->lock);
	return ret;
}

const struct dev_pm_ops icm42680_pm_ops = {
	SET_SYSTEM_SLEEP_PM_OPS(sleep_icm42680_suspend, sleep_icm42680_resume)
};
EXPORT_SYMBOL_GPL(icm42680_pm_ops);

void icm42680_core_remove(struct device *dev)
{
	struct iio_dev *indio_dev = dev_get_drvdata(dev);
	struct icm42680_data *data = iio_priv(indio_dev);

	icm42680_chip_uninit(data);
}
EXPORT_SYMBOL_GPL(icm42680_core_remove);

MODULE_AUTHOR("Hangyu Li <hangyu.li@rock-chips.com>");
MODULE_DESCRIPTION("ICM42680 I2C driver");
MODULE_LICENSE("GPL");
