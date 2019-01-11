#WORK IN PROGRESSSSSS

# Universal Rescue USB drive

I searching for recovery USB drive for long time, but all finded solutions not fully cover my needs.
I Decide make my ideal universal USB drive by miself.

In this repo i share my configs for GRUB2 and GRUB4DOS + instructions how format and test USB drive.

Moust hard for me be find right parameters to run all needed for me tools.

This USB drive can:
* Boot on BIOS and UEFI
* Diagnose HW problems
* Install Linux (debian, mint)
* Install Windows (XP, 7, 10)
* Backup / Restore
* Pen-testing (Kali linux)
* Repair bootloader 
* Repair partition table
* Flash BIOS
* And more

******************************************


Prerere PC
```
sudo apt-get update
sudo apt-get install parted vim wget p7zip-full unzip ntfs-3g dosfstools grub grub-efi-amd64-bin grub-imageboot
```

For start prepeare USB drive:

Insert USB drive, and check what name it take
```
sudo dmesg
```

```
[2949128.264602] usb-storage 3-4:1.0: USB Mass Storage device detected
[2949129.487527] sd 6:0:0:0: [sdb] 7909376 512-byte logical blocks: (4.05 GB/3.77 GiB)
[2949129.499389] sd 6:0:0:0: [sdb] Attached SCSI removable disk
```

next steps be use **/dev/sdb** as USB drive

Next step clear partition table:
```
sudo dd if=/dev/zero of=/dev/sdb bs=1M count=10
```

Create MBR partition table (Not all PC wort with GPT):
```
sudo parted /dev/sdb mktable msdos
```

Main problem in UEFI it can use only fat32 (some rare PC can see NTFS) so need 2 partitions, main and UEFI (3-5MB) to boot GRUB on EFI mode.

Get USB drive size:
```
sudo parted /dev/sdb p
```
```
Model: JetFlash Transcend 4GB (scsi)
Disk /dev/sdb: 4050MB
```

so start of second partition be 4045MB


Create main partition:
```
sudo parted /dev/sdb mkpart primary ntfs 0% 4045MB
```

Create small partition for UEFI boot :
```
sudo parted /dev/sdb mkpart primary fat32 4045MB 100%
```

Make main partition bootable:
```
sudo parted /dev/sdb set 1 boot on
```

Final resolt:
```
Model: JetFlash Transcend 4GB (scsi)
Disk /dev/sdb: 4050MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  4045MB  4044MB  primary               boot
 2      4045MB  4050MB  4194kB  primary               lba

```

Format partitions:
```
sudo mkfs.ntfs -L RESCUEUSB  /dev/sdb1
```

```
sudo mkfs.msdos -n UEFI /dev/sdb2
```


Mount partitions:
```
sudo mkdir /mnt/rescueusb
sudo mount /dev/sdb1 /mnt/rescueusb
sudo mkdir /mnt/uefi
sudo mount /dev/sdb2 /mnt/uefi
```

Install GRUB2
```
sudo grub-install --target=i386-pc --boot-directory="/mnt/rescueusb/boot" /dev/sdb
sudo cp -r /usr/lib/grub/x86_64-efi /mnt/rescueusb/boot/grub
```

Add file from ubuntu uefi boot
```
vim /mnt/rescueusb/boot/grub/x86_64-efi/grub.cfg
```
```
insmod part_acorn
insmod part_amiga
insmod part_apple
insmod part_bsd
insmod part_dfly
insmod part_dvh
insmod part_gpt
insmod part_msdos
insmod part_plan
insmod part_sun
insmod part_sunpc
source /boot/grub/grub.cfg
```

Make dirs for tools
```
cd /mnt/rescueusb/boot/
mkdir acronis debian mint winpe rescuecd kali
cd -
```

Download [GRUB4DOS](https://sourceforge.net/projects/grub4dos/)
```
unzip grub4dos-0.4.4.zip
cp grub4dos-0.4.4/grub.exe /mnt/rescueusb/boot/
```

Copy memdisk
```
cp /boot/memdisk /mnt/rescueusb/boot/
```

Get defragfs tool to defrag ISO images for use in grub4dos
```
wget https://raw.githubusercontent.com/ThomasCX/defragfs/master/defragfs -O /mnt/rescueusb/boot/defragfs
```

Download grub configs
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/chntpw.lst -O /mnt/rescueusb/boot/chntpw.lst
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/winpe.lst -O /mnt/rescueusb/boot/winpe.lst
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/grub/grub.cfg -O /mnt/rescueusb/boot/grub/grub.cfg
```


------------------------------------------------------------------------------------------------------

Download Debian installers and Live image
```
cd /mnt/rescueusb/boot/debian/
wget https://cdimage.debian.org/debian-cd/9.6.0-live/i386/iso-hybrid/debian-live-9.6.0-i386-xfce.iso
wget https://cdimage.debian.org/debian-cd/9.6.0-live/amd64/iso-hybrid/debian-live-9.6.0-amd64-xfce.iso
mkdir netinst_64 netinst_86
cd netinst_64 
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/debian/netinst_64/download_new_netinstall.sh 
bash ./download_new_netinstall.sh  
cd ../netinst_86
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/debian/netinst_86/download_new_netinstall.sh
bash ./download_new_netinstall.sh
```

Download Linux Mint
```
cd /mnt/rescueusb/boot/mint/
wget http://mirrors.evowise.com/linuxmint/stable/19.1/linuxmint-19.1-xfce-32bit.iso
wget https://mirrors.layeronline.com/linuxmint/stable/19.1/linuxmint-19.1-xfce-64bit.iso
```

Download Kali Linux
```
cd /mnt/rescueusb/boot/kali/
wget https://cdimage.kali.org/kali-2018.1/kali-linux-2018.1-i386.iso
```

Download usefull tools to put in `/mnt/rescueusb/boot/rescuecd/`

[Dos image to upgrade BIOS](https://www.allbootdisks.com/download/dos.html)
[Chntpw also known as Offline NT Password & Registry Editor](https://www.techspot.com/downloads/6967-chntpw.html)
[Clonezilla to backup linux PC](https://clonezilla.org/downloads/download.php?branch=stable)
[HDD Regenerator](https://duckduckgo.com/?q=HDD+regenerator+img&t=h_&ia=web)
[Hiren's BootCD 15.2 DOS](https://duckduckgo.com/)
[Memtest 5.01](https://mirrors.slackware.com/slackware/slackware-14.2/kernels/memtest/memtest.mirrorlist)
[MHDD DOS](http://www.mhdd.ru/files/mhdd32ver4.6iso.zip)
```
wget http://www.mhdd.ru/files/mhdd32ver4.6iso.zip
7z e mhdd32ver4.6floppy.exe
cp mhdd32ver4.6floppy /mnt/rescueusb/boot/rescuecd/mhdd32ver4.6_Boot-1.44M.img
```
[Norton Ghost 11 ima](https://duckduckgo.com/?q=nortonghost11.ima&t=h_&ia=web)
[Rescatux](https://www.supergrubdisk.org/category/download/rescatuxdownloads/rescatux-beta/)
[WHDD](https://www.richud.com/wiki/WHDD_Live_ISO_Boot_CD)


--------------------------------------------------------------------------------------------















BIOS
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdc -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm


EFI
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdc -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm -bios bios.bin



