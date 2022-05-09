#!/bin/sh

DRIVE=$1
PARAM=$2
BACKUP_DIR=/mnt/backup
SECOND_PART_SIZE=5
FIRST_PART_NAME=RESCUEUSB
SECOND_PART_NAME=UEFI

confirmDriveSelect() {
  parted $DRIVE p

  read -n1 -r -p "\nCheck $DRIVE is right? y/N\n\
  Press Y to continue or press any key to abort\n" input

  echo your answer is $input

  case $input in
    y | Y | yes | Yes)
      echo $input $DRIVE
      ;;
    *) 
      echo -e "Abort! $DRIVE is wrong\n"
      exit 1
      ;;
  esac
}

makePartTable() {
  # Cleanup old partition table
  dd if=/dev/zero of=$DRIVE bs=1M count=10

  # Create Master Boot Record
  parted $DRIVE mktable msdos

  # Calculate 5MB from end of drive
  DRIVE_SIZE=$(parted $DRIVE unit MB p |\
               grep "Disk $DRIVE: " |\
               awk '{print $NF}' |\
               tr -d 'MB' 
               )

    #echo DEBUG $DRIVE_SIZE $SECOND_PART_SIZE

    SPLIT_PLACE=$(expr $DRIVE_SIZE - $SECOND_PART_SIZE)
  
    # Make first part (BIOS)
    parted $DRIVE mkpart primary ntfs 0% ${SPLIT_PLACE}MB

    # Make second part (UEFI)
    parted --align=optimal $DRIVE mkpart primary ESP fat32 ${SPLIT_PLACE}MB 100%

    # Make main partition bootable
    parted $DRIVE set 1 boot on

    # Print result
    parted $DRIVE unit MB p
}

formarParts() {
  # Format first part
  mkfs.ntfs -f -L $FIRST_PART_NAME ${DRIVE}1

  # Format second part
  mkfs.msdos -n $SECOND_PART_NAME ${DRIVE}2
}

mountParts() {
  # Make mount point dirs
  mkdir -p /mnt/part1 \
           /mnt/part2
  # Mount drive to points
  mount -t ntfs ${DRIVE}1 /mnt/part1
  mount -t msdos ${DRIVE}2 /mnt/part2
}

installGrub2() {
  # Make dirs
  mkdir -p /mnt/part1/boot \
           /mnt/part2/EFI/BOOT/
  # Install Grub for BIOS
  grub-install --target=i386-pc \
               --boot-directory="/mnt/part1/boot" \
               ${DRIVE}
  # Install Grub for UEFI
  GRUB_MODULES="fat iso9660 part_gpt part_msdos ntfs 
                ext2 exfat btrfs hfsplus udf font gettext 
                gzio normal boot linux linux16 configfile 
                loopback chain efifwsetup efi_gop efi_uga 
                ls help echo elf search search_label 
                search_fs_uuid search_fs_file test all_video 
                loadenv gfxterm gfxterm_background gfxterm_menu
                msdospart multiboot"
  grub-mkimage -o /mnt/part2/EFI/BOOT/bootx64.efi -p /boot/grub -O x86_64-efi $GRUB_MODULES
  grub-mkimage -o /mnt/part2/EFI/BOOT/bootia32.efi -p /boot/grub -O i386-efi $GRUB_MODULES

}

umountParts() {
  umount ${DRIVE}1
  umount ${DRIVE}2
}


copyMemdisk() {
  cp /boot/memdisk /mnt/part1/boot/
}

downloadDefragFS() {
  wget https://raw.githubusercontent.com/ThomasCX/defragfs/master/defragfs -O /mnt/part1/boot/defragfs
}

updateDebian() {
  /updateDebian.sh /mnt/part1/boot/debian
}

updateKali() {
  /updateKali.sh /mnt/part1/boot/kali
}

configGenerator() {
  /configFileGenerator.sh /mnt/part1/boot/grub /mnt/part2/boot/grub/grub.conf /mnt/part1/boot
}

installMemtest() {
  /installMemtest.sh /mnt/part1/boot/memtest
}

testUsbDrive() {
  # Cleanup old partition table
  dd if=/dev/zero of=$DRIVE bs=1M count=10

  # Create Master Boot Record
  parted $DRIVE mktable msdos

  # Make one test part
  parted $DRIVE mkpart primary ext2 0% 100%
  mkfs.ext2 ${DRIVE}1

  mkdir -p /mnt/f3
  mount -t ext2 $DRIVE /mnt/f3

  f3write /mnt/f3/
  f3read /mnt/f3/
  f3exitCode=$?

  sync
  umount ${DRIVE}1

  if [ $f3exitCode == 0 ] ; then
    echo -e "All OK, drive $DRIVE is in good condition\n"
  else
    echo -e "ERROR! DRIVE - $DRIVE HAVE A PROBLEM!"
    exit 1
  fi
}

backupCurrentDrive() {

  tar --create \
      --file $BACKUP_DIR/rescueUSBbackup.tar.gz \
      --gzip \
      --verbose \
      --exclude-backups \
      --block-number \
      --files-from /backupList.txt

      tarExitCode=$?

      chmod 777 $BACKUP_DIR/rescueUSBbackup.tar.gz

      if [ "$tarExitCode" -eq 0 ] ; then
        echo "Backup success!"
      else
        echo "Backup FAIL! $tarExitCode"
        exit 1
      fi

}

restoreCurrentDrive() {
  tar --overwrite \
      --file $BACKUP_DIR/rescueUSBbackup.tar.gz \
      --verbose \
      -C / \
      --extract

      tarExitCode=$?

      if [ "$tarExitCode" -eq 0 ] ; then
        echo "Restore success!"
      else
        echo "Restore FAIL! $tarExitCode"
        exit 1
      fi

}


case "$PARAM" in
  make)
    confirmDriveSelect
    makePartTable
    formarParts
    mountParts
    installGrub2
    copyMemdisk
    downloadDefragFS
  #  updateDebian
  #  updateKali
#    configGenerator
    installMemtest
    umountParts
  ;;
  update)
    # Update installed distro
    echo -e "Start Update\n"
    mountParts
    updateDebian
    updateKali
    configGenerator
    umountParts
  ;;
  install)
    mountParts
    installMemtest
    umountParts
  ;;
  test)
    testUsbDrive
  ;;
  backup)
    mountParts
    backupCurrentDrive
    umountParts
  ;;
 restore)
    mountParts
    restoreCurrentDrive
    umountParts
  ;;
  debug)
    /bin/bash
  ;;
  *)
    echo "ERROR, Usage: /path/to/dev debug/make"
    echo "debug - Go to shell"
    echo "make - Wipe And create new partitions on drive"
    echo "update - Update linux distro"
    echo "backup - Backup files stored on usb to archive"
    echo "restore - Restore files from backup to usb drive"
    exit 1
  ;;
esac


