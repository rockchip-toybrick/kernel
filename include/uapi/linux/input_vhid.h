/*
 * Copyright 2020 Rockchip Electronics S.LSI Co. LTD
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#ifndef _UAPI_INPUT_VHID_H
#define _UAPI_INPUT_VHID_H

/* Virtual hid touchscreen's feature report id */
#define VHID_FEATURE_ID		0x02
/* Virtual hid touchscreen's points number */
#define VHID_POINTS		10
/* Virtual hid touchscreen's width */
#define VHID_WIDTH		1920
/* Virtual hid touchscreen's height */
#define VHID_HEIGHT		1080

enum {
	VHID_TYPE_UNKNOWN,
	VHID_TYPE_MOUSE,
	VHID_TYPE_KEYBOARD,
	/* Primary unmovable touch screen, such as i2c touch screen */
	VHID_TYPE_TOUCH_I2C,
	/* Extend removable touch screen, such as usb touch screen */
	VHID_TYPE_TOUCH_USB,
	VHID_TYPE_MAX,
};

enum {
	/* Report event to userspace */
	VHID_MODE_REAL,
	/* Report event to virtual hid device */
	VHID_MODE_VHID,
	/* Report event to userspace and virtual hid device */
	VHID_MODE_BOTH,
	VHID_MODE_MAX,
};

/**
 * struct input_vhid - used by virtural hid.
 * @type: input device type, such as mouse, keyboard or touch.
 * @mode: event report mode, support real, vhid and both mode.
 * @res_x: the origin X-coordinate of reserved rectangle.
 * @res_y: the origin Y-coordinate of reserved rectangle.
 * @res_w: the width of reserved rectangle.
 * @res_h: the height of reserved rectangle.
 * @max_x: the maximum X-coordinate.
 * @max_y: the maximum Y-coordinate.
 * @max_point: the maximum touch points.
 *
 * The structure is used to get and set input
 * device's control information.
 * Note:
 *   Vitrual hid control node: /sys/class/input/eventX/device/vhid
 *   1.Get control information:
 *     read(fd, &input_vhid, sizeof(struct input_vhid)).
 *   2.Set control information:
 *     1) mode: write(fd, "mode=m", len).
 *     2) reserved rectangle: write(fd, "res=x,y,w,h", len).
 */
struct input_vhid {
	int type;
	/* can be set with "mode=X" */
	int mode;
	/* Can be set with "res=x,y,w,h" */
	int res_x;
	int res_y;
	int res_w;
	int res_h;

	int max_x;
	int max_y;
	int max_point;
};

/**
 * struct input_vevent - used by virtural hid to report input event.
 * @type: input event type.
 * @code: input event code.
 * @value: input event value.
 *
 * The structure is used to get input event in
 * VHID_MODE_VHID and VHID_MODE_BOTH modes.
 * Note:
 *   Vitrual hid control node:
 *   /sys/class/input/eventX/device/vevent
 *   Get virtural event:
 *   read(fd, &input_vevent, sizeof(struct input_vevent)).
 */

struct input_vevent {
	unsigned short type;
	unsigned short code;
	int value;
};

#endif
