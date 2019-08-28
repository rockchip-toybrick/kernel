#!/bin/sh

# Add here to backup your files or fix system boot issue when rootfs crash

######### step1: create directory: /rootfs ########
# mkdir /rootfs

######## step2: mount rootfs partition ########
# In dual system, rootfs partition is /dev/mmcblk1p16
# mount /dev/mmcblk1p16 /rootfs
# In Linux system, rootfs partition is /dev/mmcblk1p4 
# mount /dev/mmcblk1p4 /rootfs

######## step3: save or fix #########
# Do something

######## step4: umount rootfs partition ########
# umount rootfs
