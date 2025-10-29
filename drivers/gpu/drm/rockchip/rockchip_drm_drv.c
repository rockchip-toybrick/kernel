// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) Fuzhou Rockchip Electronics Co.Ltd
 * Author:Mark Yao <mark.yao@rock-chips.com>
 *
 * based on exynos_drm_drv.c
 */

#include <linux/dma-buf-cache.h>
#include <linux/dma-mapping.h>
#include <linux/dma-iommu.h>
#include <linux/genalloc.h>
#include <linux/pm_runtime.h>
#include <linux/module.h>
#include <linux/of_address.h>
#include <linux/of_graph.h>
#include <linux/of_platform.h>
#include <linux/clk.h>
#include <linux/component.h>
#include <linux/console.h>
#include <linux/iommu.h>
#include <linux/kthread.h>
#include <linux/of_reserved_mem.h>
#include <uapi/linux/sched/types.h>

#include <drm/drm_debugfs.h>
#include <drm/drm_drv.h>
#include <drm/drm_displayid.h>
#include <drm/drm_fb_helper.h>
#include <drm/drm_gem_cma_helper.h>
#include <drm/drm_gem_framebuffer_helper.h>
#include <drm/drm_of.h>
#include <drm/drm_probe_helper.h>
#include <drm/drm_vblank.h>

#include "rockchip_drm_drv.h"
#include "rockchip_drm_fb.h"
#include "rockchip_drm_fbdev.h"
#include "rockchip_drm_gem.h"
#include "rockchip_drm_logo.h"

#include "../drm_crtc_internal.h"

#define CREATE_TRACE_POINTS
#include "rockchip_drm_trace.h"

#define DRIVER_NAME	"rockchip"
#define DRIVER_DESC	"RockChip Soc DRM"
#define DRIVER_DATE	"20140818"
#define DRIVER_MAJOR	3
#define DRIVER_MINOR	0

#if IS_ENABLED(CONFIG_DRM_ROCKCHIP_VVOP)
static bool is_support_iommu = (_Bool)false;
#else
static bool is_support_iommu = (_Bool)true;
#endif
static bool iommu_reserve_map;

static struct drm_driver rockchip_drm_driver;

static unsigned int drm_debug;
module_param_named(debug, drm_debug, int, 0600);

static inline bool rockchip_drm_debug_enabled(enum rockchip_drm_debug_category category)
{
	return (drm_debug & (u32)category) != 0U;
}

static void rockchip_drm_dbg_print(const struct device *dev, enum rockchip_drm_debug_category category,
				   bool show_thread, struct va_format *vaf)
{
	if (rockchip_drm_debug_enabled(category)) {
		if (dev) {
			if (show_thread) {
				dev_printk(KERN_DEBUG, dev, "%s %pV\n", current->comm, vaf);
			} else {
				dev_printk(KERN_DEBUG, dev, "%pV\n", vaf);
			}
		} else {
			if (show_thread) {
				(void)printk(KERN_DEBUG "%s %pV\n", current->comm, vaf);
			} else {
				(void)printk(KERN_DEBUG "%pV\n", vaf);
			}
		}
	}

	if (category == VOP_DEBUG_VSYNC) {
		trace_rockchip_drm_dbg_vsync(vaf);
	} else if (category == VOP_DEBUG_IOMMU_MAP) {
		trace_rockchip_drm_dbg_iommu(vaf);
	} else {
		trace_rockchip_drm_dbg_common(vaf);
	}
}

__printf(3, 4)
void rockchip_drm_dbg(const struct device *dev,
		      enum rockchip_drm_debug_category category,
		      const char *format, ...)
{
	struct va_format vaf;
	va_list args;

	va_start(args, format);
	vaf.fmt = format;
	vaf.va = &args;

	rockchip_drm_dbg_print(dev, category, (_Bool)false, &vaf);

	va_end(args);
}

__printf(3, 4)
void rockchip_drm_dbg_thread_info(const struct device *dev,
				  enum rockchip_drm_debug_category category,
				  const char *format, ...)
{
	struct va_format vaf;
	va_list args;

	va_start(args, format);
	vaf.fmt = format;
	vaf.va = &args;

	rockchip_drm_dbg_print(dev, category, (_Bool)true, &vaf);

	va_end(args);
}

const char *rockchip_drm_modifier_to_string(uint64_t modifier)
{
	const char *ret;

	switch (modifier) {
	case DRM_FORMAT_MOD_ROCKCHIP_TILED(ROCKCHIP_TILED_BLOCK_SIZE_8x8):
		ret = "_TILE-8x8";
		break;
	case DRM_FORMAT_MOD_ROCKCHIP_TILED(ROCKCHIP_TILED_BLOCK_SIZE_4x4_MODE0):
		ret = "_TILE-4x4-M0";
		break;
	case DRM_FORMAT_MOD_ROCKCHIP_TILED(ROCKCHIP_TILED_BLOCK_SIZE_4x4_MODE1):
		ret = "_TILE-4x4-M1";
		break;
	case DRM_FORMAT_MOD_ROCKCHIP_RFBC(ROCKCHIP_RFBC_BLOCK_SIZE_64x4):
		ret = "_RFBC-64x4";
		break;
	default:
		if ((modifier & (u64)AFBC_FORMAT_MOD_BLOCK_SIZE_32x8) != 0ULL) {
			ret = "_AFBC-32x8";
		} else if ((modifier & (u64)AFBC_FORMAT_MOD_BLOCK_SIZE_16x16) != 0ULL) {
			ret = "_AFBC-16x16";
		} else {
			ret = "";
		}
		break;
	}

	return ret;
}
EXPORT_SYMBOL(rockchip_drm_modifier_to_string);

/**
 * rockchip_drm_wait_vact_end
 * @crtc: CRTC to enable line flag
 * @mstimeout: millisecond for timeout
 *
 * Wait for vact_end line flag irq or timeout.
 *
 * Returns:
 * Zero on success, negative errno on failure.
 */
int rockchip_drm_wait_vact_end(struct drm_crtc *crtc, unsigned int mstimeout)
{
	struct rockchip_drm_private *priv;
	int pipe, ret = 0;

	if (!crtc) {
		return -ENODEV;
	}

	if (mstimeout <= 0U) {
		return -EINVAL;
	}

	priv = crtc->dev->dev_private;
	pipe = (int)drm_crtc_index(crtc);

	if (priv != NULL && pipe >= 0 && pipe < ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL && priv->crtc_funcs[pipe]->wait_vact_end != NULL) {
		ret = priv->crtc_funcs[pipe]->wait_vact_end(crtc, mstimeout);
	}

	return ret;
}
EXPORT_SYMBOL(rockchip_drm_wait_vact_end);

void drm_mode_convert_to_split_mode(struct drm_display_mode *mode)
{
	u16 hactive, hfp, hsync, hbp;

	hactive = mode->hdisplay;
	hfp = mode->hsync_start - mode->hdisplay;
	hsync = mode->hsync_end - mode->hsync_start;
	hbp = mode->htotal - mode->hsync_end;

	mode->clock *= 2;
	mode->crtc_clock *= 2;
	mode->hdisplay = (u16)(int)((int)hactive * 2);
	mode->hsync_start = (u16)(int)((int)mode->hdisplay + (int)hfp * 2);
	mode->hsync_end = (u16)(int)((int)mode->hsync_start + (int)hsync * 2);
	mode->htotal = (u16)(int)((int)mode->hsync_end + (int)hbp * 2);
	drm_mode_set_name(mode);
}
EXPORT_SYMBOL(drm_mode_convert_to_split_mode);

void drm_mode_convert_to_origin_mode(struct drm_display_mode *mode)
{
	u16 hactive, hfp, hsync, hbp;

	hactive = mode->hdisplay;
	hfp = mode->hsync_start - mode->hdisplay;
	hsync = mode->hsync_end - mode->hsync_start;
	hbp = mode->htotal - mode->hsync_end;

	mode->clock /= 2;
	mode->crtc_clock /= 2;
	mode->hdisplay = (u16)(int)((int)hactive / 2);
	mode->hsync_start = (u16)(int)((int)mode->hdisplay + (int)hfp / 2);
	mode->hsync_end = (u16)(int)((int)mode->hsync_start + (int)hsync / 2);
	mode->htotal = (u16)(int)((int)mode->hsync_end + (int)hbp / 2);
}
EXPORT_SYMBOL(drm_mode_convert_to_origin_mode);

/**
 * drm_connector_oob_hotplug_event - Report out-of-band hotplug event to connector
 * @connector: connector to report the event on
 *
 * On some hardware a hotplug event notification may come from outside the display
 * driver / device. An example of this is some USB Type-C setups where the hardware
 * muxes the DisplayPort data and aux-lines but does not pass the altmode HPD
 * status bit to the GPU's DP HPD pin.
 *
 * This function can be used to report these out-of-band events after obtaining
 * a drm_connector reference through calling drm_connector_find_by_fwnode().
 */
void drm_connector_oob_hotplug_event(struct fwnode_handle *connector_fwnode)
{
	struct rockchip_drm_sub_dev *sub_dev;

	if (!connector_fwnode || !connector_fwnode->dev) {
		return;
	}

	sub_dev = rockchip_drm_get_sub_dev(dev_of_node(connector_fwnode->dev));

	if (sub_dev != NULL && sub_dev->connector != NULL && sub_dev->oob_hotplug_event != NULL) {
		sub_dev->oob_hotplug_event(sub_dev->connector);
	}
}
EXPORT_SYMBOL(drm_connector_oob_hotplug_event);

uint32_t rockchip_drm_get_bpp(const struct drm_format_info *info)
{
	u32 ret;

	/* use whatever a driver has set */
	if ((u32)info->cpp[0] != 0U) {
		return (u32)info->cpp[0] * 8U;
	}

	switch (info->format) {
	case DRM_FORMAT_YUV420_8BIT:
		ret = 12U;
		break;
	case DRM_FORMAT_YUV420_10BIT:
		ret = 15U;
		break;
	case DRM_FORMAT_VUY101010:
		ret = 30U;
		break;
	default:
		ret = 0U;
		break;
	}

	/* all attempts failed */
	return ret;
}
EXPORT_SYMBOL(rockchip_drm_get_bpp);

uint32_t rockchip_drm_get_cycles_per_pixel(uint32_t bus_format)
{
	u32 ret;

	switch (bus_format) {
	case MEDIA_BUS_FMT_RGB565_1X16:
	case MEDIA_BUS_FMT_RGB666_1X18:
	case MEDIA_BUS_FMT_RGB888_1X24:
	case MEDIA_BUS_FMT_RGB666_1X24_CPADHI:
		ret = 1U;
		break;
	case MEDIA_BUS_FMT_RGB565_2X8_LE:
	case MEDIA_BUS_FMT_BGR565_2X8_LE:
		ret = 2U;
		break;
	case MEDIA_BUS_FMT_RGB666_3X6:
	case MEDIA_BUS_FMT_RGB888_3X8:
	case MEDIA_BUS_FMT_BGR888_3X8:
		ret = 3U;
		break;
	case MEDIA_BUS_FMT_RGB888_DUMMY_4X8:
	case MEDIA_BUS_FMT_BGR888_DUMMY_4X8:
		ret = 4U;
		break;
	default:
		ret = 1U;
		break;
	}

	return ret;
}
EXPORT_SYMBOL(rockchip_drm_get_cycles_per_pixel);

/**
 * rockchip_drm_of_find_possible_crtcs - find the possible CRTCs for an active
 * encoder port
 * @dev: DRM device
 * @port: encoder port to scan for endpoints
 *
 * Scan all active endpoints attached to a port, locate their attached CRTCs,
 * and generate the DRM mask of CRTCs which may be attached to this
 * encoder.
 *
 * See Documentation/devicetree/bindings/graph.txt for the bindings.
 */
uint32_t rockchip_drm_of_find_possible_crtcs(struct drm_device *dev,
					     struct device_node *port)
{
	struct device_node *remote_port, *ep;
	uint32_t possible_crtcs = 0U;

	for_each_endpoint_of_node(port, ep) {
		if (!of_device_is_available(ep)) {
			continue;
		}

		remote_port = of_graph_get_remote_port(ep);
		if (!remote_port) {
			of_node_put(ep);
			continue;
		}

		possible_crtcs |= drm_of_crtc_port_mask(dev, remote_port);

		of_node_put(remote_port);
	}

	return possible_crtcs;
}
EXPORT_SYMBOL(rockchip_drm_of_find_possible_crtcs);

static DEFINE_MUTEX(rockchip_drm_sub_dev_lock);
static LIST_HEAD(rockchip_drm_sub_dev_list);

void rockchip_connector_update_vfp_for_vrr(struct drm_crtc *crtc, struct drm_display_mode *mode,
					   int vfp)
{
	struct rockchip_drm_sub_dev *sub_dev;


	mutex_lock(&rockchip_drm_sub_dev_lock);
	list_for_each_entry(sub_dev, &rockchip_drm_sub_dev_list, list) {
		if (sub_dev && sub_dev->connector->state->crtc == crtc) {
			if (sub_dev->update_vfp_for_vrr != NULL) {
				sub_dev->update_vfp_for_vrr(sub_dev->connector, mode, vfp);
			}
		}
	}
	mutex_unlock(&rockchip_drm_sub_dev_lock);
}
EXPORT_SYMBOL(rockchip_connector_update_vfp_for_vrr);

void rockchip_drm_register_sub_dev(struct rockchip_drm_sub_dev *sub_dev)
{
	mutex_lock(&rockchip_drm_sub_dev_lock);
	list_add_tail(&sub_dev->list, &rockchip_drm_sub_dev_list);
	mutex_unlock(&rockchip_drm_sub_dev_lock);
}
EXPORT_SYMBOL(rockchip_drm_register_sub_dev);

void rockchip_drm_unregister_sub_dev(struct rockchip_drm_sub_dev *sub_dev)
{
	mutex_lock(&rockchip_drm_sub_dev_lock);
	list_del(&sub_dev->list);
	mutex_unlock(&rockchip_drm_sub_dev_lock);
}
EXPORT_SYMBOL(rockchip_drm_unregister_sub_dev);

struct rockchip_drm_sub_dev *rockchip_drm_get_sub_dev(struct device_node *node)
{
	struct rockchip_drm_sub_dev *sub_dev = NULL;
	bool found = (_Bool)false;

	mutex_lock(&rockchip_drm_sub_dev_lock);
	list_for_each_entry(sub_dev, &rockchip_drm_sub_dev_list, list) {
		if (sub_dev->of_node == node) {
			found = (_Bool)true;
			break;
		}
	}
	mutex_unlock(&rockchip_drm_sub_dev_lock);

	return found ? sub_dev : NULL;
}
EXPORT_SYMBOL(rockchip_drm_get_sub_dev);

int rockchip_drm_get_sub_dev_type(void)
{
	int connector_type = DRM_MODE_CONNECTOR_Unknown;
	struct rockchip_drm_sub_dev *sub_dev = NULL;

	mutex_lock(&rockchip_drm_sub_dev_lock);
	list_for_each_entry(sub_dev, &rockchip_drm_sub_dev_list, list) {
		if (sub_dev->connector->encoder) {
			connector_type = sub_dev->connector->connector_type;
			break;
		}
	}
	mutex_unlock(&rockchip_drm_sub_dev_lock);

	return connector_type;
}
EXPORT_SYMBOL(rockchip_drm_get_sub_dev_type);

u32 rockchip_drm_get_scan_line_time_ns(void)
{
	struct rockchip_drm_sub_dev *sub_dev = NULL;
	struct drm_display_mode *mode;
	u32 linedur_ns = 0;

	mutex_lock(&rockchip_drm_sub_dev_lock);
	list_for_each_entry(sub_dev, &rockchip_drm_sub_dev_list, list) {
		if (sub_dev->connector->encoder && sub_dev->connector->state->crtc) {
			mode = &sub_dev->connector->state->crtc->state->adjusted_mode;
			linedur_ns = (u32)div_u64((u64)mode->crtc_htotal * (u64)1000000ULL, (u32)mode->crtc_clock);
			break;
		}
	}
	mutex_unlock(&rockchip_drm_sub_dev_lock);

	return linedur_ns;
}
EXPORT_SYMBOL(rockchip_drm_get_scan_line_time_ns);

void rockchip_drm_te_handle(struct drm_crtc *crtc)
{
	struct rockchip_drm_private *priv = crtc->dev->dev_private;
	int pipe = (int)drm_crtc_index(crtc);

	if (priv != NULL && pipe >= 0 && pipe < ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL && priv->crtc_funcs[pipe]->te_handler != NULL) {
		priv->crtc_funcs[pipe]->te_handler(crtc);
	}
}
EXPORT_SYMBOL(rockchip_drm_te_handle);

struct drm_crtc *rockchip_drm_encoder_get_old_crtc(struct drm_encoder *encoder,
						   struct drm_atomic_state *state)
{
	struct drm_connector *connector;
	struct drm_connector_state *conn_state;

	connector = drm_atomic_get_old_connector_for_encoder(state, encoder);
	if (!connector) {
		return NULL;
	}

	conn_state = drm_atomic_get_old_connector_state(state, connector);
	if (!conn_state) {
		return NULL;
	}

	return conn_state->crtc;
}
EXPORT_SYMBOL(rockchip_drm_encoder_get_old_crtc);

struct drm_crtc *rockchip_drm_encoder_get_new_crtc(struct drm_encoder *encoder,
						   struct drm_atomic_state *state)
{
	struct drm_connector *connector;
	struct drm_connector_state *conn_state;

	connector = drm_atomic_get_new_connector_for_encoder(state, encoder);
	if (!connector) {
		return NULL;
	}

	conn_state = drm_atomic_get_new_connector_state(state, connector);
	if (!conn_state) {
		return NULL;
	}

	return conn_state->crtc;
}
EXPORT_SYMBOL(rockchip_drm_encoder_get_new_crtc);

static const struct drm_display_mode rockchip_drm_default_modes[] = {
	/* 4 - 1280x720@60Hz 16:9 */
	{ DRM_MODE("1280x720", DRM_MODE_TYPE_DRIVER, 74250, 1280, 1390,
		   1430, 1650, 0, 720, 725, 730, 750, 0,
		   DRM_MODE_FLAG_PHSYNC | DRM_MODE_FLAG_PVSYNC),
	  .picture_aspect_ratio = HDMI_PICTURE_ASPECT_16_9, },
	/* 16 - 1920x1080@60Hz 16:9 */
	{ DRM_MODE("1920x1080", DRM_MODE_TYPE_DRIVER, 148500, 1920, 2008,
		   2052, 2200, 0, 1080, 1084, 1089, 1125, 0,
		   DRM_MODE_FLAG_PHSYNC | DRM_MODE_FLAG_PVSYNC),
	  .picture_aspect_ratio = HDMI_PICTURE_ASPECT_16_9, },
	/* 31 - 1920x1080@50Hz 16:9 */
	{ DRM_MODE("1920x1080", DRM_MODE_TYPE_DRIVER, 148500, 1920, 2448,
		   2492, 2640, 0, 1080, 1084, 1089, 1125, 0,
		   DRM_MODE_FLAG_PHSYNC | DRM_MODE_FLAG_PVSYNC),
	  .picture_aspect_ratio = HDMI_PICTURE_ASPECT_16_9, },
	/* 19 - 1280x720@50Hz 16:9 */
	{ DRM_MODE("1280x720", DRM_MODE_TYPE_DRIVER, 74250, 1280, 1720,
		   1760, 1980, 0, 720, 725, 730, 750, 0,
		   DRM_MODE_FLAG_PHSYNC | DRM_MODE_FLAG_PVSYNC),
	  .picture_aspect_ratio = HDMI_PICTURE_ASPECT_16_9, },
	/* 0x10 - 1024x768@60Hz */
	{ DRM_MODE("1024x768", DRM_MODE_TYPE_DRIVER, 65000, 1024, 1048,
		   1184, 1344, 0,  768, 771, 777, 806, 0,
		   DRM_MODE_FLAG_NHSYNC | DRM_MODE_FLAG_NVSYNC) },
	/* 17 - 720x576@50Hz 4:3 */
	{ DRM_MODE("720x576", DRM_MODE_TYPE_DRIVER, 27000, 720, 732,
		   796, 864, 0, 576, 581, 586, 625, 0,
		   DRM_MODE_FLAG_NHSYNC | DRM_MODE_FLAG_NVSYNC),
	  .picture_aspect_ratio = HDMI_PICTURE_ASPECT_4_3, },
	/* 2 - 720x480@60Hz 4:3 */
	{ DRM_MODE("720x480", DRM_MODE_TYPE_DRIVER, 27000, 720, 736,
		   798, 858, 0, 480, 489, 495, 525, 0,
		   DRM_MODE_FLAG_NHSYNC | DRM_MODE_FLAG_NVSYNC),
	  .picture_aspect_ratio = HDMI_PICTURE_ASPECT_4_3, },
};

int rockchip_drm_add_modes_noedid(struct drm_connector *connector)
{
	struct drm_device *dev = connector->dev;
	struct drm_display_mode *mode;
	int i, count, num_modes = 0;

	mutex_lock(&rockchip_drm_sub_dev_lock);
	count = ARRAY_SIZE(rockchip_drm_default_modes);

	for (i = 0; i < count; i++) {
		const struct drm_display_mode *ptr = &rockchip_drm_default_modes[i];

		mode = drm_mode_duplicate(dev, ptr);
		if (mode) {
			if (i == 0) {
				mode->type = (u8)DRM_MODE_TYPE_PREFERRED;
			}
			drm_mode_probed_add(connector, mode);
			num_modes++;
		}
	}
	mutex_unlock(&rockchip_drm_sub_dev_lock);

	return num_modes;
}
EXPORT_SYMBOL(rockchip_drm_add_modes_noedid);

static const struct rockchip_drm_width_dclk {
	int width;
	u32 dclk_khz;
} rockchip_drm_dclk[] = {
	{1920, 148500},
	{2048, 200000},
	{2560, 280000},
	{3840, 594000},
	{4096, 594000},
	{7680, 2376000},
};

u32 rockchip_drm_get_dclk_by_width(int width)
{
	int i;
	u32 dclk_khz;

	for (i = 0; (unsigned long)i < ARRAY_SIZE(rockchip_drm_dclk); i++) {
		if (width == rockchip_drm_dclk[i].width) {
			dclk_khz = rockchip_drm_dclk[i].dclk_khz;
			break;
		}
	}

	if ((unsigned long)i == ARRAY_SIZE(rockchip_drm_dclk)) {
		DRM_ERROR("Can't not find %d width solution and use 148500 khz as max dclk\n", width);

		dclk_khz = 148500;
	}

	return dclk_khz;
}
EXPORT_SYMBOL(rockchip_drm_get_dclk_by_width);

static int
cea_db_tag(const u8 *db)
{
	return (int)(u32)((u32)db[0] >> 5U);
}

static int
cea_db_payload_len(const u8 *db)
{
	return (int)(u32)((u32)db[0] & 0x1fU);
}

#define for_each_cea_db(cea, i, start, end) \
	for ((i) = (int)(start); \
	     (i) < (int)(end) && (i) + cea_db_payload_len(&(cea)[(i)]) < (int)(end); \
	     (i) += cea_db_payload_len(&(cea)[(i)]) + 1)

#define HDMI_DOVI_VSDB_OUI 0xd04601

static bool cea_db_is_hdmi_dovi_block(const u8 *db)
{
	unsigned int oui;

	if (cea_db_tag(db) != 0x07) {
		return (_Bool)false;
	}

	if (cea_db_payload_len(db) < 11) {
		return (_Bool)false;
	}

	oui = (u32)db[3] << 16U | (u32)db[2] << 8U | (u32)db[1];
	return oui == (u32)HDMI_DOVI_VSDB_OUI;
}

static bool cea_db_is_hdmi_forum_vsdb(const u8 *db)
{
	unsigned int oui;

	if (cea_db_tag(db) != 0x03) {
		return (_Bool)false;
	}

	if (cea_db_payload_len(db) < 7) {
		return (_Bool)false;
	}

	oui = (u32)db[3] << 16U | (u32)db[2] << 8U | (u32)db[1];

	return oui == (u32)HDMI_FORUM_IEEE_OUI;
}

#define CTA_DB_EXTENDED_TAG		7

static bool cea_db_is_extended_tag(const u8 *db, int tag)
{
	return cea_db_tag(db) == (int)CTA_DB_EXTENDED_TAG &&
		cea_db_payload_len(db) >= 1 &&
		(int)db[1] == tag;
}

#define CTA_EXT_DB_HF_SCDB		0x79

static bool cea_db_is_hdmi_forum_scdb(const u8 *db)
{
	return cea_db_is_extended_tag(db, CTA_EXT_DB_HF_SCDB) &&
		cea_db_payload_len(db) >= 7;
}

static int
cea_db_offsets(const u8 *cea, int *start, int *end)
{
	/* DisplayID CTA extension blocks and top-level CEA EDID
	 * block header definitions differ in the following bytes:
	 *   1) Byte 2 of the header specifies length differently,
	 *   2) Byte 3 is only present in the CEA top level block.
	 *
	 * The different definitions for byte 2 follow.
	 *
	 * DisplayID CTA extension block defines byte 2 as:
	 *   Number of payload bytes
	 *
	 * CEA EDID block defines byte 2 as:
	 *   Byte number (decimal) within this block where the 18-byte
	 *   DTDs begin. If no non-DTD data is present in this extension
	 *   block, the value should be set to 04h (the byte after next).
	 *   If set to 00h, there are no DTDs present in this block and
	 *   no non-DTD data.
	 */
	if ((int)cea[0] == 0x81) {
		/*
		 * for_each_displayid_db() has already verified
		 * that these stay within expected bounds.
		 */
		*start = 3;
		*end = *start + (int)cea[2];
	} else if ((int)cea[0] == 0x02) {
		/* Data block offset in CEA extension block */
		*start = 4;
		*end = (int)cea[2];
		if (*end == 0) {
			*end = 127;
		}
		if (*end < 4 || *end > 127) {
			return -ERANGE;
		}
	} else {
		return -EOPNOTSUPP;
	}

	return 0;
}

static u8 *find_edid_extension(const struct edid *edid,
			       int ext_id, int *ext_index)
{
	struct edid *edid_;
	u8 *edid_ext;
	int i;

	/* No EDID or EDID extensions */
	if (edid == NULL || (u32)edid->extensions == 0U || *ext_index >= (int)edid->extensions) {
		return NULL;
	}

	(void)memcpy((u8 *)&edid_, (const u8*)edid, sizeof(struct edid *));

	/* Find CEA extension */
	for (i = *ext_index; i < (int)edid->extensions; i++) {
		edid_ext = (u8 *)edid_ + EDID_LENGTH * (i + 1);
		if ((int)edid_ext[0] == ext_id) {
			break;
		}
	}

	if (i >= (int)edid->extensions) {
		return NULL;
	}

	*ext_index = i + 1;

	return edid_ext;
}

static int validate_displayid(u8 *displayid, int length, int idx)
{
	int i, dispid_length;
	u8 csum = 0;
	struct displayid_hdr *base;

	base = (struct displayid_hdr *)(void *)&displayid[idx];

	DRM_DEBUG_KMS("base revision 0x%x, length %d, %d %d\n",
		      base->rev, base->bytes, base->prod_id, base->ext_count);

	/* +1 for DispID checksum */
	dispid_length = (int)sizeof(*base) + (int)base->bytes + 1;
	if (dispid_length > length - idx) {
		return -EINVAL;
	}

	for (i = 0; i < dispid_length; i++) {
		csum += displayid[idx + i];
	}
	if ((u32)csum != 0U) {
		(void)DRM_NOTE("DisplayID checksum invalid, remainder is %d\n", csum);
		return -EINVAL;
	}

	return 0;
}

static u8 *find_displayid_extension(const struct edid *edid,
				    int *length, int *idx,
				    int *ext_index)
{
	u8 *displayid = find_edid_extension(edid, 0x70, ext_index);
	struct displayid_hdr *base;
	int ret;

	if (!displayid) {
		return NULL;
	}

	/* EDID extensions block checksum isn't for us */
	*length = EDID_LENGTH - 1;
	*idx = 1;

	ret = validate_displayid(displayid, *length, *idx);
	if (ret != 0) {
		return NULL;
	}

	base = (struct displayid_hdr *)(void *)&displayid[*idx];
	if (base == NULL) {
		return NULL;
	}

	*length = *idx + (int)sizeof(*base) + (int)base->bytes;

	return displayid;
}

static u8 *find_cea_extension(const struct edid *edid)
{
	int length, idx;
	struct displayid_block *block;
	u8 *cea;
	u8 *displayid;
	int ext_index;

	/* Look for a top level CEA extension block */
	/* FIXME: make callers iterate through multiple CEA ext blocks? */
	ext_index = 0;
	cea = find_edid_extension(edid, 0x02, &ext_index);
	if (cea) {
		return cea;
	}

	/* CEA blocks can also be found embedded in a DisplayID block */
	ext_index = 0;
	for (;;) {
		displayid = find_displayid_extension(edid, &length, &idx,
						     &ext_index);
		if (!displayid) {
			return NULL;
		}

		idx += (int)sizeof(struct displayid_hdr);
		for_each_displayid_db(displayid, block, idx, length) {
			if ((int)block->tag == 0x81) {
				return (u8 *)block;
			}
		}
	}
}

#define EDID_CEA_YCRCB422	(1U << 4U)

int rockchip_drm_get_yuv422_format(struct drm_connector *connector,
				   struct edid *edid)
{
	struct drm_display_info *info;
	const u8 *edid_ext;

	if (!connector || !edid) {
		return -EINVAL;
	}

	info = &connector->display_info;

	edid_ext = find_cea_extension(edid);
	if (!edid_ext) {
		return -EINVAL;
	}

	if (((u32)edid_ext[3] & (u32)EDID_CEA_YCRCB422) != 0U) {
		info->color_formats |= (u32)DRM_COLOR_FORMAT_YCRCB422;
	}

	return 0;
}
EXPORT_SYMBOL(rockchip_drm_get_yuv422_format);

static
void get_max_frl_rate(int max_frl_rate, u8 *max_lanes, u8 *max_rate_per_lane)
{
	switch (max_frl_rate) {
	case 0:
		*max_lanes = 0;
		*max_rate_per_lane = 0;
		break;
	case 1:
		*max_lanes = 3;
		*max_rate_per_lane = 3;
		break;
	case 2:
		*max_lanes = 3;
		*max_rate_per_lane = 6;
		break;
	case 3:
		*max_lanes = 4;
		*max_rate_per_lane = 6;
		break;
	case 4:
		*max_lanes = 4;
		*max_rate_per_lane = 8;
		break;
	case 5:
		*max_lanes = 4;
		*max_rate_per_lane = 10;
		break;
	case 6:
	/*
	 * According to CTS HFR1-17, if max frl rate in edid is out
	 * of hdmi spec range, hdmitx should output its max frl rate.
	 */
	default:
		*max_lanes = 4;
		*max_rate_per_lane = 12;
		break;
	}
}

#define EDID_DSC_10BPC			(1U << 0U)
#define EDID_DSC_12BPC			(1U << 1U)
#define EDID_DSC_16BPC			(1U << 2U)
#define EDID_DSC_ALL_BPP		(1U << 3U)
#define EDID_DSC_NATIVE_420		(1U << 6U)
#define EDID_DSC_1P2			(1U << 7U)
#define EDID_DSC_MAX_FRL_RATE_MASK	0xf0U
#define EDID_DSC_MAX_SLICES		0xfU
#define EDID_DSC_TOTAL_CHUNK_KBYTES	0x3fU
#define EDID_MAX_FRL_RATE_MASK		0xf0U

static
void parse_edid_forum_vsdb(struct rockchip_drm_dsc_cap *dsc_cap,
			   u8 *max_frl_rate_per_lane, u8 *max_lanes, u8 *add_func,
			   const u8 *hf_vsdb)
{
	u8 max_frl_rate;
	u8 dsc_max_frl_rate;
	u8 dsc_max_slices;

	if (hf_vsdb[7] == (u8)0U) {
		return;
	}

	DRM_DEBUG_KMS("hdmi_21 sink detected. parsing edid\n");
	max_frl_rate = (hf_vsdb[7] & EDID_MAX_FRL_RATE_MASK) >> 4;
	get_max_frl_rate((int)max_frl_rate, max_lanes,
			 max_frl_rate_per_lane);

	*add_func = hf_vsdb[8];

	if (cea_db_payload_len(hf_vsdb) < 13) {
		return;
	}

	dsc_cap->v_1p2 = ((u32)hf_vsdb[11] & EDID_DSC_1P2) != 0U;

	if (!dsc_cap->v_1p2) {
		return;
	}

	dsc_cap->native_420 = ((u32)hf_vsdb[11] & EDID_DSC_NATIVE_420) != 0U;
	dsc_cap->all_bpp = ((u32)hf_vsdb[11] & EDID_DSC_ALL_BPP) != 0U;

	if (((u32)hf_vsdb[11] & EDID_DSC_16BPC) != 0U) {
		dsc_cap->bpc_supported = (u8)16U;
	} else if (((u32)hf_vsdb[11] & EDID_DSC_12BPC) != 0U) {
		dsc_cap->bpc_supported = (u8)12U;
	} else if (((u32)hf_vsdb[11] & EDID_DSC_10BPC) != 0U) {
		dsc_cap->bpc_supported = (u8)10U;
	} else {
		dsc_cap->bpc_supported = (u8)0U;
	}

	dsc_max_frl_rate = (hf_vsdb[12] & EDID_DSC_MAX_FRL_RATE_MASK) >> 4;
	get_max_frl_rate((int)dsc_max_frl_rate, &dsc_cap->max_lanes,
			 &dsc_cap->max_frl_rate_per_lane);
	dsc_cap->total_chunk_kbytes = (u8)(u32)((u32)hf_vsdb[13] & (u32)EDID_DSC_TOTAL_CHUNK_KBYTES);

	dsc_max_slices = (u8)hf_vsdb[12] & (u8)EDID_DSC_MAX_SLICES;
	switch (dsc_max_slices) {
	case 1:
		dsc_cap->max_slices = (u8)1U;
		dsc_cap->clk_per_slice = 340;
		break;
	case 2:
		dsc_cap->max_slices = (u8)2U;
		dsc_cap->clk_per_slice = 340;
		break;
	case 3:
		dsc_cap->max_slices = (u8)4U;
		dsc_cap->clk_per_slice = 340;
		break;
	case 4:
		dsc_cap->max_slices = (u8)8U;
		dsc_cap->clk_per_slice = 340;
		break;
	case 5:
		dsc_cap->max_slices = (u8)8U;
		dsc_cap->clk_per_slice = 400;
		break;
	case 6:
		dsc_cap->max_slices = (u8)12U;
		dsc_cap->clk_per_slice = 400;
		break;
	case 7:
		dsc_cap->max_slices = (u8)16U;
		dsc_cap->clk_per_slice = 400;
		break;
	case 0:
	default:
		dsc_cap->max_slices = (u8)0U;
		dsc_cap->clk_per_slice = 0;
		break;
	}
}

/* Sink Capability Data Structure, for compatibility with linux version < linux kernel 6.1 */
static void parse_hdmi_forum_scds(struct rockchip_drm_dsc_cap *dsc_cap,
				  u8 *max_frl_rate_per_lane, u8 *max_lanes,
				  const u8 *hf_scds)
{
	if (hf_scds[7] != (u8)0U) {
		u8 max_frl_rate;
		u8 dsc_max_frl_rate;
		u8 dsc_max_slices;

		DRM_DEBUG_KMS("hdmi_21 sink detected. parsing edid\n");
		max_frl_rate = (u8)(u32)(((u32)hf_scds[7] & EDID_MAX_FRL_RATE_MASK) >> 4U);
		get_max_frl_rate((int)max_frl_rate, max_lanes,
				 max_frl_rate_per_lane);
		dsc_cap->v_1p2 = ((u32)hf_scds[11] & EDID_DSC_1P2) != 0U;

		if (dsc_cap->v_1p2) {
			dsc_cap->native_420 = ((u32)hf_scds[11] & EDID_DSC_NATIVE_420) != 0U;
			dsc_cap->all_bpp = ((u32)hf_scds[11] & EDID_DSC_ALL_BPP) != 0U;

			if (((u32)hf_scds[11] & EDID_DSC_16BPC) != 0U) {
				dsc_cap->bpc_supported = (u8)16U;
			} else if (((u32)hf_scds[11] & EDID_DSC_12BPC) != 0U) {
				dsc_cap->bpc_supported = (u8)12U;
			} else if (((u32)hf_scds[11] & EDID_DSC_10BPC) != 0U) {
				dsc_cap->bpc_supported = (u8)10U;
			} else {
				/* Supports min 8 BPC if DSC 1.2 is supported*/
				dsc_cap->bpc_supported = (u8)8U;
			}

			dsc_max_frl_rate = (u8)(u32)(((u32)hf_scds[12] & EDID_DSC_MAX_FRL_RATE_MASK) >> 4U);
			get_max_frl_rate((int)dsc_max_frl_rate, &dsc_cap->max_lanes,
					 &dsc_cap->max_frl_rate_per_lane);
			dsc_cap->total_chunk_kbytes = hf_scds[13] & EDID_DSC_TOTAL_CHUNK_KBYTES;

			dsc_max_slices = hf_scds[12] & (u8)EDID_DSC_MAX_SLICES;
			switch (dsc_max_slices) {
			case 1:
				dsc_cap->max_slices = (u8)1U;
				dsc_cap->clk_per_slice = 340;
				break;
			case 2:
				dsc_cap->max_slices = (u8)2U;
				dsc_cap->clk_per_slice = 340;
				break;
			case 3:
				dsc_cap->max_slices = (u8)4U;
				dsc_cap->clk_per_slice = 340;
				break;
			case 4:
				dsc_cap->max_slices = (u8)8U;
				dsc_cap->clk_per_slice = 340;
				break;
			case 5:
				dsc_cap->max_slices = (u8)8U;
				dsc_cap->clk_per_slice = 400;
				break;
			case 6:
				dsc_cap->max_slices = (u8)12U;
				dsc_cap->clk_per_slice = 400;
				break;
			case 7:
				dsc_cap->max_slices = (u8)16U;
				dsc_cap->clk_per_slice = 400;
				break;
			case 0:
			default:
				dsc_cap->max_slices = (u8)0U;
				dsc_cap->clk_per_slice = 0;
				break;
			}
		}
	}
}

static
int parse_dovi_block(u8 *sink_data, const u8 *dovi_db)
{
	u8 length = ((u8)dovi_db[0] & (u8)0x1fU) + (u8)1U;

	if (length > DOVI_VSDB_LEN) {
		return -EINVAL;
	}

	(void)memcpy(sink_data, dovi_db, length);
	return 0;
}

int rockchip_drm_parse_cea_ext(struct rockchip_drm_dsc_cap *dsc_cap,
			       u8 *max_frl_rate_per_lane, u8 *max_lanes, u8 *add_func,
			       const struct edid *edid)
{
	const u8 *edid_ext;
	int i, start, end;

	if (!dsc_cap || !max_frl_rate_per_lane || !max_lanes || !edid || !add_func) {
		return -EINVAL;
	}

	edid_ext = find_cea_extension(edid);
	if (!edid_ext) {
		return -EINVAL;
	}

	if (cea_db_offsets(edid_ext, &start, &end) != 0) {
		return -EINVAL;
	}

	for_each_cea_db(edid_ext, i, start, end) {
		const u8 *db = &edid_ext[i];

		if (cea_db_is_hdmi_forum_vsdb(db)) {
			parse_edid_forum_vsdb(dsc_cap, max_frl_rate_per_lane,
					      max_lanes, add_func, db);
		} else if (cea_db_is_hdmi_forum_scdb(db)) {
			parse_hdmi_forum_scds(dsc_cap, max_frl_rate_per_lane,
					      max_lanes, db);
		} else {
			/* Intentionally Empty */
		}
	}

	return 0;
}
EXPORT_SYMBOL(rockchip_drm_parse_cea_ext);

int rockchip_drm_parse_dovi(u8 *sink_data, const struct edid *edid)
{
	const u8 *edid_ext;
	int i, start, end, ret;

	if (!sink_data || !edid) {
		return -EINVAL;
	}

	(void)memset(sink_data, 0, DOVI_VSDB_LEN);

	edid_ext = find_cea_extension(edid);
	if (!edid_ext) {
		return -EINVAL;
	}

	if (cea_db_offsets(edid_ext, &start, &end) != 0) {
		return -EINVAL;
	}

	for_each_cea_db(edid_ext, i, start, end) {
		const u8 *db = &edid_ext[i];

		if (cea_db_is_hdmi_dovi_block(db)) {
			ret = parse_dovi_block(sink_data, db);
			if (ret != 0) {
				return ret;
			}
		}
	}

	return 0;
}
EXPORT_SYMBOL(rockchip_drm_parse_dovi);

#define COLORIMETRY_DATA_BLOCK		0x5
#define USE_EXTENDED_TAG		0x07

static bool cea_db_is_hdmi_colorimetry_data_block(const u8 *db)
{
	if (cea_db_tag(db) != USE_EXTENDED_TAG) {
		return (_Bool)false;
	}

	if ((int)db[1] != COLORIMETRY_DATA_BLOCK) {
		return (_Bool)false;
	}

	return (_Bool)true;
}

int
rockchip_drm_parse_colorimetry_data_block(u8 *colorimetry, const struct edid *edid)
{
	const u8 *edid_ext;
	int i, start, end;

	if (!colorimetry || !edid) {
		return -EINVAL;
	}

	*colorimetry = 0;

	edid_ext = find_cea_extension(edid);
	if (!edid_ext) {
		return -EINVAL;
	}

	if (cea_db_offsets(edid_ext, &start, &end) != 0) {
		return -EINVAL;
	}

	for_each_cea_db(edid_ext, i, start, end) {
		const u8 *db = &edid_ext[i];

		if (cea_db_is_hdmi_colorimetry_data_block(db)) {
			/* As per CEA 861-G spec */
			*colorimetry = (u8)(u32)((((u32)db[3] & (0x1U << 7U)) << 1U) | (u32)db[2]);
		}
	}

	return 0;
}
EXPORT_SYMBOL(rockchip_drm_parse_colorimetry_data_block);

/*
 * Attach a (component) device to the shared drm dma mapping from master drm
 * device.  This is used by the VOPs to map GEM buffers to a common DMA
 * mapping.
 */
int rockchip_drm_dma_attach_device(struct drm_device *drm_dev,
				   struct device *dev)
{
	struct rockchip_drm_private *private = drm_dev->dev_private;
	int ret;

	if (!is_support_iommu) {
		return 0;
	}

	ret = iommu_attach_device(private->domain, dev);
	if (ret != 0) {
		DRM_DEV_ERROR(dev, "Failed to attach iommu device\n");
		return ret;
	}

	return 0;
}

void rockchip_drm_dma_detach_device(struct drm_device *drm_dev,
				    struct device *dev)
{
	struct rockchip_drm_private *private = drm_dev->dev_private;
	struct iommu_domain *domain = private->domain;

	if (!is_support_iommu) {
		return;
	}

	iommu_detach_device(domain, dev);
}

void rockchip_drm_crtc_standby(struct drm_crtc *crtc, bool standby)
{
	struct rockchip_drm_private *priv = crtc->dev->dev_private;
	int pipe = (int)drm_crtc_index(crtc);

	if (pipe >= 0 && pipe < ROCKCHIP_MAX_CRTC &&
	    priv->crtc_funcs[pipe] != NULL &&
	    priv->crtc_funcs[pipe]->crtc_standby != NULL) {
		priv->crtc_funcs[pipe]->crtc_standby(crtc, standby);
	}
}

void rockchip_drm_crtc_output_post_enable(struct drm_crtc *crtc, int intf)
{
	struct rockchip_drm_private *priv = crtc->dev->dev_private;
	int pipe = (int)drm_crtc_index(crtc);

	if (pipe >= 0 && pipe < ROCKCHIP_MAX_CRTC &&
	    priv->crtc_funcs[pipe] != NULL &&
	    priv->crtc_funcs[pipe]->crtc_output_post_enable != NULL) {
		priv->crtc_funcs[pipe]->crtc_output_post_enable(crtc, intf);
	}
}

void rockchip_drm_crtc_output_pre_disable(struct drm_crtc *crtc, int intf)
{
	struct rockchip_drm_private *priv = crtc->dev->dev_private;
	int pipe = (int)drm_crtc_index(crtc);

	if (pipe >= 0 && pipe < ROCKCHIP_MAX_CRTC &&
	    priv->crtc_funcs[pipe] != NULL &&
	    priv->crtc_funcs[pipe]->crtc_output_pre_disable != NULL) {
		priv->crtc_funcs[pipe]->crtc_output_pre_disable(crtc, intf);
	}
}

int rockchip_register_crtc_funcs(struct drm_crtc *crtc,
				 const struct rockchip_crtc_funcs *crtc_funcs)
{
	unsigned int pipe = drm_crtc_index(crtc);
	struct rockchip_drm_private *priv = crtc->dev->dev_private;

	if (pipe >= ROCKCHIP_MAX_CRTC) {
		return -EINVAL;
	}

	priv->crtc_funcs[pipe] = crtc_funcs;

	return 0;
}

void rockchip_unregister_crtc_funcs(struct drm_crtc *crtc)
{
	unsigned int pipe = drm_crtc_index(crtc);
	struct rockchip_drm_private *priv = crtc->dev->dev_private;

	if (pipe >= ROCKCHIP_MAX_CRTC) {
		return;
	}

	priv->crtc_funcs[pipe] = NULL;
}

/*
 * a high frequency of page faults will follow up, if
 * there is a iommu fault, so it's better to limit the
 * registers dump frequency to save log buffer
 *
 * Report no more than once every 10s, give userspace time
 * to do recovery process, as for a serdes based display
 * pipeline, the disable/enable time may very long.
 */
static DEFINE_RATELIMIT_STATE(fault_handler_rate, 10 * HZ, 1);

static int fault_handler_rate_limit(void)
{
	return __ratelimit(&fault_handler_rate);
}

void rockchip_drm_reset_iommu_fault_handler_rate_limit(void)
{
	fault_handler_rate.begin = 0;
	fault_handler_rate.printed = 0;
}

static int rockchip_drm_fault_handler(struct iommu_domain *iommu,
				      struct device *dev,
				      unsigned long iova, int flags, void *arg)
{
	struct drm_device *drm_dev = arg;
	struct rockchip_drm_private *priv = drm_dev->dev_private;
	struct drm_crtc *crtc;
	bool handled = (_Bool)false;

	priv->iommu_fault_count++;
	DRM_ERROR("iommu fault handler flags: 0x%x: count: %lld\n",
		  flags, priv->iommu_fault_count);

	if (fault_handler_rate_limit() == 0) {
		return 0;
	}

	drm_for_each_crtc(crtc, drm_dev) {
		unsigned int pipe = drm_crtc_index(crtc);

		/*
		 * Only need to call iommu fault handler once for one iommu fault
		 */
		if (pipe < (u32)ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL &&
		    priv->crtc_funcs[pipe]->iommu_fault_handler != NULL &&
		    !handled) {
			priv->crtc_funcs[pipe]->iommu_fault_handler(crtc, iommu);
			handled = (_Bool)true;
		}

		if (pipe < (u32)ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL &&
		    priv->crtc_funcs[pipe]->regs_dump != NULL) {
			priv->crtc_funcs[pipe]->regs_dump(crtc, NULL);
		}

		if (pipe < (u32)ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL &&
		    priv->crtc_funcs[pipe]->debugfs_dump != NULL) {
			priv->crtc_funcs[pipe]->debugfs_dump(crtc, NULL);
		}
	}

	return 0;
}

static int rockchip_drm_init_iommu(struct drm_device *drm_dev)
{
	struct rockchip_drm_private *private = drm_dev->dev_private;
	struct iommu_domain_geometry *geometry;
	u64 start, end;
	int ret = 0;

	if (!is_support_iommu) {
		return 0;
	}

	private->domain = iommu_domain_alloc(&platform_bus_type);
	if (!private->domain) {
		return -ENOMEM;
	}

	geometry = &private->domain->geometry;
	start = geometry->aperture_start;
	end = geometry->aperture_end;

	DRM_DEBUG("IOMMU context initialized (aperture: %#llx-%#llx)\n",
		  start, end);
	drm_mm_init(&private->mm, start, end - start + 1ULL);
	mutex_init(&private->mm_lock);

	iommu_set_fault_handler(private->domain, rockchip_drm_fault_handler,
				drm_dev);

	if (iommu_reserve_map) {
		/*
		 * At 32 bit platform size_t maximum value is 0xffffffff, SZ_4G(0x100000000) will be
		 * cliped to 0, so we split into two mapping
		 */
		ret = iommu_map(private->domain, 0, 0, (size_t)SZ_2G,
				(int)(u32)(IOMMU_WRITE | IOMMU_READ | IOMMU_PRIV));
		if (ret != 0) {
			dev_err(drm_dev->dev, "failed to create 0-2G pre mapping\n");
			return 0;
		}

		ret = iommu_map(private->domain, SZ_2G, SZ_2G, (size_t)SZ_2G,
				IOMMU_WRITE | IOMMU_READ | IOMMU_PRIV);
		if (ret != 0) {
			dev_err(drm_dev->dev, "failed to create 2G-4G pre mapping\n");
			return 0;
		}
		dev_info(drm_dev->dev, "Enable iommu reserve map\n");
	}

	return ret;
}

static void rockchip_iommu_cleanup(struct drm_device *drm_dev)
{
	struct rockchip_drm_private *private = drm_dev->dev_private;

	if (!is_support_iommu) {
		return;
	}

	if (iommu_reserve_map) {
		iommu_unmap(private->domain, 0, (size_t)SZ_2G);
		iommu_unmap(private->domain, SZ_2G, (size_t)SZ_2G);
	}
	drm_mm_takedown(&private->mm);
	iommu_domain_free(private->domain);
}

#ifdef CONFIG_DEBUG_FS
static int rockchip_drm_mm_dump(struct seq_file *s, void *data)
{
	struct drm_info_node *node = s->private;
	struct drm_minor *minor = node->minor;
	struct drm_device *drm_dev = minor->dev;
	struct rockchip_drm_private *priv = drm_dev->dev_private;
	struct drm_printer p = drm_seq_file_printer(s);

	if (!priv->domain) {
		return 0;
	}
	mutex_lock(&priv->mm_lock);
	drm_mm_print(&priv->mm, &p);
	mutex_unlock(&priv->mm_lock);

	return 0;
}

static int rockchip_drm_summary_show(struct seq_file *s, void *data)
{
	struct drm_info_node *node = s->private;
	struct drm_minor *minor = node->minor;
	struct drm_device *drm_dev = minor->dev;
	struct rockchip_drm_private *priv = drm_dev->dev_private;
	struct drm_crtc *crtc;

	drm_for_each_crtc(crtc, drm_dev) {
		unsigned int pipe = drm_crtc_index(crtc);

		if (pipe < (u32)ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL &&
		    priv->crtc_funcs[pipe]->debugfs_dump != NULL) {
			priv->crtc_funcs[pipe]->debugfs_dump(crtc, s);
		}
	}

	return 0;
}

static int rockchip_drm_regs_dump(struct seq_file *s, void *data)
{
	struct drm_info_node *node = s->private;
	struct drm_minor *minor = node->minor;
	struct drm_device *drm_dev = minor->dev;
	struct rockchip_drm_private *priv = drm_dev->dev_private;
	struct drm_crtc *crtc;

	drm_for_each_crtc(crtc, drm_dev) {
		unsigned int pipe = drm_crtc_index(crtc);

		if (pipe < (u32)ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL &&
		    priv->crtc_funcs[pipe]->regs_dump != NULL) {
			priv->crtc_funcs[pipe]->regs_dump(crtc, s);
		}
	}

	return 0;
}

static int rockchip_drm_active_regs_dump(struct seq_file *s, void *data)
{
	struct drm_info_node *node = s->private;
	struct drm_minor *minor = node->minor;
	struct drm_device *drm_dev = minor->dev;
	struct rockchip_drm_private *priv = drm_dev->dev_private;
	struct drm_crtc *crtc;

	drm_for_each_crtc(crtc, drm_dev) {
		unsigned int pipe = drm_crtc_index(crtc);

		if (pipe < (u32)ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL &&
		    priv->crtc_funcs[pipe]->active_regs_dump != NULL) {
			priv->crtc_funcs[pipe]->active_regs_dump(crtc, s);
		}
	}

	return 0;
}

static struct drm_info_list rockchip_debugfs_files[] = {
	{ "active_regs", rockchip_drm_active_regs_dump, 0, NULL },
	{ "regs", rockchip_drm_regs_dump, 0, NULL },
	{ "summary", rockchip_drm_summary_show, 0, NULL },
	{ "mm_dump", rockchip_drm_mm_dump, 0, NULL },
};

static void rockchip_drm_debugfs_init(struct drm_minor *minor)
{
	struct drm_device *dev = minor->dev;
	struct rockchip_drm_private *priv = dev->dev_private;
	struct drm_crtc *crtc;

	drm_debugfs_create_files(rockchip_debugfs_files,
				 ARRAY_SIZE(rockchip_debugfs_files),
				 minor->debugfs_root, minor);

	drm_for_each_crtc(crtc, dev) {
		unsigned int pipe = drm_crtc_index(crtc);

		if (pipe < (u32)ROCKCHIP_MAX_CRTC && priv->crtc_funcs[pipe] != NULL &&
		    priv->crtc_funcs[pipe]->debugfs_init != NULL) {
			priv->crtc_funcs[pipe]->debugfs_init(minor, crtc);
		}
	}
}
#endif

static const struct drm_prop_enum_list split_area[] = {
	{ (int)ROCKCHIP_DRM_SPLIT_UNSET, "UNSET" },
	{ (int)ROCKCHIP_DRM_SPLIT_LEFT_SIDE, "LEFT" },
	{ (int)ROCKCHIP_DRM_SPLIT_RIGHT_SIDE, "RIGHT" },
};

static int rockchip_drm_create_properties(struct drm_device *dev)
{
	struct drm_property *prop;
	struct rockchip_drm_private *private = dev->dev_private;

	prop = drm_property_create_range(dev, (u32)DRM_MODE_PROP_ATOMIC,
					 "EOTF", 0ULL, (u64)HDMI_EOTF_DOVI);
	if (!prop) {
		return -ENOMEM;
	}
	private->eotf_prop = prop;

	prop = drm_property_create_range(dev, (u32)DRM_MODE_PROP_ATOMIC,
					 "COLOR_SPACE", 0ULL, 12ULL);
	if (!prop) {
		return -ENOMEM;
	}
	private->color_space_prop = prop;

	prop = drm_property_create_range(dev, (u32)DRM_MODE_PROP_ATOMIC,
					 "ASYNC_COMMIT", 0ULL, 1ULL);
	if (!prop) {
		return -ENOMEM;
	}
	private->async_commit_prop = prop;

	prop = drm_property_create_range(dev, (u32)DRM_MODE_PROP_ATOMIC,
					 "SHARE_ID", 0ULL, (u64)UINT_MAX);
	if (!prop) {
		return -ENOMEM;
	}
	private->share_id_prop = prop;

	prop = drm_property_create_range(dev, (u32)((u32)DRM_MODE_PROP_ATOMIC | (u32)DRM_MODE_PROP_IMMUTABLE),
					 "CONNECTOR_ID", 0ULL, 0xfULL);
	if (!prop) {
		return -ENOMEM;
	}
	private->connector_id_prop = prop;

	prop = drm_property_create_enum(dev, (u32)DRM_MODE_PROP_ENUM, "SPLIT_AREA",
					split_area,
					ARRAY_SIZE(split_area));
	private->split_area_prop = prop;

	prop = drm_property_create_object(dev,
					  (u32)((u32)DRM_MODE_PROP_ATOMIC | (u32)DRM_MODE_PROP_IMMUTABLE),
					  "SOC_ID", DRM_MODE_OBJECT_CRTC);
	private->soc_id_prop = prop;

	prop = drm_property_create_object(dev,
					  (u32)((u32)DRM_MODE_PROP_ATOMIC | (u32)DRM_MODE_PROP_IMMUTABLE),
					  "PORT_ID", DRM_MODE_OBJECT_CRTC);
	private->port_id_prop = prop;

	prop = drm_property_create_range(dev, (u32)DRM_MODE_PROP_ATOMIC,
					 "DOVI_INPUT_TYPE", 0ULL, (u64)DOVI_ENHANCE_LAYER);
	if (!prop) {
		return -ENOMEM;
	}
	private->dovi_input_type_prop = prop;

	private->aclk_prop = drm_property_create_range(dev, 0U, "ACLK", 0ULL, (u32)UINT_MAX);
	private->bg_prop = drm_property_create_range(dev, 0U, "BACKGROUND", 0ULL, (u32)UINT_MAX);
	private->line_flag_prop = drm_property_create_range(dev, 0U, "LINE_FLAG1", 0ULL, (u32)UINT_MAX);
	private->cubic_lut_prop = drm_property_create(dev, (u32)DRM_MODE_PROP_BLOB, "CUBIC_LUT", 0);
	private->cubic_lut_size_prop = drm_property_create_range(dev, (u32)DRM_MODE_PROP_IMMUTABLE,
								 "CUBIC_LUT_SIZE", 0ULL, (u32)UINT_MAX);

	return drm_mode_create_tv_properties(dev, 0U, NULL);
}

static void rockchip_attach_connector_property(struct drm_device *drm)
{
	struct drm_connector *connector;
	struct drm_mode_config *conf = &drm->mode_config;
	struct drm_connector_list_iter conn_iter;

	mutex_lock(&drm->mode_config.mutex);

#define ROCKCHIP_PROP_ATTACH(prop, v) \
		drm_object_attach_property(&connector->base, prop, v)

	drm_connector_list_iter_begin(drm, &conn_iter);
	drm_for_each_connector_iter(connector, &conn_iter) {
		ROCKCHIP_PROP_ATTACH(conf->tv_brightness_property, 50);
		ROCKCHIP_PROP_ATTACH(conf->tv_contrast_property, 50);
		ROCKCHIP_PROP_ATTACH(conf->tv_saturation_property, 50);
		ROCKCHIP_PROP_ATTACH(conf->tv_hue_property, 50);
	}
	drm_connector_list_iter_end(&conn_iter);
#undef ROCKCHIP_PROP_ATTACH

	mutex_unlock(&drm->mode_config.mutex);
}

static void rockchip_drm_set_property_default(struct drm_device *drm)
{
	struct drm_connector *connector;
	struct drm_mode_config *conf = &drm->mode_config;
	struct drm_atomic_state *state;
	int ret;
	struct drm_connector_list_iter conn_iter;

	drm_modeset_lock_all(drm);

	state = drm_atomic_helper_duplicate_state(drm, conf->acquire_ctx);
	if (IS_ERR(state)) {
		DRM_ERROR("failed to alloc atomic state\n");
		goto err_unlock;
	}
	state->acquire_ctx = conf->acquire_ctx;

	drm_connector_list_iter_begin(drm, &conn_iter);
	drm_for_each_connector_iter(connector, &conn_iter) {
		struct drm_connector_state *connector_state;

		connector_state = drm_atomic_get_connector_state(state,
								 connector);
		if (IS_ERR(connector_state)) {
			DRM_ERROR("Connector[%d]: Failed to get state\n", connector->base.id);
			continue;
		}

		connector_state->tv.brightness = 50;
		connector_state->tv.contrast = 50;
		connector_state->tv.saturation = 50;
		connector_state->tv.hue = 50;
	}
	drm_connector_list_iter_end(&conn_iter);

	ret = drm_atomic_commit(state);
	(void)WARN_ON(ret == -EDEADLK);
	if (ret != 0) {
		DRM_ERROR("Failed to update properties\n");
	}
	drm_atomic_state_put(state);

err_unlock:
	drm_modeset_unlock_all(drm);
}

static int rockchip_gem_pool_init(struct drm_device *drm)
{
	struct rockchip_drm_private *private = drm->dev_private;
	struct device_node *np = drm->dev->of_node;
	struct device_node *node;
	phys_addr_t start, size;
	struct resource res;
	int ret;

	node = of_parse_phandle(np, "secure-memory-region", 0);
	if (!node) {
		return -ENXIO;
	}

	ret = of_address_to_resource(node, 0, &res);
	if (ret != 0) {
		return ret;
	}
	start = res.start;
	size = resource_size(&res);
	if ((u64)size == 0ULL) {
		return -ENOMEM;
	}

	private->secure_buffer_pool = gen_pool_create(PAGE_SHIFT, -1);
	if (!private->secure_buffer_pool) {
		return -ENOMEM;
	}

	(void)gen_pool_add(private->secure_buffer_pool, start, size, -1);

	return 0;
}

static void rockchip_gem_pool_destroy(struct drm_device *drm)
{
	struct rockchip_drm_private *private = drm->dev_private;

	if (!private->secure_buffer_pool) {
		return;
	}

	gen_pool_destroy(private->secure_buffer_pool);
}

void rockchip_drm_send_error_event(struct rockchip_drm_private *priv,
				   enum rockchip_drm_error_event_type event)
{
	struct rockchip_drm_error_event *error_event = &priv->error_event;
	struct drm_event_vblank *e;
	struct timespec64 tv;
	unsigned long flags;

	/*
	 * Maybe the error thread has not be created.
	 */
	if (IS_ERR_OR_NULL(priv->error_event.thread)) {
		return;
	}

	spin_lock_irqsave(&error_event->lock, flags);
	tv = ktime_to_timespec64(ktime_get());
	e = &error_event->event;
	e->base.type = (u32)event;
	e->base.length = sizeof(*e);
	e->tv_sec = (u32)tv.tv_sec;
	e->tv_usec = (u32)(long)((long)tv.tv_nsec / 1000L);
	e->sequence++;
	error_event->error_state = (_Bool)true;
	spin_unlock_irqrestore(&error_event->lock, flags);

	wake_up_interruptible_all(&error_event->wait);
}

static int rockchip_drm_error_event_thread(void *data)
{
	struct drm_device *drm_dev = data;
	struct rockchip_drm_private *priv = drm_dev->dev_private;
	struct rockchip_drm_error_event *error_event = &priv->error_event;
	struct drm_event_vblank *e;
	int ret;
	int cnt = 0;

	while (!kthread_should_stop()) {
		e = &error_event->event;

		error_event->error_state = (_Bool)false;
		ret = wait_event_interruptible(error_event->wait, error_event->error_state);
		if (ret == 0) {
			sysfs_notify(&drm_dev->dev->kobj, NULL, "error_event");
			drm_info(drm_dev, "rockchipdrm send_error_event_type: 0x%x, count:%d\n",
				 e->base.type, ++cnt);
		}
	}

	return 0;
}

static ssize_t rockchip_drm_error_event_show(struct device *dev,
					     struct device_attribute *attr, char *buf)
{
	struct drm_device *drm_dev = dev_get_drvdata(dev);
	struct rockchip_drm_private *priv = drm_dev->dev_private;
	struct rockchip_drm_error_event *error_event = &priv->error_event;
	struct drm_event_vblank *e;
	uint32_t length = sizeof(*e);
	unsigned long flags;

	spin_lock_irqsave(&error_event->lock, flags);
	e = &error_event->event;
	(void)memcpy((u8 *)buf, (const u8 *)e, length);
	spin_unlock_irqrestore(&error_event->lock, flags);

	return (ssize_t)length;
}
static DEVICE_ATTR(error_event, 0444, rockchip_drm_error_event_show, NULL);

static void rockchip_drm_error_event_init(struct drm_device *drm_dev)
{
	struct rockchip_drm_private *priv = drm_dev->dev_private;
	struct sched_param sched_param = { .sched_priority = MAX_RT_PRIO - 1 };
	int ret;

	ret = device_create_file(drm_dev->dev, &dev_attr_error_event);
	if (ret != 0) {
		dev_warn(drm_dev->dev, "failed to create vcnt event file\n");
		return;
	}

	init_waitqueue_head(&priv->error_event.wait);
	spin_lock_init(&priv->error_event.lock);
	priv->error_event.thread = kthread_run(rockchip_drm_error_event_thread,
					       drm_dev, "display-error-event-thread");
	if (IS_ERR(priv->error_event.thread)) {
		priv->error_event.thread = NULL;
		drm_err(drm_dev, "failed to run display error_event thread\n");
	} else {
		(void)sched_setscheduler(priv->error_event.thread, SCHED_FIFO, &sched_param);
		drm_info(drm_dev, "run display error_event monitor\n");
	}
}

static void rockchip_drm_error_event_fini(struct drm_device *drm_dev)
{
	struct rockchip_drm_private *priv = drm_dev->dev_private;

	if (priv->error_event.thread) {
		(void)kthread_stop(priv->error_event.thread);
	}
	device_remove_file(drm_dev->dev, &dev_attr_error_event);
}

static int rockchip_drm_bind(struct device *dev)
{
	struct drm_device *drm_dev;
	struct rockchip_drm_private *private;
	int ret;

	drm_dev = drm_dev_alloc(&rockchip_drm_driver, dev);
	if (IS_ERR(drm_dev)) {
		return (int)PTR_ERR(drm_dev);
	}

	dev_set_drvdata(dev, drm_dev);

	private = devm_kzalloc(drm_dev->dev, sizeof(*private), GFP_KERNEL);
	if (!private) {
		ret = -ENOMEM;
		goto err_free;
	}

	mutex_init(&private->ovl_lock);

	drm_dev->dev_private = private;

	INIT_LIST_HEAD(&private->psr_list);
	mutex_init(&private->psr_list_lock);
	mutex_init(&private->commit_lock);

	private->hdmi_pll.pll = devm_clk_get_optional(dev, "hdmi-tmds-pll");
	if (PTR_ERR(private->hdmi_pll.pll) == -EPROBE_DEFER) {
		ret = -EPROBE_DEFER;
		goto err_free;
	} else if (IS_ERR(private->hdmi_pll.pll)) {
		dev_err(dev, "failed to get hdmi-tmds-pll\n");
		ret = (int)PTR_ERR(private->hdmi_pll.pll);
		goto err_free;
	} else {
		/* Intentionally Empty */
	}
	private->default_pll.pll = devm_clk_get_optional(dev, "default-vop-pll");
	if (PTR_ERR(private->default_pll.pll) == -EPROBE_DEFER) {
		ret = -EPROBE_DEFER;
		goto err_free;
	} else if (IS_ERR(private->default_pll.pll)) {
		dev_err(dev, "failed to get default vop pll\n");
		ret = (int)PTR_ERR(private->default_pll.pll);
		goto err_free;
	} else {
		/* Intentionally Empty */
	}

	ret = drmm_mode_config_init(drm_dev);
	if (ret != 0) {
		goto err_free;
	}

	rockchip_drm_mode_config_init(drm_dev);
	(void)rockchip_drm_create_properties(drm_dev);
	/* Try to bind all sub drivers. */
	ret = component_bind_all(dev, drm_dev);
	if (ret != 0) {
		goto err_mode_config_cleanup;
	}

	rockchip_attach_connector_property(drm_dev);
	ret = drm_vblank_init(drm_dev, (u32)drm_dev->mode_config.num_crtc);
	if (ret != 0) {
		goto err_unbind_all;
	}

	drm_mode_config_reset(drm_dev);
	rockchip_drm_set_property_default(drm_dev);

	/*
	 * enable drm irq mode.
	 * - with irq_enabled = true, we can use the vblank feature.
	 */
	drm_dev->irq_enabled = (_Bool)true;

	/* init kms poll for handling hpd */
	drm_kms_helper_poll_init(drm_dev);

	ret = rockchip_drm_init_iommu(drm_dev);
	if (ret != 0) {
		goto err_unbind_all;
	}

	(void)rockchip_gem_pool_init(drm_dev);
	ret = of_reserved_mem_device_init(drm_dev->dev);
	if (ret != 0) {
		DRM_DEBUG_KMS("No reserved memory region assign to drm\n");
	}

	rockchip_drm_show_logo(drm_dev);

	ret = rockchip_drm_fbdev_init(drm_dev);
	if (ret != 0) {
		goto err_iommu_cleanup;
	}

	drm_dev->mode_config.allow_fb_modifiers = (_Bool)true;

	ret = drm_dev_register(drm_dev, 0);
	if (ret != 0) {
		goto err_kms_helper_poll_fini;
	}

	rockchip_drm_error_event_init(drm_dev);

	return 0;
err_kms_helper_poll_fini:
	rockchip_gem_pool_destroy(drm_dev);
	drm_kms_helper_poll_fini(drm_dev);
	rockchip_drm_fbdev_fini(drm_dev);
err_iommu_cleanup:
	rockchip_iommu_cleanup(drm_dev);
err_unbind_all:
	component_unbind_all(dev, drm_dev);
err_mode_config_cleanup:
	drm_mode_config_cleanup(drm_dev);
err_free:
	drm_dev->dev_private = NULL;
	dev_set_drvdata(dev, NULL);
	drm_dev_put(drm_dev);
	return ret;
}

static void rockchip_drm_unbind(struct device *dev)
{
	struct drm_device *drm_dev = dev_get_drvdata(dev);

	rockchip_drm_error_event_fini(drm_dev);
	drm_dev_unregister(drm_dev);

	rockchip_drm_fbdev_fini(drm_dev);
	rockchip_gem_pool_destroy(drm_dev);
	drm_kms_helper_poll_fini(drm_dev);

	drm_atomic_helper_shutdown(drm_dev);
	component_unbind_all(dev, drm_dev);
	drm_mode_config_cleanup(drm_dev);
	rockchip_iommu_cleanup(drm_dev);

	drm_dev->dev_private = NULL;
	dev_set_drvdata(dev, NULL);
	drm_dev_put(drm_dev);
}

static void rockchip_drm_crtc_cancel_pending_vblank(struct drm_crtc *crtc,
						    struct drm_file *file_priv)
{
	struct rockchip_drm_private *priv = crtc->dev->dev_private;
	unsigned int pipe = drm_crtc_index(crtc);

	if (pipe < (u32)ROCKCHIP_MAX_CRTC &&
	    priv->crtc_funcs[pipe] != NULL &&
	    priv->crtc_funcs[pipe]->cancel_pending_vblank != NULL) {
		priv->crtc_funcs[pipe]->cancel_pending_vblank(crtc, file_priv);
	}
}

static int rockchip_drm_open(struct drm_device *dev, struct drm_file *file)
{
	struct drm_crtc *crtc;

	if (dev == NULL) {
		return -1;
	}

	drm_for_each_crtc(crtc, dev) {
		crtc->primary->fb = NULL;
	}

	return 0;
}

static void rockchip_drm_postclose(struct drm_device *dev,
				   struct drm_file *file_priv)
{
	struct drm_crtc *crtc;

	if (dev == NULL) {
		return;
	}

	list_for_each_entry(crtc, &dev->mode_config.crtc_list, head) {
		rockchip_drm_crtc_cancel_pending_vblank(crtc, file_priv);
	}
}

static void rockchip_drm_lastclose(struct drm_device *dev)
{
	struct rockchip_drm_private *priv = dev->dev_private;

	if (!priv->logo) {
		(void)drm_fb_helper_restore_fbdev_mode_unlocked(priv->fbdev_helper);
	}
}

static struct drm_pending_vblank_event *
rockchip_drm_add_vcnt_event(struct drm_crtc *crtc, union drm_wait_vblank *vblwait,
			    struct drm_file *file_priv)
{
	struct drm_pending_vblank_event *e;
	struct drm_device *dev = crtc->dev;
	unsigned long flags;

	e = kzalloc(sizeof(*e), GFP_KERNEL);
	if (!e) {
		return NULL;
	}

	e->pipe = drm_crtc_index(crtc);
	e->event.base.type = DRM_EVENT_ROCKCHIP_CRTC_VCNT;
	e->event.base.length = sizeof(e->event.vbl);
	e->event.vbl.crtc_id = crtc->base.id;
	e->event.vbl.user_data = vblwait->request.signal;

	spin_lock_irqsave(&dev->event_lock, flags);
	(void)drm_event_reserve_init_locked(dev, file_priv, &e->base, &e->event.base);
	spin_unlock_irqrestore(&dev->event_lock, flags);

	return e;
}

static int rockchip_drm_get_vcnt_event_ioctl(struct drm_device *dev, void *data,
					     struct drm_file *file_priv)
{
	struct rockchip_drm_private *priv = dev->dev_private;
	union drm_wait_vblank *vblwait = data;
	struct drm_pending_vblank_event *e;
	struct drm_crtc *crtc;
	unsigned int flags, pipe;

	flags = (u32)vblwait->request.type & (u32)((u32)_DRM_VBLANK_FLAGS_MASK | (u32)_DRM_ROCKCHIP_VCNT_EVENT);
	pipe = ((u32)vblwait->request.type & (u32)_DRM_VBLANK_HIGH_CRTC_MASK);
	if (pipe != 0U) {
		pipe = pipe >> (u32)_DRM_VBLANK_HIGH_CRTC_SHIFT;
	} else {
		pipe = (flags & (u32)_DRM_VBLANK_SECONDARY) != 0U ? 1U : 0U;
	}

	crtc = drm_crtc_from_index(dev, (int)pipe);

	if ((flags & (u32)_DRM_ROCKCHIP_VCNT_EVENT) != 0U) {
		e = rockchip_drm_add_vcnt_event(crtc, vblwait, file_priv);
		if (pipe < (u32)ROCKCHIP_MAX_CRTC && priv) {
			priv->vcnt[pipe].event = e;
		}
	}

	return 0;
}

static const struct drm_ioctl_desc rockchip_ioctls[] = {
	DRM_IOCTL_DEF_DRV(ROCKCHIP_GEM_CREATE, rockchip_gem_create_ioctl,
			  DRM_UNLOCKED | DRM_AUTH | DRM_RENDER_ALLOW),
	DRM_IOCTL_DEF_DRV(ROCKCHIP_GEM_MAP_OFFSET,
			  rockchip_gem_map_offset_ioctl,
			  DRM_UNLOCKED | DRM_AUTH | DRM_RENDER_ALLOW),
	DRM_IOCTL_DEF_DRV(ROCKCHIP_GEM_GET_PHYS, rockchip_gem_get_phys_ioctl,
			  DRM_UNLOCKED | DRM_AUTH | DRM_RENDER_ALLOW),
	DRM_IOCTL_DEF_DRV(ROCKCHIP_GET_VCNT_EVENT, rockchip_drm_get_vcnt_event_ioctl,
			  DRM_UNLOCKED),
};

static const struct file_operations rockchip_drm_driver_fops = {
	.owner = THIS_MODULE,
	.open = drm_open,
	.mmap = rockchip_gem_mmap,
	.poll = drm_poll,
	.read = drm_read,
	.unlocked_ioctl = drm_ioctl,
	.compat_ioctl = drm_compat_ioctl,
	.release = drm_release,
};

static int rockchip_drm_gem_dmabuf_begin_cpu_access(struct dma_buf *dma_buf,
						    enum dma_data_direction dir)
{
	struct drm_gem_object *obj = dma_buf->priv;

	return rockchip_gem_prime_begin_cpu_access(obj, dir);
}

static int rockchip_drm_gem_dmabuf_end_cpu_access(struct dma_buf *dma_buf,
						  enum dma_data_direction dir)
{
	struct drm_gem_object *obj = dma_buf->priv;

	return rockchip_gem_prime_end_cpu_access(obj, dir);
}

static const struct dma_buf_ops rockchip_drm_gem_prime_dmabuf_ops = {
	.cache_sgt_mapping = (_Bool)true,
	.attach = drm_gem_map_attach,
	.detach = drm_gem_map_detach,
	.map_dma_buf = drm_gem_map_dma_buf,
	.unmap_dma_buf = drm_gem_unmap_dma_buf,
	.release = drm_gem_dmabuf_release,
	.mmap = drm_gem_dmabuf_mmap,
	.vmap = drm_gem_dmabuf_vmap,
	.vunmap = drm_gem_dmabuf_vunmap,
	.get_uuid = drm_gem_dmabuf_get_uuid,
	.begin_cpu_access = rockchip_drm_gem_dmabuf_begin_cpu_access,
	.end_cpu_access = rockchip_drm_gem_dmabuf_end_cpu_access,
};

static struct drm_gem_object *rockchip_drm_gem_prime_import_dev(struct drm_device *dev,
								struct dma_buf *dma_buf,
								struct device *attach_dev)
{
	struct dma_buf_attachment *attach;
	struct sg_table *sgt;
	struct drm_gem_object *obj;
	int ret;

	if (dma_buf->ops == &rockchip_drm_gem_prime_dmabuf_ops) {
		obj = dma_buf->priv;
		if (obj->dev == dev) {
			/*
			 * Importing dmabuf exported from out own gem increases
			 * refcount on gem itself instead of f_count of dmabuf.
			 */
			drm_gem_object_get(obj);
			return obj;
		}
	}

	if (dev->driver->gem_prime_import_sg_table == NULL) {
		return (struct drm_gem_object *)ERR_PTR(-EINVAL);
	}

	attach = dma_buf_attach(dma_buf, attach_dev);
	if (IS_ERR(attach)) {
		return (struct drm_gem_object *)ERR_CAST(attach);
	}

	get_dma_buf(dma_buf);

	sgt = dma_buf_map_attachment(attach, DMA_BIDIRECTIONAL);
	if (IS_ERR(sgt)) {
		ret = (int)PTR_ERR(sgt);
		goto fail_detach;
	}

	obj = dev->driver->gem_prime_import_sg_table(dev, attach, sgt);
	if (IS_ERR(obj)) {
		ret = (int)PTR_ERR(obj);
		goto fail_unmap;
	}

	obj->import_attach = attach;
	obj->resv = dma_buf->resv;

	return obj;

fail_unmap:
	dma_buf_unmap_attachment(attach, sgt, DMA_BIDIRECTIONAL);
fail_detach:
	dma_buf_detach(dma_buf, attach);
	dma_buf_put(dma_buf);

	return (struct drm_gem_object *)ERR_PTR(ret);
}

static struct drm_gem_object *rockchip_drm_gem_prime_import(struct drm_device *dev,
							    struct dma_buf *dma_buf)
{
	return rockchip_drm_gem_prime_import_dev(dev, dma_buf, dev->dev);
}

static struct dma_buf *rockchip_drm_gem_prime_export(struct drm_gem_object *obj,
						     int flags)
{
	struct drm_device *dev = obj->dev;
	struct dma_buf_export_info exp_info = {
		.exp_name = KBUILD_MODNAME, /* white lie for debug */
		.owner = dev->driver->fops->owner,
		.ops = &rockchip_drm_gem_prime_dmabuf_ops,
		.size = obj->size,
		.flags = flags,
		.priv = obj,
		.resv = obj->resv,
	};

	return drm_gem_dmabuf_export(dev, &exp_info);
}

static struct drm_driver rockchip_drm_driver = {
	.driver_features	= DRIVER_MODESET | DRIVER_GEM | DRIVER_ATOMIC | DRIVER_RENDER,
	.postclose		= rockchip_drm_postclose,
	.lastclose		= rockchip_drm_lastclose,
	.open			= rockchip_drm_open,
	.gem_vm_ops		= &drm_gem_cma_vm_ops,
	.gem_free_object_unlocked = rockchip_gem_free_object,
	.dumb_create		= rockchip_gem_dumb_create,
	.prime_handle_to_fd	= drm_gem_prime_handle_to_fd,
	.prime_fd_to_handle	= drm_gem_prime_fd_to_handle,
	.gem_prime_import	= rockchip_drm_gem_prime_import,
	.gem_prime_export	= rockchip_drm_gem_prime_export,
	.gem_prime_get_sg_table	= rockchip_gem_prime_get_sg_table,
	.gem_prime_import_sg_table	= rockchip_gem_prime_import_sg_table,
	.gem_prime_vmap		= rockchip_gem_prime_vmap,
	.gem_prime_vunmap	= rockchip_gem_prime_vunmap,
	.gem_prime_mmap		= rockchip_gem_mmap_buf,
#ifdef CONFIG_DEBUG_FS
	.debugfs_init		= rockchip_drm_debugfs_init,
#endif
	.ioctls			= rockchip_ioctls,
	.num_ioctls		= ARRAY_SIZE(rockchip_ioctls),
	.fops			= &rockchip_drm_driver_fops,
	.name	= DRIVER_NAME,
	.desc	= DRIVER_DESC,
	.date	= DRIVER_DATE,
	.major	= DRIVER_MAJOR,
	.minor	= DRIVER_MINOR,
};

#ifdef CONFIG_PM_SLEEP
static int rockchip_drm_sys_suspend(struct device *dev)
{
	struct drm_device *drm = dev_get_drvdata(dev);

	return drm_mode_config_helper_suspend(drm);
}

static int rockchip_drm_sys_resume(struct device *dev)
{
	struct drm_device *drm = dev_get_drvdata(dev);

	return drm_mode_config_helper_resume(drm);
}
#endif

static const struct dev_pm_ops rockchip_drm_pm_ops = {
	SET_SYSTEM_SLEEP_PM_OPS(rockchip_drm_sys_suspend,
				rockchip_drm_sys_resume)
};

#define MAX_ROCKCHIP_SUB_DRIVERS 16
static struct platform_driver *rockchip_sub_drivers[MAX_ROCKCHIP_SUB_DRIVERS];
static int num_rockchip_sub_drivers;

/*
 * Check if a vop endpoint is leading to a rockchip subdriver or bridge.
 * Should be called from the component bind stage of the drivers
 * to ensure that all subdrivers are probed.
 *
 * @ep: endpoint of a rockchip vop
 *
 * returns true if subdriver, false if external bridge and -ENODEV
 * if remote port does not contain a device.
 */
#if 0
int rockchip_drm_endpoint_is_subdriver(struct device_node *ep)
{
	struct device_node *node = of_graph_get_remote_port_parent(ep);
	struct platform_device *pdev;
	struct device_driver *drv;
	int i;

	if (!node) {
		return -ENODEV;
	}

	/* status disabled will prevent creation of platform-devices */
	pdev = of_find_device_by_node(node);
	of_node_put(node);
	if (!pdev) {
		return -ENODEV;
	}

	/*
	 * All rockchip subdrivers have probed at this point, so
	 * any device not having a driver now is an external bridge.
	 */
	drv = pdev->dev.driver;
	if (!drv) {
		platform_device_put(pdev);
		return (_Bool)false;
	}

	for (i = 0; i < num_rockchip_sub_drivers; i++) {
		if (rockchip_sub_drivers[i] == to_platform_driver(drv)) {
			platform_device_put(pdev);
			return (_Bool)true;
		}
	}

	platform_device_put(pdev);
	return (_Bool)false;
}
#endif

static int compare_dev(struct device *dev, void *data)
{
	return dev == (struct device *)data ? 1 : 0;
}

static void rockchip_drm_match_remove(struct device *dev)
{
	struct device_link *link;

	list_for_each_entry(link, &dev->links.consumers, s_node) {
		device_link_del(link);
	}
}

static struct component_match *rockchip_drm_match_add(struct device *dev)
{
	struct component_match *match = NULL;
	int i;

	for (i = 0; i < num_rockchip_sub_drivers; i++) {
		struct platform_driver *drv = rockchip_sub_drivers[i];
		struct device *p = NULL, *d;

		do {
			d = platform_find_device_by_driver(p, &drv->driver);
			put_device(p);
			p = d;

			if (!d) {
				break;
			}

			(void)device_link_add(dev, d, (u32)DL_FLAG_STATELESS);
			component_match_add(dev, &match, compare_dev, d);
		} while ((_Bool)true);
	}

	if (IS_ERR(match)) {
		rockchip_drm_match_remove(dev);
	}

	return match ?: ERR_PTR(-ENODEV);
}

static const struct component_master_ops rockchip_drm_ops = {
	.bind = rockchip_drm_bind,
	.unbind = rockchip_drm_unbind,
};

static int rockchip_drm_platform_of_probe(struct device *dev)
{
	struct device_node *np = dev->of_node;
	struct device_node *port;
	bool found = (_Bool)false;
	int i;

	if (!np) {
		return -ENODEV;
	}

	i = 0;
	for (;;) {
		struct device_node *iommu;

		port = of_parse_phandle(np, "ports", i);
		if (!port) {
			break;
		}

		if (!of_device_is_available(port->parent)) {
			of_node_put(port);
			i++;
			continue;
		}

		iommu = of_parse_phandle(port->parent, "iommus", 0);
		if (!of_device_is_available(iommu)) {
			DRM_DEV_DEBUG(dev,
				      "no iommu attached for %pOF, using non-iommu buffers\n",
				      port->parent);
			/*
			 * if there is a crtc not support iommu, force set all
			 * crtc use non-iommu buffer.
			 */
			is_support_iommu = (_Bool)false;
		}

		found = (_Bool)true;

		if (of_property_read_bool(iommu, "rockchip,reserve-map")) {
			iommu_reserve_map = (_Bool)true;
		}

		of_node_put(iommu);
		of_node_put(port);
		i++;
	}

	if (i == 0) {
		DRM_DEV_ERROR(dev, "missing 'ports' property\n");
		return -ENODEV;
	}

	if (!found) {
		DRM_DEV_ERROR(dev,
			      "No available vop found for display-subsystem.\n");
		return -ENODEV;
	}

	return 0;
}

static int rockchip_drm_platform_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct component_match *match = NULL;
	int ret;

	ret = rockchip_drm_platform_of_probe(dev);
#if !IS_ENABLED(CONFIG_DRM_ROCKCHIP_VVOP)
	if (ret != 0) {
		return ret;
	}
#endif

	match = rockchip_drm_match_add(dev);
	if (IS_ERR(match)) {
		return (int)PTR_ERR(match);
	}

	ret = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64));
	if (ret != 0) {
		goto err;
	}

	ret = component_master_add_with_match(dev, &rockchip_drm_ops, match);
	if (ret < 0) {
		goto err;
	}

	return 0;
err:
	rockchip_drm_match_remove(dev);

	return ret;
}

static int rockchip_drm_platform_remove(struct platform_device *pdev)
{
	component_master_del(&pdev->dev, &rockchip_drm_ops);

	rockchip_drm_match_remove(&pdev->dev);

	return 0;
}

static void rockchip_drm_platform_shutdown(struct platform_device *pdev)
{
	struct drm_device *drm = platform_get_drvdata(pdev);

	if (drm != NULL) {
		drm_atomic_helper_shutdown(drm);
	}
}

static const struct of_device_id rockchip_drm_dt_ids[] = {
	{ .compatible = "rockchip,display-subsystem", },
	{ /* sentinel */ },
};
MODULE_DEVICE_TABLE(of, rockchip_drm_dt_ids);

static struct platform_driver rockchip_drm_platform_driver = {
	.probe = rockchip_drm_platform_probe,
	.remove = rockchip_drm_platform_remove,
	.shutdown = rockchip_drm_platform_shutdown,
	.driver = {
		.name = "rockchip-drm",
		.of_match_table = rockchip_drm_dt_ids,
		.pm = &rockchip_drm_pm_ops,
	},
};

#define ADD_ROCKCHIP_SUB_DRIVER(drv, cond) { \
	if (IS_ENABLED(cond) && \
	    (u32)WARN_ON((int)num_rockchip_sub_drivers >= (int)MAX_ROCKCHIP_SUB_DRIVERS) == 0U) { \
		rockchip_sub_drivers[num_rockchip_sub_drivers] = &(drv); \
		num_rockchip_sub_drivers++; \
	} \
}

static int __init rockchip_drm_init(void)
{
	int ret;

	num_rockchip_sub_drivers = 0;
#if IS_ENABLED(CONFIG_DRM_ROCKCHIP_VVOP)
	ADD_ROCKCHIP_SUB_DRIVER(vvop_platform_driver, CONFIG_DRM_ROCKCHIP_VVOP);
#else
	ADD_ROCKCHIP_SUB_DRIVER(vop_platform_driver, CONFIG_ROCKCHIP_VOP);
	ADD_ROCKCHIP_SUB_DRIVER(vop2_platform_driver, CONFIG_ROCKCHIP_VOP2);
	ADD_ROCKCHIP_SUB_DRIVER(vconn_platform_driver, CONFIG_ROCKCHIP_VCONN);
	ADD_ROCKCHIP_SUB_DRIVER(rockchip_lvds_driver,
				CONFIG_ROCKCHIP_LVDS);
	ADD_ROCKCHIP_SUB_DRIVER(rockchip_dp_driver,
				CONFIG_ROCKCHIP_ANALOGIX_DP);
	ADD_ROCKCHIP_SUB_DRIVER(cdn_dp_driver, CONFIG_ROCKCHIP_CDN_DP);
	ADD_ROCKCHIP_SUB_DRIVER(dw_hdmi_rockchip_pltfm_driver,
				CONFIG_ROCKCHIP_DW_HDMI);
	ADD_ROCKCHIP_SUB_DRIVER(dw_mipi_dsi_rockchip_driver,
				CONFIG_ROCKCHIP_DW_MIPI_DSI);
	ADD_ROCKCHIP_SUB_DRIVER(dw_mipi_dsi2_rockchip_driver,
				CONFIG_ROCKCHIP_DW_MIPI_DSI);
	ADD_ROCKCHIP_SUB_DRIVER(inno_hdmi_driver, CONFIG_ROCKCHIP_INNO_HDMI);
	ADD_ROCKCHIP_SUB_DRIVER(rk3066_hdmi_driver,
				CONFIG_ROCKCHIP_RK3066_HDMI);
	ADD_ROCKCHIP_SUB_DRIVER(rockchip_rgb_driver, CONFIG_ROCKCHIP_RGB);
	ADD_ROCKCHIP_SUB_DRIVER(rockchip_tve_driver, CONFIG_ROCKCHIP_DRM_TVE);
	ADD_ROCKCHIP_SUB_DRIVER(dw_dp_driver, CONFIG_ROCKCHIP_DW_DP);

#endif
	ret = platform_register_drivers(rockchip_sub_drivers,
					(u32)num_rockchip_sub_drivers);
	if (ret != 0) {
		return ret;
	}

	ret = platform_driver_register(&rockchip_drm_platform_driver);
	if (ret != 0) {
		goto err_unreg_drivers;
	}

	rockchip_gem_get_ddr_info();

	return 0;

err_unreg_drivers:
	platform_unregister_drivers(rockchip_sub_drivers,
				    (u32)num_rockchip_sub_drivers);
	return ret;
}

static void __exit rockchip_drm_fini(void)
{
	platform_driver_unregister(&rockchip_drm_platform_driver);

	platform_unregister_drivers(rockchip_sub_drivers,
				    (unsigned int)num_rockchip_sub_drivers);
}

#ifdef CONFIG_VIDEO_REVERSE_IMAGE
fs_initcall(rockchip_drm_init);
#else
module_init(rockchip_drm_init);
#endif
module_exit(rockchip_drm_fini);

MODULE_AUTHOR("Mark Yao <mark.yao@rock-chips.com>");
MODULE_DESCRIPTION("ROCKCHIP DRM Driver");
MODULE_LICENSE("GPL v2");
