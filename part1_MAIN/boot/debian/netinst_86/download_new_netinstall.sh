#!/bin/bash

rm linux
rm initrd.gz

wget http://ftp.debian.org/debian/dists/stable/main/installer-i386/current/images/netboot/debian-installer/i386/linux
wget http://ftp.debian.org/debian/dists/stable/main/installer-i386/current/images/netboot/debian-installer/i386/initrd.gz

echo "Done!"
