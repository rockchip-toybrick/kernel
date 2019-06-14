#!/bin/bash

JOB=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`
DTB=toybrick-$1

function help()
{
	echo "Usage: ./make.sh sx"
	echo
	echo "Parameter:"
	echo "1) sx:    should be s0, s1, s2 ..."
	echo
	echo "e.g. ./make.sh s0"
}

if [ $# -lt 1 ];then
	help
	exit 1
fi
if [ ! -f arch/arm64/boot/dts/rockchip/rk1808-${DTB}.dts ]; then
	help
	exit 1
fi

mkdir -p boot_linux/extlinux
make rk1808_linux_defconfig
make ARCH=arm64 rk1808-${DTB}.img -j${JOB}
cp -f arch/arm64/boot/dts/rockchip/rk1808-${DTB}.dtb boot_linux/extlinux/rk1808.dtb
cp -f arch/arm64/boot/Image boot_linux/extlinux/
cp -f extlinux.conf boot_linux/extlinux/extlinux.conf
cp -f initramfs-4.4-1.rockchip.fc28.aarch64.img boot_linux/
if [ "`uname -i`" == "aarch64" ]; then
	echo y | mke2fs -b 4096 -d boot_linux -i 8192 -t ext2 boot_linux.img $((64 * 1024 * 1024 / 4096))
else
	genext2fs -b 32768 -B $((64 * 1024 * 1024 / 32768)) -d boot_linux -i 8192 -U boot_linux.img
fi
rm -rf boot_linux

exit 0

