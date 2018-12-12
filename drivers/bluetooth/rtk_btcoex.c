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

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/types.h>
#include <linux/sched.h>
#include <linux/errno.h>
#include <linux/skbuff.h>
#include <linux/usb.h>

#include <linux/ioctl.h>
#include <linux/io.h>
#include <linux/firmware.h>
#include <linux/vmalloc.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/reboot.h>
#include "rtk_btcoex.h"

#define RTKBT_RELEASE_NAME "test"
#define VERSION "4.2.1"

#define BTCOEX_CHAR_DEVICE_NAME "rtk_btcoex"

static dev_t btcoex_devid; /* bt coex char device number */
static struct cdev btcoex_char_dev; /* bt coex character device structure */
static struct class *btcoex_char_class; /* device class for usb char driver */
static wait_queue_head_t btcoex_read_wait;

static struct sk_buff_head rtw_q;
static u8 rtw_coex_on;

u8 rtw_btcoex_wifi_to_bt(u8 *msg, u8 msg_size)
{
	struct sk_buff *nskb;

	if (!rtw_coex_on) {
		RTKBT_WARN("Bluetooth is closed");
		return 0;
	}

	nskb = alloc_skb(msg_size, GFP_ATOMIC);
	if (!nskb) {
		RTKBT_ERR("Couldnt alloc skb for WiFi coex message");
		return 0;
	}

	memcpy(skb_put(nskb, msg_size), msg, msg_size);
	skb_queue_tail(&rtw_q, nskb);
  wake_up_interruptible(&btcoex_read_wait);
	return 1;
}
EXPORT_SYMBOL(rtw_btcoex_wifi_to_bt);

static int rtk_send_coexmsg2wifi(u8 *msg, u8 size)
{
	u8 result;
	u8 (*btmsg_to_wifi)(u8 *, u8);

	btmsg_to_wifi = __symbol_get(VMLINUX_SYMBOL_STR(rtw_btcoex_bt_to_wifi));

	if (!btmsg_to_wifi) {
		return -1;
	}

	result = btmsg_to_wifi(msg, size);
	__symbol_put(VMLINUX_SYMBOL_STR(rtw_btcoex_bt_to_wifi));
	if (!result) {
		RTKBT_ERR("Couldnt send coex msg to WiFi");
		return -1;
	} else if (result == 1){
		/* successful to send message */
		return 0;
	} else {
		RTKBT_ERR("Unknown result %d", result);
		return -1;
	}
}

static int btcoex_open(struct inode *inode_p, struct file *file_p)
{
    skb_queue_head_init(&rtw_q);
	  rtw_coex_on = 1;
    return nonseekable_open(inode_p, file_p);
}

static int btcoex_close(struct inode  *inode_p, struct file *file_p)
{
    rtw_coex_on = 0;
	  skb_queue_purge(&rtw_q);
    return 0;
}

static ssize_t btcoex_read(struct file *file_p, char __user *buf_p, size_t count, loff_t *pos_p)
{
    ssize_t ret = 0;
    struct sk_buff *skb;
    int len;
    while(count)
    {
        ret = wait_event_interruptible(btcoex_read_wait, !skb_queue_empty(&rtw_q));
        if (ret < 0) {
            RTKBT_ERR("%s: wait event is signaled %d", __func__, ret);
            break;
        }
        skb = skb_dequeue(&rtw_q);
        if(skb->len > count) {
            skb_queue_head(&rtw_q, skb);
            return -ENOMEM;
        }
        len = min_t(unsigned int, skb->len, count);
        if (copy_to_user(buf_p, skb->data, len)) {
            skb_queue_head(&rtw_q, skb);
            return -EFAULT;
        }
        kfree_skb(skb);
        break;
    }
    return len;
}

static ssize_t btcoex_write(struct file *file_p, const char __user *buf_p, size_t count, loff_t *pos_p)
{
    u8 *msg_buff = NULL;
    msg_buff = vmalloc(count);
    if (!msg_buff)
        return -ENOMEM;

    if (copy_from_user(msg_buff, buf_p, count)) {
        RTKBT_ERR("%s: Failed to get data from user space", __func__);
        vfree(msg_buff);
        return -EFAULT;
    }
    rtk_send_coexmsg2wifi(msg_buff, count);
    vfree(msg_buff);
    return count;
}

static unsigned int btcoex_poll(struct file *file_p, poll_table *wait)
{

    RTKBT_DBG("%s: BT coex char device is polling", __func__);

    poll_wait(file_p, &btcoex_read_wait, wait);

    if (!skb_queue_empty(&rtw_q))
        return POLLIN | POLLRDNORM;

    return POLLOUT | POLLWRNORM;
}

static long btcoex_ioctl(struct file *file_p, unsigned int cmd, unsigned long arg){
    int ret = 0;

    return ret;
}


static struct file_operations btcoex_chrdev_ops  = {
    open    :    btcoex_open,
    release    :    btcoex_close,
    read    :    btcoex_read,
    write    :    btcoex_write,
    poll    :    btcoex_poll,
    unlocked_ioctl   :   btcoex_ioctl,
};

static int btcoex_chr_init(void)
{
    int res = 0;
    struct device *dev;

    RTKBT_INFO("Register usb char device interface for BT driver");

    btcoex_char_class = class_create(THIS_MODULE, BTCOEX_CHAR_DEVICE_NAME);
    if (IS_ERR(btcoex_char_class)) {
        RTKBT_ERR("Failed to create bt char class");
        return PTR_ERR(btcoex_char_class);
    }

    res = alloc_chrdev_region(&btcoex_devid, 0, 1, BTCOEX_CHAR_DEVICE_NAME);
    if (res < 0) {
        RTKBT_ERR("Failed to allocate bt char device");
        goto err_alloc;
    }

    dev = device_create(btcoex_char_class, NULL, btcoex_devid, NULL, BTCOEX_CHAR_DEVICE_NAME);
    if (IS_ERR(dev)) {
        RTKBT_ERR("Failed to create bt char device");
        res = PTR_ERR(dev);
        goto err_create;
    }

    cdev_init(&btcoex_char_dev, &btcoex_chrdev_ops);
    res = cdev_add(&btcoex_char_dev, btcoex_devid, 1);
    if (res < 0) {
        RTKBT_ERR("Failed to add bt char device");
        goto err_add;
    }

    init_waitqueue_head(&btcoex_read_wait);
    return 0;

err_add:
    device_destroy(btcoex_char_class, btcoex_devid);
err_create:
    unregister_chrdev_region(btcoex_devid, 1);
err_alloc:
    class_destroy(btcoex_char_class);
    return res;
}

static void btcoex_chr_exit(void)
{
    RTKBT_INFO("Unregister usb char device interface for BT driver");

    device_destroy(btcoex_char_class, btcoex_devid);
    cdev_del(&btcoex_char_dev);
    unregister_chrdev_region(btcoex_devid, 1);
    class_destroy(btcoex_char_class);

    return;
}

static int __init btcoex_init(void)
{
    int err;

    RTKBT_INFO("RTKBT_RELEASE_NAME: %s",RTKBT_RELEASE_NAME);
    RTKBT_INFO("Realtek Bluetooth coex driver module init, version %s", VERSION);
    err = btcoex_chr_init();
    if (err < 0) {
        /* usb register will go on, even bt char register failed */
        RTKBT_ERR("Failed to register coex char device interfaces");
    }
    return err;
}

static void __exit btcoex_exit(void)
{
    RTKBT_INFO("Realtek Bluetooth coex driver module exit");
    btcoex_chr_exit();
}

module_init(btcoex_init);
module_exit(btcoex_exit);


MODULE_AUTHOR("Realtek Corporation");
MODULE_DESCRIPTION("Realtek Bluetooth wifi-bt coex driver version");
MODULE_VERSION(VERSION);
MODULE_LICENSE("GPL");
