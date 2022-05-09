#!/bin/sh

#
# Grub2 Configuration file generator for BIOS and UEFI
#
# Upya4ko 2022-05-09
#

biosConf=$1
uefiConf=$2
bootDir=$3

if [ $# -lt 3 ]; then
  echo "ERROR! Usage:"
  echo "$(basename $0) /path/bios/grub.cfg /path/uefi/grub.cfg /path/boot"
fi


debianLiveIso=${bootDir}/debian/debian-live-amd64-xfce.iso
debianLiveVer=$(cat ${bootDir}/debian/ver.info)
debianLiveKernVer=$(isoinfo -i $debianLiveIso -l | grep "VMLINUZ_" | egrep -o "[0-9]{1,3}_[0-9]{1,3}\.[0-9]{1,3}_[0-9]{1,3}")

cat EOF << $biosConf
# Default boot line
default=0

# auto boot timeout
timeout=90

# color theme
color_normal=light-cyan/dark-gray
menu_color_normal=black/light-cyan
menu_color_highlight=white/black

#set root
search --label RESCUEUSB  --set=root
#set root=(hd0,2)


# --------------   boot menu ------------------

## Memtest 
menuentry "Memtest86+ 5.01" {
    linux16 /boot/memtest/bios/memtest86.bin
}

#---------------------------------------------------------------

# Boot windows 8 pe
menuentry "Windows 8 PE" {
    linux /boot/grub.exe --config-file=/boot/winpe.lst
}

#-----------------------------------------------------------------

# Acronis DD x86 BIOS
menuentry "Acronis Disk Director 12.0.3270 x86" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod ntldr
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    linux /boot/acronis/add/1.krn gfxpayload=800x600x16,800x600 force_modules=usbhid quiet
    initrd /boot/acronis/add/1.fs
}

#-----------------------------------------------------------------

# Debian Live CD X86
menuentry "Debian Live 10.3.0 i386 Xfce" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/debian/debian-live-i386-xfce.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz-5.10.0-13-686 boot=live components splash findiso=$isofile 
    initrd (loop)/live/initrd.img-5.10.0-13-686
}

#-----------------------------------------------------------------

# Acronis TI x86 BIOS
menuentry "Acronis True Image 2017 v20.0.8029 x86" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod ntldr
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    linux /boot/acronis/ati/1.krn gfxpayload=800x600x16,800x600 force_modules=usbhid quiet
    initrd /boot/acronis/ati/1.fs /boot/acronis/ati/1-1.fs
}

#-----------------------------------------------------------------

# WHDD
menuentry "WHDD Disk Test" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/rescuecd/whdd-live.iso
    loopback loop $isofile
    linux (loop)/bzImage findiso=$isofile
    initrd (loop)/initramfs
}

#-----------------------------------------------------------------

## Kali Linux x64
menuentry "Kali Linux x64" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/kali/kali-linux-2021-W42-live-amd64.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live components splash username=root hostname=kali findiso=$isofile
    initrd (loop)/live/initrd.img
}

#-----------------------------------------------------------------

submenu "Debian" {

# Debian Network Install X86
menuentry "Debian NetworkInstall 10.3.0 i386" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    linux /boot/debian/netinst_86/linux gfxpayload=800x600x16,800x600 --- quiet
    initrd /boot/debian/netinst_86/initrd.gz
}

# Debian Network Install X64
menuentry "Debian NetworkInstall 10.3.0 amd64" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    linux /boot/debian/netinst_64/linux gfxpayload=800x600x16,800x600 --- quiet
    initrd /boot/debian/netinst_64/initrd.gz
}

# Debian Live CD X64
menuentry "Debian Live 10.1.0 amd64 Xfce" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/debian/debian-live-10.1.0-amd64-xfce.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz-4.19.0-6-amd64 boot=live components splash findiso=$isofile
    initrd (loop)/live/initrd.img-4.19.0-6-amd64
}

}

#-----------------------------------------------------------------

submenu "Linux Mint" {

## Linux Mint
menuentry "Linux Mint 19 Xfce x86" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/mint/linuxmint-19.2-xfce-32bit.iso
    loopback loop $isofile
    linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$isofile noprompt noeject splash file=/cdrom/preseed/linuxmint.seed
    initrd (loop)/casper/initrd.lz
}

menuentry "Linux Mint 19 Xfce x64" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/mint/linuxmint-19.2-xfce-64bit.iso
    loopback loop $isofile
    linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$isofile noprompt noeject splash file=/cdrom/preseed/linuxmint.seed
    initrd (loop)/casper/initrd.lz
}

}

#-----------------------------------------------------------------


submenu "ETC" {

## HDD Regenerator
menuentry "HDD Regenerator 2011" {
    linux16 /boot/memdisk
    initrd16 /boot/rescuecd/hdd_regenerator_Boot-1.44M.img
}

## MHDD
menuentry "MHDD" {
    linux16 /boot/memdisk
    initrd16 /boot/rescuecd/mhdd32ver4.6_Boot-1.44M.img
}

#------------------------------------------------------------------

## MS DOS
menuentry "MS DOS 4.10" {
    linux16 /boot/memdisk
    initrd16 /boot/rescuecd/boot_dos.ima
}

## Norton Ghost 11
menuentry "Norton Ghost 11" {
    linux16 /boot/memdisk
    initrd16 /boot/rescuecd/nortonghost11.ima
}

submenu "Clonezilla" {

menuentry "Clonezilla i686-pae (Default settings, VGA 800x600)" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod ntldr
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    set isofile=/boot/rescuecd/clonezilla-live-2.6.3-7-i686-pae.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nomodeset edd=on ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" keyboard-layouts= ocs_live_batch=\"no\" locales= live_extra_param= ip= net.ifnames=0 nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso=$isofile gfxpayload=800x600x16,800x600
    initrd (loop)/live/initrd.img
}

menuentry "Clonezilla i686-pae (To RAM, boot media can be removed later)" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod ntldr
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    set isofile=/boot/rescuecd/clonezilla-live-2.6.3-7-i686-pae.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nomodeset edd=on ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" keyboard-layouts= ocs_live_batch=\"no\" locales= live_extra_param= ip= net.ifnames=0 nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso=$isofile gfxpayload=800x600x16,800x600 toram=live,syslinux,EFI
    initrd (loop)/live/initrd.img
}

menuentry "Clonezilla i686-pae (Failsafe mode)" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod ntldr
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    set isofile=/boot/rescuecd/clonezilla-live-2.6.3-7-i686-pae.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nomodeset edd=on ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" keyboard-layouts= ocs_live_batch=\"no\" locales= live_extra_param= ip= net.ifnames=0 nosplash findiso=$isofile gfxpayload=640x480x8,640x480 acpi=off irqpoll noapic noapm nodma nomce nolapic nosmp
    initrd (loop)/live/initrd.img
}


}

## Hiren's boot cd 15.2 RU 
menuentry "Hiren's boot cd 15.2 RU" {
    linux16 /boot/memdisk
    initrd16 /boot/rescuecd/hiren_15.2_ru.ima
}

menuentry "RescaTux 0.72b1 x64" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod tga
    set isofile=/boot/rescuecd/rescatux-0.72-beta1.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz1 boot=live config quiet splash selinux=1 security=selinux enforcing=0 locales=en_US.UTF-8 findiso=$isofile 
    initrd (loop)/live/initrd1.img
}

menuentry "RescaTux 0.72b1 x86" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod tga
    set isofile=/boot/rescuecd/rescatux-0.72-beta1.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz2 boot=live config quiet splash selinux=1 security=selinux enforcing=0 locales=en_US.UTF-8 findiso=$isofile 
    initrd (loop)/live/initrd2.img
}

menuentry "Offline NT/2000/XP/Vista/7 Password Changer" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    linux /boot/chntpw/vmlinuz gfxpayload=800x600x16,800x600 loglevel=1
    initrd /boot/chntpw/initrd.cpio.gz
}


# Acronis DD x64 
menuentry "Acronis Disk Director 12.0.3270 x64 UEFI" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    linux /boot/acronis/add/2.krn gfxpayload=800x600x16,800x600 force_modules=usbhid quiet
    initrd /boot/acronis/add/2.fs
}

# Acronis TI 64 
menuentry "Acronis True Image 2017 v20.0.8029 x64 UEFI" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs	
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    linux /boot/acronis/ati/2.krn gfxpayload=800x600x16,800x600 force_modules=usbhid quiet
    initrd /boot/acronis/ati/2.fs /boot/acronis/ati/2-1.fs
}

}

#-----------------------------------------------------------------

# Boot Ieshua's Live-DVD/USB  pe
#menuentry "Ieshua's Live-USB" {
#    search --label WINPE --set root
#    linux /boot/grub.exe 
#}

EOF


UEFI -----------------------------
# Default boot line
default=0

# auto boot timeout
timeout=90

# color theme
color_normal=light-cyan/dark-gray
menu_color_normal=black/light-cyan
menu_color_highlight=white/black

#set root
# Set root first patririon
search --label RESCUEUSB  --set=root
#set root=(hd0,2)


# --------------  boot menu ------------------

# -------------- Memtest86 UEFI -------------

menuentry "PassMark MemTest86 X64 (do not touch keyboard)" {
    chainloader /boot/memtest/uefi/BOOTX64.efi
}

#----------------------------------------------------------------

menuentry "Windows 10 PE UEFI" {
    insmod chain
    insmod fat
    insmod ntfs
    chainloader /EFI/microsoft/bootx64.efi
}

#-----------------------------------------------------------------

# Acronis DD x64 
menuentry "Acronis Disk Director 12.0.3270 x64 UEFI" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod msdospart
    insmod chain
    linux /boot/acronis/add/2.krn gfxpayload=800x600x16,800x600 force_modules=usbhid quiet
    initrd /boot/acronis/add/2.fs
}


#-----------------------------------------------------------------

# Debian Live CD X86
menuentry "Debian Live 10.1.0 i386 Xfce" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/debian/debian-live-10.1.0-i386-xfce.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz-4.19.0-6-686 boot=live components splash findiso=$isofile 
    initrd (loop)/live/initrd.img-4.19.0-6-686
}

#-----------------------------------------------------------------

# Acronis TI x64 UEFI  
menuentry "Acronis True Image 2017 v20.0.8029 x64 UEFI" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs	
    insmod msdospart
    insmod chain
    linux /boot/acronis/ati/2.krn gfxpayload=800x600x16,800x600 force_modules=usbhid quiet
    initrd /boot/acronis/ati/2.fs /boot/acronis/ati/2-1.fs
}

#-----------------------------------------------------------------

## Kali Linux x64
menuentry "Kali Linux x64" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/kali/kali-linux-xfce-2019.3-amd64.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live components splash username=root hostname=kali findiso=$isofile
    initrd (loop)/live/initrd.img
}

#-----------------------------------------------------------------

submenu "Debian" {

# Debian Network Install X86
menuentry "Debian NetworkInstall 10.1.0 i386" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    linux /boot/debian/netinst_86/linux gfxpayload=800x600x16,800x600 --- quiet
    initrd /boot/debian/netinst_86/initrd.gz
}

# Debian Network Install X64
menuentry "Debian NetworkInstall 10.1.0 amd64" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    linux /boot/debian/netinst_64/linux gfxpayload=800x600x16,800x600 --- quiet
    initrd /boot/debian/netinst_64/initrd.gz
}

# Debian Live CD X64
menuentry "Debian Live 10.1.0 amd64 Xfce" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/debian/debian-live-10.1.0-amd64-xfce.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz-4.19.0-6-amd64 boot=live components splash findiso=$isofile
    initrd (loop)/live/initrd.img-4.19.0-6-amd64
}

}

#-----------------------------------------------------------------

submenu "Linux Mint" {

## Linux Mint
menuentry "Linux Mint 19 Xfce x86" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod efi_gop
    insmod efi_uga
    set isofile=/boot/mint/linuxmint-19.2-xfce-32bit.iso
    loopback loop $isofile
    linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$isofile noprompt noeject splash file=/cdrom/preseed/linuxmint.seed
    initrd (loop)/casper/initrd.lz
}

menuentry "Linux Mint 19 Xfce x64" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod efi_gop
    insmod efi_uga
    set isofile=/boot/mint/linuxmint-19.2-xfce-64bit.iso
    loopback loop $isofile
    linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$isofile noprompt noeject splash file=/cdrom/preseed/linuxmint.seed
    initrd (loop)/casper/initrd.lz
}
}


#-----------------------------------------------------------------

submenu "ETC" {

## HDD Regenerator
menuentry "HDD Regenerator 2011 " { 
    linux16 /boot/memdisk
    initrd16 /boot/rescuecd/hdd_regenerator_Boot-1.44M.img
}

## MHDD
menuentry "MHDD" {
    linux16 /boot/memdisk
    initrd16 /boot/rescuecd/mhdd32ver4.6_Boot-1.44M.img
}

#-----------------------------------------------------------------

# Acronis DD x86 BIOS
menuentry "Acronis Disk Director 12.0.3270 x86" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod msdospart
    insmod chain
    linux /boot/acronis/add/1.krn gfxpayload=800x600x16,800x600 force_modules=usbhid quiet
    initrd /boot/acronis/add/1.fs
}

# Acronis TI x86 BIOS
menuentry "Acronis True Image 2017 v20.0.8029 x86" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod msdospart
    insmod chain
    linux /boot/acronis/ati/1.krn gfxpayload=800x600x16,800x600 force_modules=usbhid quiet
    initrd /boot/acronis/ati/1.fs /boot/acronis/ati/1-1.fs
}

# Clonezilla x86
submenu "Clonezilla" {

menuentry "Clonezilla i686-pae (Default settings, VGA 800x600)" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod ntldr
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    set isofile=/boot/rescuecd/clonezilla-live-2.6.3-7-i686-pae.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nomodeset edd=on ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" keyboard-layouts= ocs_live_batch=\"no\" locales= live_extra_param= ip= net.ifnames=0 nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso=$isofile gfxpayload=800x600x16,800x600
    initrd (loop)/live/initrd.img
}

menuentry "Clonezilla i686-pae (To RAM, boot media can be removed later)" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod ntldr
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    set isofile=/boot/rescuecd/clonezilla-live-2.6.3-7-i686-pae.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nomodeset edd=on ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" keyboard-layouts= ocs_live_batch=\"no\" locales= live_extra_param= ip= net.ifnames=0 nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 findiso=$isofile gfxpayload=800x600x16,800x600 toram=live,syslinux,EFI
    initrd (loop)/live/initrd.img
}

menuentry "Clonezilla i686-pae (Failsafe mode)" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    insmod ntldr
    insmod msdospart
    insmod chain
    insmod usb
    insmod usbms
    set isofile=/boot/rescuecd/clonezilla-live-2.6.3-7-i686-pae.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nomodeset edd=on ocs_live_run=\"ocs-live-general\" ocs_live_extra_param=\"\" keyboard-layouts= ocs_live_batch=\"no\" locales= live_extra_param= ip= net.ifnames=0 nosplash findiso=$isofile gfxpayload=640x480x8,640x480 acpi=off irqpoll noapic noapm nodma nomce nolapic nosmp
    initrd (loop)/live/initrd.img
}


}

# RescaTux
menuentry "RescaTux 0.72b1 x64" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso9660
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/rescuecd/rescatux-0.72-beta1.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz1 boot=live config quiet splash selinux=1 security=selinux enforcing=0 locales=en_US.UTF-8 findiso=$isofile 
    initrd (loop)/live/initrd1.img
}

menuentry "RescaTux 0.72b1 x86" {
    insmod part_msdos
    insmod ext2
    insmod loopback
    insmod iso96600.51b3
    insmod gzio
    insmod fat
    insmod ntfs
    set isofile=/boot/rescuecd/rescatux-0.72-beta1.iso
    loopback loop $isofile
    linux (loop)/live/vmlinuz2 boot=live config quiet splash selinux=1 security=selinux enforcing=0 locales=en_US.UTF-8 findiso=$isofile 
    initrd (loop)/live/initrd2.img
}

}

#-----------------------------------------------------------------
