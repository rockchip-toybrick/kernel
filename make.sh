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
	echo "     ./make.sh android 96ai"
	echo "     ./make.sh linux prod"
	echo "     ./make.sh linux prop"
	echo "     ./make.sh linux 96ai"
	echo "     ./make.sh linux ivc"
}

if [ $# -lt 2 ];then
	help
	exit 1
fi

case $1 in
	android)
		make rockchip_defconfig
		make ARCH=arm64 rk3399pro-${DTB}-android.img -j${JOB}
		;;
	linux)
		DTB=""
		mkdir -p boot_linux/extlinux
		case $2 in
			prod)
				make rockchip_linux_defconfig
				DTB=rk3399pro-toybrick-prod-linux
				;;
			prop)
				make rockchip_linux_defconfig
				DTB=rk3399pro-toybrick-prop-linux
				;;
			96ai)
				make rockchip_96ai_linux_defconfig
				DTB=rk3399pro-toybrick-96ai-linux
				;;
			ivc)
				make rockchip_96ai_linux_defconfig
				DTB=rk3399pro-toybrick-96ai-ivc
				;;
			*)
				help
				exit 1
				;;
		esac
		make ARCH=arm64 ${DTB}.img -j${JOB}
		cp -f arch/arm64/boot/dts/rockchip/${DTB}.dtb boot_linux/extlinux/toybrick.dtb
		cp -f arch/arm64/boot/Image boot_linux/extlinux/
		cp -f extlinux.conf boot_linux/extlinux/
		cp -f initramfs-4.4-1.rockchip.fc28.aarch64.img boot_linux/
		if [ "`uname -i`" == "aarch64" ]; then
			echo y | mke2fs -b 4096 -d boot_linux -i 8192 -t ext2 boot_linux.img $((64 * 1024 * 1024 / 4096))
		else
			genext2fs -b 32768 -B $((64 * 1024 * 1024 / 32768)) -d boot_linux -i 8192 -U boot_linux.img
		fi
		rm -rf boot_linux
		;;
	*)
		help
		exit 1
		;;
esac

exit 0

