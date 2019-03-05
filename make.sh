#!/bin/bash

JOB=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`
DTB=eaidk

function help()
{
	echo "Usage: ./make.sh os"
	echo
	echo "Parameter:"
	echo "1) os:    should be android or linux"
	echo
	echo "e.g. ./make.sh android"
	echo "     ./make.sh linux"
}

if [ $# -lt 1 ];then
	help
	exit 1
fi

case $1 in
	android)
		make rockchip_defconfig
		make ARCH=arm64 rk3399-${DTB}-android.img -j${JOB}
		;;
	linux)
		mkdir -p boot_linux/extlinux
		make rockchip_linux_defconfig
		make ARCH=arm64 rk3399-${DTB}-linux.img -j${JOB}
		cp -f arch/arm64/boot/dts/rockchip/rk3399-${DTB}-linux.dtb boot_linux/extlinux/rk3399.dtb
		cp -f arch/arm64/boot/Image boot_linux/extlinux/
		cp -f extlinux.conf boot_linux/extlinux/
		genext2fs -b 32768 -B $((32 * 1024 * 1024 / 32768)) -d boot_linux -i 8192 -U boot_linux.img
		rm -rf boot_linux
		;;
	*)
		help
		exit 1
		;;
esac

exit 0

