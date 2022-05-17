#!/bin/sh

installPath=$1
memtest86url='https://www.memtest86.com/downloads/memtest86-usb.zip'


if [ $# -lt 1 ]; then
  echo -e "Error! Usage:\n $(basename $0) /install/path"
  exit 1
fi

# Check if memtest already installed
uefiBinFile=$installPath/uefi/BOOTX64.efi
biosBinFile=$installPath/bios/memtest86.bin

createDirs() {
  echo "Download and unpack Memtest86 for BIOS and UEFI"
  echo -e "\nMemetest path - $installPath\n"
  echo "Create memtest directory"
  mkdir -p $installPath/uefi $installPath/bios
}

installMemtestUefi() {
  # memtest for UEFI
  echo -e "\nCreate temp directory"
  mkdir -p $installPath/temp/img
  echo -e "\nDownload Memtest86 for UEFI"
  wget $memtest86url -O $installPath/temp/memtest86-usb.zip
  echo -e "\nUnpack Memtest86 for UEFI"
  unzip $installPath/temp/memtest86-usb.zip memtest86-usb.img -d $installPath/temp/
  echo -e "\n\nMount Memtest86 for UEFI image"
  START_SECTOR=$(fdisk -lu $installPath/temp/memtest86-usb.img | grep "MemTest86" | awk '{print $2}')
  SIZE_SECTOR=$(fdisk -lu $installPath/temp/memtest86-usb.img | grep "Logical sector size:" | awk '{print $4}')
  mount -o loop,offset=$(($START_SECTOR * $SIZE_SECTOR)) $installPath/temp/memtest86-usb.img $installPath/temp/img
  echo -e "\nCopy Memtest86 for UEFI EFI files"
  cp -v $installPath/temp/img/EFI/BOOT/BOOTX64.efi  $installPath/uefi/BOOTX64.efi
#  cp -v $installPath/temp/img/EFI/BOOT/blacklist.cfg $installPath/uefi/blacklist.cfg
  echo -e "\nUnmount Memtest86 for UEFI image"
  umount $installPath/temp/img
}

installMemtestBios() {
  # memtest for BIOS
  echo "Copy Memtest86 for BIOS BIN file"
  cp -v /sourceDir/memtest86+.bin $installPath/bios/memtest86.bin
}


cleanUp() {
  echo -e "\nDelete temp directory"
  rm -rv $installPath/temp/
}

report() {
  echo -e "\nMemtest86 files:"
  find $installPath/ -type f
}

# ---

createDirs

if [ ! -f $uefiBinFile ] ; then
  installMemtestUefi
  cleanUp
else
  echo -e "\nMemtest86 UEFI Already installed\n"
fi

if [ ! -f $biosBinFile ] ; then
  installMemtestBios
else
  echo -e "\nMemtest86 BIOS Already installed\n"
fi

report

exit 0

