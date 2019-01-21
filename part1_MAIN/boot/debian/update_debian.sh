#!/bin/bash

SCRIPT_PATH=$(dirname "$0")
CURRENT_LIVE_32=$(ls $SCRIPT_PATH/ | grep "i386-xfce.iso")
CURRENT_LIVE_64=$(ls $SCRIPT_PATH/ | grep "amd64-xfce.iso")
NEW_LIVE_32=$(wget -nv -q -O - https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/ | grep "i386-xfce.iso" | sed 's/^.*\(debian-live.*iso\).*$/\1/')

NEW_LIVE_64=$(wget -nv -q -O - https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/ | grep "amd64-xfce.iso" | sed 's/^.*\(debian-live.*iso\).*$/\1/')

NEW_DEBIAN_VER=$(wget -nv -q -O - https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/ | grep "amd64-xfce.iso" | sed 's/^.*\(debian-live.*iso\).*$/\1/' | cut -c 13-17)

CUR_DEBIAN_VER=$(ls $SCRIPT_PATH/ | grep "amd64-xfce.iso" | cut -c 13-17)

ARIA_VER=$(aria2c --version | head -n 1)
ARIA_PATH=$(whereis -b -f aria2c | cut -d ' ' -f 2)

# -------------------------------------------

echo ""
echo "Update Debian live and netinstall"
echo ""
echo "Dist path - $SCRIPT_PATH"
echo "$ARIA_VER"
echo "Current live X32 - $CURRENT_LIVE_32"
echo "Current live X64 - $CURRENT_LIVE_64"
echo "New live X32 - $NEW_LIVE_32"
echo "New live X64 - $NEW_LIVE_64"
echo ""


if [ "$CURRENT_LIVE_32" == "$NEW_LIVE_32" ] || [ "$CURRENT_LIVE_64" == "$NEW_LIVE_64" ]
  then
    echo "You have latest debian release"
    echo "Update not heeded"
    exit 0
  else 
    echo "New Debian version available"
    echo "Current - $CUR_DEBIAN_VER"
    echo "New     - $NEW_DEBIAN_VER"
    echo ""
fi

read -n1 -r -p "Press Y to continue update or press any key to abort" key
echo ""

if [ "$key" = 'y' ] || [ "$key" = 'Y' ]
  then
    # Space pressed, do something
    # echo [$key] is empty when SPACE is pressed # uncomment to trace
    echo ""
    echo "Start update"
    echo ""
else
    # Anything else pressed, do whatever else.
    # echo [$key] not empty
    echo "Update aborted"
    exit 1
fi

#---------------------------------------------------

if [ ! -e $ARIA_PATH ]
  then 
    echo "Aria2 Not installed, install it?"
    read -n1 -r -p "Press Y to install Aria2  or press any key to abort" key

    if [ "$key" = 'y' ] || [ "$key" = 'Y' ]
      then
        sudo apt-get update
        sudo apt-get install aria2
      else
        echo "Aria2 not installed, abort Debian live update"
        exit 1
    fi
fi

#--------------------------------------------------------------

echo "Remove old images"
rm $SCRIPT_PATH/$CURRENT_LIVE_32
rm $SCRIPT_PATH/$CURRENT_LIVE_64
echo "Done remove old images"
echo ""

echo "Download new images"
echo ""
wget https://cdimage.debian.org/debian-cd/current-live/i386/bt-hybrid/$NEW_LIVE_32".torrent" -O $SCRIPT_PATH/$NEW_LIVE_32".torrent"
echo ""
aria2c --seed-time=0 $SCRIPT_PATH/$NEW_LIVE_32".torrent" -d $SCRIPT_PATH
rm $SCRIPT_PATH/$NEW_LIVE_32".torrent"

echo ""

wget https://cdimage.debian.org/debian-cd/current-live/amd64/bt-hybrid/$NEW_LIVE_64".torrent" -O $SCRIPT_PATH/$NEW_LIVE_64".torrent"
echo ""
aria2c --seed-time=0 $SCRIPT_PATH/$NEW_LIVE_64".torrent" -d $SCRIPT_PATH
rm $SCRIPT_PATH/$NEW_LIVE_64".torrent"

# Not used HTTP download
# wget https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/$NEW_LIVE_32 -O $SCRIPT_PATH/$NEW_LIVE_32
echo ""
#wget https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/$NEW_LIVE_64 -O $SCRIPT_PATH/$NEW_LIVE_64
echo "Done download new images"
echo ""

echo "Remove old netinstall"
rm -r $SCRIPT_PATH/netinst_86
rm -r $SCRIPT_PATH/netinst_64
mkdir $SCRIPT_PATH/netinst_86
mkdir $SCRIPT_PATH/netinst_64
echo "Done remove old netinstall"
echo ""

echo "Download new netinstall"
echo ""
wget http://ftp.debian.org/debian/dists/stable/main/installer-i386/current/images/netboot/debian-installer/i386/linux -O $SCRIPT_PATH/netinst_86/linux
echo ""
wget http://ftp.debian.org/debian/dists/stable/main/installer-i386/current/images/netboot/debian-installer/i386/initrd.gz -O $SCRIPT_PATH/netinst_86/initrd.gz
echo ""
wget http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux -O $SCRIPT_PATH/netinst_64/linux
echo ""
wget http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz -O $SCRIPT_PATH/netinst_64/initrd.gz
echo "Done download new netinstall"
echo ""

echo "New images downloaded, update GRUB config!"

exit 0
