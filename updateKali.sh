#!/bin/bash
#
# Kali Linux LiveCD updater
#
# Upya4ko 2022-05-07
#

updatePath=$1
kaliUrlBase='https://kali.download/base-images'

# Get new distro names and versions
currentVer=$(cat ${updatePath}/ver.info)
newVer=$(wget -nv -q -O - "$kaliUrlBase/current" | grep "live-amd64.iso<" | egrep -o "kali-linux-[.0-9]*-live-amd64.iso" - | tail -n 1 | egrep -o "[0-9]{4}\.[0-9]*" -)

kaliVer=$newVer
kaliArch='amd64' #i386
kaliUrl=$kaliUrlBase'/kali-'$kaliVer'/kali-linux-'$kaliVer'-live-'$kaliArch'.iso.torrent'


if [ -z $updatePath ]; then
  echo "Usage: $(basename $0) /path/to/storage"
  exit 1
fi

# Create target dir
mkdir -p $updatePath

# Change workdir to target dir
cd $updatePath

echo -e "\nUpdate Kali Linux live\n"

# Is no normal way to compare strings in sh
# https://stackoverflow.com/questions/454427/string-difference-in-bash/454579
diff  <(echo "$currentVer" ) <(echo "$newVer")
diffExitCode=$?

if [ $diffExitCode -eq 0 ]; then
  echo "You have latest kali release $currentVer"
  echo -e "Update not needed\n"
  exit 0
else
  echo "New Kali version available"
  echo "Current - $currentVer"
  echo -e "New     - $newVer"
  echo -e "Dist path - $updatePath\n"
fi

echo -e "\nStart update\n"

echo "Remove old images"
rm -v ${updatePath}/kali-live-amd64.iso
echo -e "Done remove old images\n"

echo -e "Download new x64 image\n"
wget ${kaliUrl} -O ${updatePath}/kali-live-amd64.iso.torrent
echo -e "\nStart torrent download\n"
aria2c --file-allocation=none --seed-time=0 ${updatePath}/kali-live-amd64.iso.torrent -d $updatePath
rm ${updatePath}/kali-live-amd64.iso.torrent
mv ${updatePath}/kali-linux-${newVer}-live-amd64.iso ${updatePath}/kali-live-amd64.iso

echo -e "\nDone download new images\n"

# Save new version
echo $newVer > $updatePath/ver.info

exit 0

