#!/bin/bash

SCRIPT_PATH=$(dirname "$0")
CURRENT_MINT_32=$(ls $SCRIPT_PATH/ | grep "xfce-32bit")
CURRENT_MINT_64=$(ls $SCRIPT_PATH/ | grep "xfce-64bit")
NEW_MINT_32=$(wget -nv -q -O - https://torrents.linuxmint.com | grep xfce-32 | tail -n 1 | sed 's/^.*\(linuxmint.*iso\).*$/\1/')

NEW_MINT_64=$(wget -nv -q -O - https://torrents.linuxmint.com | grep xfce-64bit | tail -n 1 | sed 's/^.*\(linuxmint.*iso\).*$/\1/')

NEW_MINT_VER=$(wget -nv -q -O - https://torrents.linuxmint.com | grep xfce-32 | tail -n 1 | sed 's/^.*\(linuxmint.*iso.torrent\).*$/\1/' | cut -f2 -d-)

CUR_MINT_VER=$(ls $SCRIPT_PATH/ | grep "xfce-32bit.iso" | cut -f2 -d-)

ARIA_VER=$(aria2c --version | head -n 1)
ARIA_PATH=$(whereis -b -f aria2c | cut -d ' ' -f 2)

# -------------------------------------------

echo ""
echo "Update Mint images"
echo ""
echo "Dist path - $SCRIPT_PATH"
echo "$ARIA_VER"
echo "Current Mint X32 - $CURRENT_MINT_32"
echo "Current Mint X64 - $CURRENT_MINT_64"
echo "New Mint X32 - $NEW_MINT_32"
echo "New Mint X64 - $NEW_MINT_64"
echo ""


if [ "$CURRENT_MINT_32" == "$NEW_MINT_32" ] || [ "$CURRENT_MINT_64" == "$NEW_MINT_64" ]
  then
    echo "You have latest Mint release"
    echo "Update not needed"
    exit 0
  else 
    echo "New Mint version available"
    echo "Current - $CUR_MINT_VER"
    echo "New     - $NEW_MINT_VER"
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
rm $SCRIPT_PATH/$CURRENT_MINT_32
rm $SCRIPT_PATH/$CURRENT_MINT_64
echo "Done remove old images"
echo ""

echo "Download new images"
echo ""
wget https://torrents.linuxmint.com/torrents/$NEW_MINT_32".torrent" -O $SCRIPT_PATH/$NEW_MINT_32".torrent"
echo ""
aria2c --seed-time=0 $SCRIPT_PATH/$NEW_MINT_32".torrent" -d $SCRIPT_PATH
rm $SCRIPT_PATH/$NEW_MINT_32".torrent"

echo ""

wget https://torrents.linuxmint.com/torrents/$NEW_MINT_64".torrent" -O $SCRIPT_PATH/$NEW_MINT_64".torrent"
echo ""
aria2c --seed-time=0 $SCRIPT_PATH/$NEW_MINT_64".torrent" -d $SCRIPT_PATH
rm $SCRIPT_PATH/$NEW_MINT_64".torrent"

echo ""

echo "Done download new images"
echo ""

echo "New images downloaded, update GRUB config!"

exit 0
