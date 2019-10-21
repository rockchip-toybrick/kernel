#!/bin/bash

VERSION="2.0"
JOB=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`
DTB=toybrick-$2

function help()
{
	echo "Usage: ./make.sh os board"
	echo
	echo "Parameter:"
	echo "1) os: should be android or linux"
	echo "2) board:"
	echo "   - prod: TB-RK3399ProD"
	echo "   - prop: TB-RK3399ProP"
	echo "   - prox: TB-RK3399ProX"
	echo "   - 96ai: TB-96AI"
	echo
	echo "e.g. ./make.sh android prod"
	echo "     ./make.sh android prop"
	echo "     ./make.sh android 96ai"
	echo "     ./make.sh android prox"
	echo "     ./make.sh linux prod"
	echo "     ./make.sh linux prop"
	echo "     ./make.sh linux 96ai"
    echo "     ./make.sh linux prox"
}

function make_extlinux_conf()
{
	echo "label rockchip-kernel-4.4" > boot_linux/extlinux/extlinux.conf
	echo "	kernel /extlinux/Image" >> boot_linux/extlinux/extlinux.conf
	echo "	fdt /extlinux/toybrick.dtb" >> boot_linux/extlinux/extlinux.conf
	echo "	append  earlycon=uart8250,mmio32,0xff1a0000 initrd=/initramfs-toybrick-${VERSION}.img root=PARTUUID=614e0000-0000-4b53-8000-1d28000054a9 rw rootwait rootfstype=ext4" >> boot_linux/extlinux/extlinux.conf
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
		rm -rf boot_linux
		mkdir -p boot_linux/extlinux

		make rockchip_linux_defconfig
		case $2 in
			prod)
				DTB=rk3399pro-toybrick-prod-linux
				MODEL="TB-RK3399ProD"
				make ARCH=arm64 ${DTB}-edp.img -j${JOB}
				make ARCH=arm64 ${DTB}-mipi.img -j${JOB}
				cp -f arch/arm64/boot/dts/rockchip/${DTB}-edp.dtb boot_linux/extlinux/toybrick-edp.dtb
				cp -f arch/arm64/boot/dts/rockchip/${DTB}-mipi.dtb boot_linux/extlinux/toybrick-mipi.dtb
				;;
			prop)
				DTB=rk3399pro-toybrick-prop-linux
				;;
			96ai)
				DTB=rk3399pro-toybrick-96ai-linux
				;;
			prox)
                DTB=rk3399pro-toybrick-prox-linux
                ;;
			*)
				help
				exit 1
				;;
		esac
		make ARCH=arm64 ${DTB}.img -j${JOB}

		cp -f arch/arm64/boot/dts/rockchip/${DTB}.dtb boot_linux/extlinux/toybrick.dtb
		cp -f arch/arm64/boot/dts/rockchip/${DTB}.dtb boot_linux/extlinux/toybrick-default.dtb
		cp -f arch/arm64/boot/Image boot_linux/extlinux/
		make_extlinux_conf
		cp -f initramfs-toybrick-${VERSION}.img boot_linux/
		cp -f rescue.sh boot_linux/
		if [ "`uname -i`" == "aarch64" ]; then
			echo y | mke2fs -b 4096 -d boot_linux -i 8192 -t ext2 boot_linux.img $((64 * 1024 * 1024 / 4096))
		else
			genext2fs -b 32768 -B $((64 * 1024 * 1024 / 32768)) -d boot_linux -i 8192 -U boot_linux.img
		fi
		;;
	*)
		help
		exit 1
		;;
esac

exit 0

