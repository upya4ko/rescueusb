#!/bin/sh
#
# Debian Netinstall and LiveCD updater
#
# Upya4ko 2022-05-06
#

updatePath=$1
#mirrorUrl='https://cdimage.debian.org/debian-cd'
mirrorUrl='http://debian.volia.net/debian-cd'

#mirrorUrlFtp='http://ftp.debian.org/debian'
mirrorUrlFtp='http://debian.volia.net/debian'

repo32live=$mirrorUrl'/current-live/i386/iso-hybrid'
repo64live=$mirrorUrl'/current-live/amd64/iso-hybrid'
repo32bt=$mirrorUrl'/current-live/i386/bt-hybrid'
repo64bt=$mirrorUrl'/current-live/amd64/bt-hybrid'
repo32NetInst=$mirrorUrlFtp'/dists/stable/main/installer-i386/current/images/netboot/debian-installer/i386'
repo64NetInst=$mirrorUrlFtp'/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64'

if [ -z $updatePath ]; then
  echo "Usage: $(basename $0) /path/to/storage"
  exit 1
fi

# Create target dir
mkdir -p $updatePath

# Change workdir to target dir
cd $updatePath

# Get new distro names and versions
currentVer=$(cat ${updatePath}/ver.info)
newVer=$(wget -nv -q -O - $repo64live | grep "amd64-xfce.iso" | sed 's/^.*\(debian-live.*iso\).*$/\1/' | cut -f3 -d-)

echo -e "\nUpdate Debian live and netinstall\n"

# Is no normal way to compare strings in sh
# https://stackoverflow.com/questions/454427/string-difference-in-bash/454579
diff  <(echo "$currentVer" ) <(echo "$newVer")
diffExitCode=$?

if [ $diffExitCode -eq 0 ]; then
  echo "You have latest debian release $currentVer"
  echo -e "Update not needed\n"
  exit 0
else
  echo "New Debian version available"
  echo "Current - $currentVer"
  echo -e "New     - $newVer"
  echo -e "Dist path - $updatePath\n"
fi

echo -e "\nStart update\n"

echo "Remove old images"
rm -v ${updatePath}/debian-live-i386-xfce.iso
rm -v ${updatePath}/debian-live-amd64-xfce.iso
echo -e "Done remove old images\n"

echo -e "Download new x86 image\n"
wget ${repo32bt}/debian-live-${newVer}-i386-xfce.iso.torrent -O ${updatePath}/debian-live-${newVer}-i386-xfce.iso.torrent
echo -e "\nStart torrent download\n"
aria2c --file-allocation=none --seed-time=0 ${updatePath}/debian-live-${newVer}-i386-xfce.iso.torrent -d $updatePath
rm -v ${updatePath}/debian-live-${newVer}-i386-xfce.iso.torrent
mv ${updatePath}/debian-live-${newVer}-i386-xfce.iso ${updatePath}/debian-live-i386-xfce.iso

echo -e "Download new x64 image\n"
wget ${repo64bt}/debian-live-${newVer}-amd64-xfce.iso.torrent -O ${updatePath}/debian-live-${newVer}-amd64-xfce.iso.torrent
echo -e "\nStart torrent download\n"
aria2c --file-allocation=none --seed-time=0 ${updatePath}/debian-live-${newVer}-amd64-xfce.iso.torrent -d $updatePath
rm ${updatePath}/debian-live-${newVer}-amd64-xfce.iso.torrent
mv ${updatePath}/debian-live-${newVer}-amd64-xfce.iso ${updatePath}/debian-live-amd64-xfce.iso

# Not used HTTP download
# wget https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/$NEW_LIVE_32 -O $SCRIPT_PATH/$NEW_LIVE_32
#wget https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/$NEW_LIVE_64 -O $SCRIPT_PATH/$NEW_LIVE_64
echo -e "\nDone download new images\n"

echo "Remove old netinstall"
rm -rv $updatePath/netinst_86
rm -rv $updatePath/netinst_64
mkdir $updatePath/netinst_86
mkdir $updatePath/netinst_64
echo -e "Done remove old netinstall\n"

echo -e "Download new netinstall\n"
wget $repo32NetInst/linux -O $updatePath/netinst_86/linux
echo ""
wget $repo32NetInst/initrd.gz -O $updatePath/netinst_86/initrd.gz
echo ""
wget $repo64NetInst/linux -O $updatePath/netinst_64/linux
echo ""
wget $repo64NetInst/initrd.gz -O $updatePath/netinst_64/initrd.gz
echo -e "Done download new netinstall\n"

# Save new version
echo $newVer > $updatePath/ver.info

exit 0

