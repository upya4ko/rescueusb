# Update 2022-05-03 Move to docker

# Universal Rescue USB drive

I searching for recovery USB drive for long time, but all find solutions not fully cover my needs, so i decide make my ideal universal USB drive by myself.

In this repo i share my configs for GRUB2 and GRUB4DOS + instructions how format and test USB drive.

## This USB drive can:
* Boot on BIOS and UEFI
* Diagnose HW problems
* Install Linux (debian)
* Install Windows (XP, 7, 8.1, 10)
* Backup / Restore
* Pen-testing (Kali linux)
* Repair bootloader 
* Repair partition table
* Flash BIOS
* And more

----------------------------------------------


New docker usage:

Clone repo:
```
git clone git@github.com/upya4ko/rescueusb.git
cd rescueusb
```

# Make magic 
# (if you have rescueUSBbackup.tar.gz to ./rescueusb/backup/)


build docker image
```
./build.sh
```

Find your USB drive path
```
sudo dmesg
```

make basic setup
```
run-make-usb-shell.sh /dev/sdX make
```

update Debian based distros
```
run-make-usb-shell.sh /dev/sdX update
```

backup all distro from USB drive to archive
```
run-make-usb-shell.sh /dev/sdX backup
```

restore all distro files from archive to USB drive
```
run-make-usb-shell.sh /dev/sdX restore
```

to acces debug shell use
```
run-make-usb-shell.sh /dev/sdX debug
```


OLD README NEXT
# ---
## Items:
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

---

##### [Download GRUB4DOS](https://sourceforge.net/projects/grub4dos/) 
```
unzip grub4dos-0.4.4.zip
cp grub4dos-0.4.4/grub.exe /mnt/rescueusb/boot/
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
rm -r boot_dos/ boot_dos.zip
```

### Chntpw also known as Offline NT Password and Registry Editor   
Download  [Files for USB Install (usb140201.zip)](https://www.techspot.com/downloads/6967-chntpw.html)
```
cd /mnt/rescueusb/boot/chntpw/
unzip *
mv initrd.cgz initrd.cpio.gz
mv scsi.cgz scsi.cpio.gz
gunzip initrd.cpio.gz
gunzip scsi.cpio.gz
cat scsi.cpio >> initrd.cpio
gzip initrd.cpio
rm boot.msg isolinux.bin isolinux.cfg readme.txt syslinux.cfg syslinux.exe *.zip scsi.cpio
```

---------------------------------------------------------

### Clonezilla to backup linux PC
Go to [Clonezilla download page](https://clonezilla.org/downloads/download.php?branch=stable)
Select:
  * CPU - i686-pae
  * File type - ISO
  * Repository - auto

---------------------------------------------------------

### HDD Regenerator
You must buy one on [official site](http://www.dposoft.net/hdd.html)
Never search any livecd with this software.

--------------------------------------------------------
### [Hirens BootCD 15.2 DOS](https://www.google.com.ua/search?q=Hirens+BootCD+15.2+DOS)   

--------------------------------------------------------

### [MHDD DOS](http://www.mhdd.ru/files/mhdd32ver4.6floppy.exe)   
```
wget http://www.mhdd.ru/files/mhdd32ver4.6floppy.exe
7z e mhdd32ver4.6floppy.exe
cp mhdd32ver4.6floppy /mnt/rescueusb/boot/rescuecd/mhdd32ver4.6_Boot-1.44M.img
```

--------------------------------------------------------

### [Norton Ghost 11 ima](https://www.google.com.ua/search?q=Norton+Ghost+11+livecd)   

--------------------------------------------------------
### [Rescatux](https://www.supergrubdisk.org/category/download/rescatuxdownloads/rescatux-stable/)   

--------------------------------------------------------

### [WHDD](https://www.richud.com/wiki/WHDD_Live_ISO_Boot_CD)   


-------------------------------------------------------------------------------------

## Testing:
To test USB drive easy i use QEMU

*NOTE: Release mouse - Ctrl + Alt + G

### Install QEMU:

```
sudo apt-get install qemu-system-x86 ovmf
mkdir testing_boot_usb
cd testing_boot_usb
```

### Create dummy drive image:
```
dummyDriveCreate.sh
```

### Options:
***(more RAM and cores = faster boot)***
* `-m 2048` - give 2GB RAM
* `-usb /dev/sdb` - attach usb drive
* `-hda test1.qcow` - attach dummy drive
* `-cpu kvm64` - emulated CPU
* `-smp cores=2` - set 2 cores to emulated CPU
* `-cdrom /some_iso.iso` - optional ISO images testing
* `-enable-kvm` - enable KVM full virtualization support (if host support virtualization it make boot way more faster)
* `-bios bios.bin` - use specific bios image
* `-boot order=dc` - Boot iso first, a, b (floppy 1 and 2), c (first hard disk), d (first CD-ROM)
* `-fda floppy.img` - Attach floppy image

### To test in BIOS mode:
***X32***
```
qemu-bios-x86.sh
```

***X64***
```
qemu-bios-x64.sh
```

### To test in UEFI mode:
***X32***
```
qemu-uefi-x86.sh
```

***X64***
```
qemu-uefi-x86.sh
```

***Also you can test any other CPU, to show available CPU list:***
```
qemu-system-x86_64 -cpu help
```

