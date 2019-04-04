#!/bin/bash

JOB=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`
DTB=toybrick-$2

function help()
{
	echo "Usage: ./make.sh os board"
	echo
	echo "Parameter:"
	echo "1) os:    should be android or linux"
	echo "2) board: should be prod for TB-RK3399ProD or prop for TB-RK3399ProP"
	echo
	echo "e.g. ./make.sh android prod"
	echo "     ./make.sh android prop"
    echo "     ./make.sh android bq96board"
	echo "     ./make.sh linux prod"
	echo "     ./make.sh linux prop"
    echo "     ./make.sh linux bq96board"
}

if [ $# -lt 2 ];then
	help
	exit 1
fi
if [ ! -f arch/arm64/boot/dts/rockchip/rk3399pro-${DTB}-linux.dts ]; then
	help
	exit 1
fi

case $1 in
	android)
		make rockchip_defconfig
		make ARCH=arm64 rk3399pro-${DTB}-android.img -j${JOB}
		;;
	linux)
		mkdir -p boot_linux/extlinux
        if [ ${DTB} == "toybrick-bq96board" ]; then
            make rockchip_bq96board_linux_defconfig
        else
            make rockchip_linux_defconfig
        fi
		make ARCH=arm64 rk3399pro-${DTB}-linux.img -j${JOB}
		cp -f arch/arm64/boot/dts/rockchip/rk3399pro-${DTB}-linux.dtb boot_linux/extlinux/rk3399pro.dtb
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

