#!/bin/bash

VERSION="2.0"
JOB=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`
DTB=toybrick-$1

function help()
{
	echo "Usage: ./make.sh board"
	echo
	echo "Parameter:"
	echo "1) board:"
	echo "   - s0: TB-RK1808S0"
	echo "   - m0: TB-RK1808M0"
	echo "   - x0: TB-RK1808X0"
	echo "   - cam0: TB-RK1808CAM0"
	echo
	echo "e.g. ./make.sh s0"
}

function make_extlinux_conf()
{
	echo "label rockchip-kernel-4.4" > boot_linux/extlinux/extlinux.conf
	echo "	kernel /extlinux/Image" >> boot_linux/extlinux/extlinux.conf
	echo "	fdt /extlinux/toybrick.dtb" >> boot_linux/extlinux/extlinux.conf
	echo "	append  earlycon=uart8250,mmio32,0xff1a0000 initrd=/initramfs-toybrick-${VERSION}.img root=PARTUUID=614e0000-0000-4b53-8000-1d28000054a9 rw rootwait rootfstype=ext4" >> boot_linux/extlinux/extlinux.conf
}


if [ $# -lt 1 ];then
	help
	exit 1
fi

rm -rf boot_linux
mkdir -p boot_linux/extlinux

make rk1808_linux_defconfig
DTB=rk1808-toybrick-$1
make ARCH=arm64 ${DTB}.img -j${JOB}

cp -f arch/arm64/boot/dts/rockchip/${DTB}.dtb boot_linux/extlinux/toybrick.dtb
cp -f arch/arm64/boot/Image boot_linux/extlinux/
make_extlinux_conf
cp -f initramfs-toybrick-${VERSION}.img boot_linux/
cp -f rescue.sh boot_linux/
if [ "`uname -i`" == "aarch64" ]; then
	echo y | mke2fs -b 4096 -d boot_linux -i 8192 -t ext2 boot_linux.img $((64 * 1024 * 1024 / 4096))
else
	genext2fs -b 32768 -B $((64 * 1024 * 1024 / 32768)) -d boot_linux -i 8192 -U boot_linux.img
fi

exit 0

