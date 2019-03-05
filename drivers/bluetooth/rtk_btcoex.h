/*
 *
 *  Realtek Bluetooth USB driver
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */
#ifndef RTK_BTCOEX_H
#define RTK_BTCOEX_H
#include <linux/interrupt.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/types.h>
#include <linux/sched.h>
#include <linux/skbuff.h>
#include <linux/errno.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/poll.h>

#include <linux/version.h>
#include <linux/pm_runtime.h>
#include <linux/firmware.h>
#include <linux/suspend.h>


#define RTKBT_DBG_FLAG 0

#if RTKBT_DBG_FLAG
#define RTKBT_DBG(fmt, arg...) printk(KERN_INFO "rtk_btcoex: " fmt "\n" , ## arg)
#else
#define RTKBT_DBG(fmt, arg...)
#endif
#define RTKBT_INFO(fmt, arg...) printk(KERN_INFO "rtk_btcoex: " fmt "\n" , ## arg)
#define RTKBT_WARN(fmt, arg...) printk(KERN_WARNING "rtk_btcoex: " fmt "\n" , ## arg)
#define RTKBT_ERR(fmt, arg...) printk(KERN_ERR "rtk_btcoex: " fmt "\n" , ## arg)

#endif
