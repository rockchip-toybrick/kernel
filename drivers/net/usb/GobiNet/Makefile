obj-m := GobiNet.o
GobiNet-objs := GobiUSBNet.o QMIDevice.o QMI.o MPQMUX.o 
KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
OUTPUTDIR=/lib/modules/`uname -r`/kernel/drivers/net/usb/

PI_KDIR := ~/k/linux-rpi-3.6.y
FILE = ${KDIR}/drivers/net/usb/usbnet.h
PI_CCPREFIX=~/toolchain/rpi/tools-master/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin/arm-bcm2708-linux-gnueabi- 
all:
        ifeq ($(FILE), $(wildcard $(FILE)))
	    cp ${KDIR}/drivers/net/usb/usbnet.h ./
        endif
	$(MAKE) -C $(KDIR) M=$(PWD) modules

pi: 
	$(MAKE) ARCH=arm CROSS_COMPILE=${PI_CCPREFIX} -C $(PI_KDIR) M=$(PWD) modules

install: all
	mkdir -p $(OUTPUTDIR)
	cp -f GobiNet.ko $(OUTPUTDIR)
	depmod

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions Module.* modules.order
