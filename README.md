# WORK IN PROGRESSSSSS

# Universal Rescue USB drive

I searching for recovery USB drive for long time, but all find solutions not fully cover my needs, so i decide make my ideal universal USB drive by myself.

In this repo i share my configs for GRUB2 and GRUB4DOS + instructions how format and test USB drive.

## This USB drive can:
* Boot on BIOS and UEFI
* Diagnose HW problems
* Install Linux (debian, mint)
* Install Windows (XP, 7, 8.1, 10)
* Backup / Restore
* Pen-testing (Kali linux)
* Repair bootloader 
* Repair partition table
* Flash BIOS
* And more

------------------------------------------------------------------------------------------

## Items:
1. [Prepare](#prepare)
   - [Get closest debian mirror](#get-closest-debian-mirror)
   - [Create chroot](#create-chroot)
      - [Prepare chroot](#prepare-chroot)
   - [Prepare USB drive](#prepare-usb-drive)
      - [Clear partition table](#clear-partition-table)
      - [Create MBR partition table](#create-mbr-partition-table)
      - [Get USB drive size](#get-usb-drive-size)
      - [Create main partition](#create-main-partition)
      - [Create small partition for UEFI boot](#create-small-partition-for-uefi-boot)
      - [Make main partition bootable](#make-main-partition-bootable)
      - [Final result](#final-result)
      - [Format partitions](#format-partitions)
      - [Mount partitions](#mount-partitions)
   - [Install GRUB](#install-grub)
      - [Install GRUB2 for BIOS boot](#install-grub2-for-bios-boot)
      - [Add file from Ubuntu CD UEFI boot](#add-file-from-ubuntu-cd-uefi-boot)
      - [Download GRUB4DOS](#download-grub4dos)
      - [Copy memdisk](#copy-memdisk)
      - [Download GRUB configs](#download-grub-configs)
      - [Install GRUB2 for UEFI boot](#install-grub2-for-uefi-boot)
      - [Copy GRUB2 UEFI config](#copy-grub2-uefi-config)
      - [Create UEFI loader](#create-uefi-loader)
1. [Download tools and distros](#download-tools-and-distros)
   - [Make dirs for tools](#make-dirs-for-tools)
   - [Get defragfs tool to defrag ISO images for use in grub4dos](#get-defragfs-tool-to-defrag-iso-images-for-use-in-grub4dos)
   - [Download Debian installers and Live images](#download-debian-installers-and-live-images)
   - [Download Linux Mint](#download-linux-mint)
   - [Download Kali Linux](#download-kali-linux)
   - [Download Memtest86 for UEFI and BIOS](#download-memtest86-for-uefi-and-bios)
1. [Finish](#finish)
   - [Unmount done USB drive](#unmount-done-usb-drive)
   - [Exit chroot](#exit-chroot)
1. [More usefull tools](#more-usefull-tools)
   - [Dos image to upgrade BIOS](#dos-image-to-upgrade-bios)   
   - [Chntpw also known as Offline NT Password and Registry Editor](#chntpw-also-known-as-offline-nt-password-and-registry-editor)   
   - [Clonezilla to backup linux PC](#clonezilla-to-backup-linux-pc)   
   - [HDD Regenerator](#hdd-regenerator)   
   - [Hiren's BootCD 15.2 DOS](#hirens-bootcd-15.2-dos)   
   - [MHDD DOS](#mhdd-dos)   
   - [Norton Ghost 11 ima](#norton-ghost-11-ima)   
   - [Rescatux](#rescatux)   
   - [WHDD](#whdd)   
1. [Testing](#testing)
   - [Install QEMU](#install-qemu)
   - [Create dummy drive image](#create-dummy-drive-image)
   - [QEMU Options](#options)
   - [To test in BIOS mode](#to-test-in-bios-mode)
   - [To test in UEFI mode](#to-test-in-uefi-mode)

----------------------------------------------------------------------------------------

## Prepare:
Installation be inside chroot, it safe and easy to clean after install.

### [*Get closest debian mirror*](https://www.debian.org/mirror/list)

### Create chroot:
```
sudo apt-get update
sudo apt-get install debootstrap
mkdir usb_install
sudo debootstrap stable usb_install http://debian.volia.net/debian/
sudo mount --bind /dev usb_install/dev
sudo mount --bind /proc usb_install/proc
sudo chroot usb_install
```

#### Prepare chroot:
```
apt-get update
apt-get install parted wget p7zip-full unzip ntfs-3g dosfstools grub-pc grub-efi-amd64-bin grub-efi-ia32-bin grub-imageboot grep aria2 ca-certificates gzip sudo
```

#### Prepare USB drive:
*Insert USB drive, and check what name it take*
```
dmesg
```
```
[2949128.264602] usb-storage 3-4:1.0: USB Mass Storage device detected
[2949129.487527] sd 6:0:0:0: [sdb] 7909376 512-byte logical blocks: (4.05 GB/3.77 GiB)
[2949129.499389] sd 6:0:0:0: [sdb] Attached SCSI removable disk
```

Next steps be use **/dev/sdb** as USB drive

#### Clear partition table:
```
dd if=/dev/zero of=/dev/sdb bs=1M count=10
```

#### Create MBR partition table:
*Not all PC work with GPT*
```
parted /dev/sdb mktable msdos
```

Main problem in UEFI it can use only fat32 (some rare PC can see NTFS) so need 2 partitions, main and UEFI (3-5 MB) to boot GRUB on EFI mode.

#### Get USB drive size:
```
parted /dev/sdb unit MB p
```
```
Model: JetFlash Transcend 4GB (scsi)
Disk /dev/sdb: 4050MB
```

In my case start of second partition be **4045MB** *(4050 - 5 = 4045 MB)*

#### Create main partition:
```
parted /dev/sdb mkpart primary ntfs 0% 4045MB
```

#### Create small partition for UEFI boot:
```
parted /dev/sdb mkpart primary fat32 4045MB 100%
```

#### Make main partition bootable:
```
parted /dev/sdb set 1 boot on
```

#### Final result:
```
Model: JetFlash Transcend 4GB (scsi)
Disk /dev/sdb: 4050MB
Partition Table: msdos

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  4045MB  4044MB  primary               boot
 2      4045MB  4050MB  4194kB  primary               lba

```

#### Format partitions:
```
mkfs.ntfs -L RESCUEUSB  /dev/sdb1
mkfs.msdos -n UEFI /dev/sdb2
```

#### Mount partitions:
```
mkdir /mnt/rescueusb
mount /dev/sdb1 /mnt/rescueusb
mkdir /mnt/uefi
mount /dev/sdb2 /mnt/uefi
```

------------------------------------------------------------------------------------

### Install GRUB:

#### Install GRUB2 for BIOS boot:
```
grub-install --target=i386-pc --boot-directory="/mnt/rescueusb/boot" /dev/sdb
##########  cp -r /usr/lib/grub/x86_64-efi /mnt/rescueusb/boot/grub
```

##### Add file from Ubuntu CD UEFI boot:
```
########### nano /mnt/rescueusb/boot/grub/x86_64-efi/grub.cfg
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

##### [Download GRUB4DOS](https://sourceforge.net/projects/grub4dos/) 
And copy it to chroot
```
unzip grub4dos-0.4.4.zip
cp grub4dos-0.4.4/grub.exe /mnt/rescueusb/boot/
```

##### Copy memdisk:
*Memdisk needed to boot floppy images*
```
cp /boot/memdisk /mnt/rescueusb/boot/
```

##### Download GRUB configs:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/chntpw.lst -O /mnt/rescueusb/boot/chntpw.lst
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/winpe.lst -O /mnt/rescueusb/boot/winpe.lst
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/grub/grub.cfg -O /mnt/rescueusb/boot/grub/grub.cfg
```

-----------------------------------------------------------------------------------------
#### Install GRUB2 for UEFI boot:

##### Copy GRUB2 UEFI config:
```
mkdir -p /mnt/uefi/boot/grub/
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part2_UEFI/boot/grub/grub.cfg -O /mnt/uefi/boot/grub/grub.cfg
```

##### Create UEFI loader:
```
mkdir -p /mnt/uefi/EFI/BOOT/
GRUB_MODULES="fat iso9660 part_gpt part_msdos ntfs ext2 exfat btrfs hfsplus udf font gettext gzio normal boot linux linux16 configfile loopback chain efifwsetup efi_gop efi_uga ls help echo elf search search_label search_fs_uuid search_fs_file test all_video loadenv gfxterm gfxterm_background gfxterm_menu msdospart multiboot"
grub-mkimage -o /mnt/uefi/EFI/BOOT/bootx64.efi -p /boot/grub -O x86_64-efi $GRUB_MODULES
grub-mkimage -o /mnt/uefi/EFI/BOOT/bootia32.efi -p /boot/grub -O i386-efi $GRUB_MODULES 
```

*NOT USED*    
Some UEFI only systems (UEFI Bay Trail) locked to 32-bit efi loaders, to boot on this systems need patched bootia32.efi
```
cp /mnt/uefi/EFI/BOOT/BOOTIA32.EFI /mnt/uefi/EFI/BOOT/64_bit_only_____BOOTIA32.EFI
wget https://github.com/hirotakaster/baytail-bootia32.efi/blob/master/bootia32.efi?raw=true -O /mnt/uefi/EFI/BOOT/32_bit_only_____BOOTIA32.EFI 
cp /mnt/uefi/EFI/BOOT/32_bit_only_____BOOTIA32.EFI cp /mnt/uefi/EFI/BOOT/BOOTIA32.EFI
```

-----------------------------------------------------------------------------------------

## Download tools and distros:

### Make dirs for tools:
```
mkdir /mnt/rescueusb/boot/{acronis,debian,mint,winpe,rescuecd,kali,memtest,chntpw}
```

### Get defragfs tool to defrag ISO images for use in grub4dos:
```
wget https://raw.githubusercontent.com/ThomasCX/defragfs/master/defragfs -O /mnt/rescueusb/boot/defragfs
```

### Download Debian installers and Live images:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/debian/update_debian.sh -O /mnt/rescueusb/boot/debian/update_debian.sh
bash /mnt/rescueusb/boot/debian/update_debian.sh
```

### Download Linux Mint:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/mint/update_mint.sh -O /mnt/rescueusb/boot/mint/update_mint.sh
bash /mnt/rescueusb/boot/mint/update_mint.sh
```

### Download Kali Linux:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/kali/update_kali.sh -O /mnt/rescueusb/boot/kali/update_kali.sh
bash /mnt/rescueusb/boot/kali/update_kali.sh
```

### Download Memtest86 for UEFI and BIOS:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/memtest_download.sh -O /mnt/rescueusb/boot/memtest/download_memtest.sh
bash /mnt/rescueusb/boot/memtest/download_memtest.sh
```

------------------------------------------------------------------------------------------

# Finish

## Unmount done USB drive:
```
umount /mnt/rescueusb/
umount /mnt/uefi/
```

## Exit chroot:
```
exit
sudo umount usb_install/dev
sudo umount usb_install/proc
```

-------------------------------------------------------------------------------------------

## More usefull tools:
*Images put in* `/mnt/rescueusb/boot/rescuecd/`

### Dos image to upgrade BIOS
Modified floppy image from site [zheleznov.info](http://web.archive.org/web/20160418222032/http://zheleznov.info/boot_dos.htm)   

* Why need floppy with DOS:
   - Install Windows 2000
   - Flashing motherboard BIOS
   - Run DOS programs to work with low level utilities (TestDisk, MHDD, Partition Magic, Acronis Disk Director)
   - RAM testing "MemTest86+"
* Image contains:
   - Image based on "Windows 98 SE boot disk"
   - Added drivers and utilities:
      - Driver IDE CD-ROM: ECSCDIDE
      - Driver SATA CD-ROM: GCDROM V2.4
      - Driver SATA CD-ROM: XGCDROM V2.4b
      - RAM testing "MemTest86+ 1.65"
      - Russian keyboard driver "KEYRUS"
      - Mouse driver MOUSE.COM
      - Diver disk caching "SMARTDRV.EXE", need to install Windows 2000
      - File manager "Volkov Commander", run with command VC
* Other improvements:
   - Remove unused files.
   - Remove unpacking utilities to RAM-disk, all utilities fit in to floppy unpacked.
   - Original utilities moved to directory DOS.
   - Additional drivers and utilities moved to directory UTILS.
   - Directories added to environment variable PATH, so all utilities can be called from any catalog.
   - Removed boot variant without CD-ROM support.
   - Rework config files and boot menu.

```
wget http://web.archive.org/web/20160418222032/http://zheleznov.info/file/boot_dos.zip
unzip boot_dos.zip
mv boot_dos/boot_dos.ima .
rm -r boot_dos/
```

### Chntpw also known as Offline NT Password and Registry Editor   
Download  [Files for USB Install (usb140201.zip)](https://www.techspot.com/downloads/6967-chntpw.html)
```
cd /mnt/rescueusb/boot/chntpw/
unzip usb140201.zip
mv initrd.cgz initrd.cpio.gz
mv scsi.cgz scsi.cpio.gz
gunzip initrd.cpio.gz
gunzip scsi.cpio.gz
cat scsi.cpio >> initrd.cpio
gzip initrd.cpio
rm boot.msg isolinux.bin isolinux.cfg readme.txt syslinux.cfg syslinux.exe usb140201.zip scsi.cpio
```

---------------------------------------------------------

### [Clonezilla to backup linux PC](https://clonezilla.org/downloads/download.php?branch=stable)   
### [HDD Regenerator](https://duckduckgo.com/?q=HDD+regenerator+img&t=h_&ia=web)   
### [Hirens BootCD 15.2 DOS](https://duckduckgo.com/?q=Hiren%27s+BootCD+15.2+DOS&t=hl&ia=web)   
### [MHDD DOS](http://www.mhdd.ru/files/mhdd32ver4.6floppy.exe)   
```
wget http://www.mhdd.ru/files/mhdd32ver4.6floppy.exe
7z e mhdd32ver4.6floppy.exe
cp mhdd32ver4.6floppy /mnt/rescueusb/boot/rescuecd/mhdd32ver4.6_Boot-1.44M.img
```
### [Norton Ghost 11 ima](https://duckduckgo.com/?q=nortonghost11.ima&t=h_&ia=web)   
### [Rescatux](https://www.supergrubdisk.org/category/download/rescatuxdownloads/rescatux-beta/)   
### [WHDD](https://www.richud.com/wiki/WHDD_Live_ISO_Boot_CD)   


-------------------------------------------------------------------------------------

## Testing:
To test USB drive easy i use QEMU

### Install QEMU:

```
sudo apt-get install qemu-system-x86 ovmf
mkdir testing_boot_usb
cd testing_boot_usb
```

### Create dummy drive image:
```
qemu-img create -f qcow test1.qcow 1G
```

### Options:
***(more RAM and cores = faster boot)***
* `-m 2048` - give 2GB RAM
* `-usb /dev/sdb` - attach usb drive
* `-hda test1.qcow` - attach dummy drive
* `-cpu kvm64` - emulated CPU
* `-smp cores=4` - set 4 cores to emulated CPU
* `-cdrom /some_iso.iso` - optional ISO images testing
* `-enable-kvm` - enable KVM full virtualization support (if host support virtualization it make boot way more faster)
* `-bios bios.bin` - use specific bios image
* `-boot order=dc` - Boot iso first

### To test in BIOS mode:
***X32***
```
sudo qemu-system-i386 -m 2048 -usb /dev/sdb -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm
```

***X64***
```
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdb -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm
```

### To test in UEFI mode:
***X32***
```
sudo qemu-system-i386 -m 2048 -usb /dev/sdb -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm -bios /usr/share/ovmf/OVMF.fd
```

***X64***
```
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdb -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm -bios /usr/share/ovmf/OVMF.fd
```

***Also you can test any other CPU, to show available CPU list:***
```
qemu-system-x86_64 -cpu help
```

