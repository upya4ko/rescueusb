#!/bin/bash

SCRIPT_PATH=$(dirname "$0")

SUDO_PATH=$(whereis -b -f sudo | cut -d ' ' -f 2)
UNZIP_PATH=$(whereis -b -f unzip | cut -d ' ' -f 2)
DPKG_PATH=$(whereis -b -f dpkg | cut -d ' ' -f 2)
FDISK_PATH=$(whereis -b -f fdisk | cut -d ' ' -f 2)
WGET_PATH=$(whereis -b -f wget | cut -d ' ' -f 2)

# -------------------------------------------

echo ""
echo "Download and unpack Memtest86 for BIOS and UEFI"
echo ""
echo "Memetest path - $SCRIPT_PATH/memtest"
echo ""


read -n1 -r -p "Press Y to continue download or press any key to abort" key
echo ""

if [ "$key" = 'y' ] || [ "$key" = 'Y' ]
  then
    # Space pressed, do something
    # echo [$key] is empty when SPACE is pressed # uncomment to trace
    echo ""
    echo "Start download"
    echo ""
else
    # Anything else pressed, do whatever else.
    # echo [$key] not empty
    echo "Download aborted"
    exit 1
fi

#---------------------------------------------------

if [ ! -e $SUDO_PATH ] || [ ! -e $UNZIP_PATH ] || [ ! -e $DPKG_PATH ] || [ ! -e $FDISK_PATH ]
  then 
    echo "sudo - $SUDO_PATH"
    echo "unzip - $UNZIP_PATH"
    echo "dpkg - $DPKG_PATH"
    echo "fdisk - $FDISK_PATH"
    echo "wget - $WGET_PATH"
    echo ""
    echo "Some of used tools not installed, install it?"
    read -n1 -r -p "Press Y to install or press any key to abort" key

    if [ "$key" = 'y' ] || [ "$key" = 'Y' ]
      then
        echo ""
        if [ ! -e $SUDO_PATH ]
          then
            apt-get update
            apt-get install unzip sudo dpkg util-linux wget
          else
            sudo apt-get update
            sudo apt-get install unzip sudo dpkg util-linux wget
        fi
        echo ""
      else
        echo "Used tiils not installed, abort memtest download"
        exit 1
    fi
fi

#--------------------------------------------------------------

echo ""
echo "Create memtest directory"
mkdir -p $SCRIPT_PATH/memtest/{uefi,bios}
echo ""

# memtest for UEFI
echo "Create temp directory"
mkdir -p $SCRIPT_PATH/temp/img
echo ""
echo "Download Memtest86 for UEFI"
wget https://www.memtest86.com/downloads/memtest86-usb.zip -O $SCRIPT_PATH/temp/memtest86-usb.zip
echo ""
echo "Unpack Memtest86 for UEFI"
unzip $SCRIPT_PATH/temp/memtest86-usb.zip memtest86-usb.img -d $SCRIPT_PATH/temp/
echo ""
echo ""
echo "Mount Memtest86 for UEFI image"
START_SECTOR=$(sudo fdisk -lu $SCRIPT_PATH/temp/memtest86-usb.img | grep "memtest86-usb.img1" | cut -f4 -d' ')
SIZE_SECTOR=$(sudo fdisk -lu $SCRIPT_PATH/temp/memtest86-usb.img | grep "Sector size" | cut -f4 -d' ')
sudo mount -o loop,offset=$(($START_SECTOR * $SIZE_SECTOR)) $SCRIPT_PATH/temp/memtest86-usb.img $SCRIPT_PATH/temp/img
echo ""
echo "Copy Memtest86 for UEFI EFI files"
cp -v $SCRIPT_PATH/temp/img/EFI/BOOT/BOOTIA32.efi $SCRIPT_PATH/memtest/uefi/BOOTIA32.efi
cp -v $SCRIPT_PATH/temp/img/EFI/BOOT/BOOTX64.efi  $SCRIPT_PATH/memtest/uefi/BOOTX64.efi
cp -v $SCRIPT_PATH/temp/img/EFI/BOOT/blacklist.cfg $SCRIPT_PATH/memtest/uefi/blacklist.cfg
echo ""
echo "Unmount Memtest86 for UEFI image"
sudo umount $SCRIPT_PATH/temp/img

# memtest for BIOS
echo ""
echo "Download Memtest86 for BIOS"
sudo apt-get update
echo ""
sudo apt-get install --download-only memtest86+
echo ""
echo "Unpack Memtest86 for BIOS DEB packet"
MEMTEST_DEB=$(ls /var/cache/apt/archives/ | grep "memtest")
dpkg -x /var/cache/apt/archives/$MEMTEST_DEB $SCRIPT_PATH/temp/
echo ""
echo "Copy Memtest86 for BIOS BIN file"
cp -v $SCRIPT_PATH/temp/boot/memtest86+.bin $SCRIPT_PATH/memtest/bios/memtest86.bin
echo ""

echo "Delete temp directory"
rm -r $SCRIPT_PATH/temp/
echo ""

echo "Memtest86 files:"
find $SCRIPT_PATH/memtest/ -type f
echo ""
echo "Update GRUB2 config if need"
echo


exit 0
