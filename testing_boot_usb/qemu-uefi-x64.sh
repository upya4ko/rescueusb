#!/bin/sh

CORES=1
RAM=2048
DUMMY_DRIVE=test1.qcow
USB_DRIVE=$1
BIOS=/usr/share/ovmf/OVMF.fd

if [ $# -lt 1 ];then
  echo "ERROR Usage:"
  echo "$(basename $0) /dev/sdX"
  exit 1
fi

sudo qemu-system-x86_64 \
     -m $RAM \
     -usb $USB_DRIVE \
     -hdb $DUMMY_DRIVE \
     -cpu kvm64 \
     -smp cores=$CORES \
     -bios $BIOS
     #     -enable-kvm
