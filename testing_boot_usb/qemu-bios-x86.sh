#!/bin/sh

CORES=1
RAM=2048
DUMMY_DRIVE=test1.qcow
USB_DRIVE=$1

if [ $# -lt 1 ];then
  echo "ERROR Usage:"
  echo "$(basename $0) /dev/sdX"
  exit 1
fi

sudo qemu-system-i386 \
     -m $RAM \
     -usb $USB_DRIVE \
     -hdb $DUMMY_DRIVE \
     -cpu 486 \
     -smp cores=$CORES 
#     -enable-kvm
