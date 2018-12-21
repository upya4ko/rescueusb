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
sudo apt-get install parted ntfs-3g dosfstools grub
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
sudo grub-install --target=x86_64-efi --boot-directory="/mnt/rescueusb/boot" /dev/sdb
```

Only in /home/mcpcholkin/my_projects/git/etc/rescue-usb/part1_MAIN/boot/grub/i386-pc/: efi_gop.mod
Only in /home/mcpcholkin/my_projects/git/etc/rescue-usb/part1_MAIN/boot/grub/i386-pc/: efi_uga.mod















BIOS
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdc -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm


EFI
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdc -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm -bios bios.bin



