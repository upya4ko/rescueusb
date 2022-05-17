#!/bin/sh

DEV=$1
IMAGE="myregistry.com:5001/rescue-usb-maker"
PARAM=$2


if [ ! -b "$DEV" ] && [ ! -f "$DEV" ]; then
  echo "ERROR $DEV is not block device or image"
  exit 1
else

  case $PARAM in
    backup)
      backupDir=$PWD/backup
      mkdir -p $backupDir
      chmod -R 777 $backupDir
      
      docker run --rm -it \
      --privileged \
      -v $backupDir:/mnt/backup \
      $IMAGE $DEV $PARAM
 
#      -v /dev:/dev \
#      -v /proc:/proc \
#      -v $backupDir:/mnt/backup \
#      $IMAGE $DEV $PARAM
    ;;
    restore)
      backupDir=$PWD/backup
      
      docker run --rm -it \
      --privileged \
      -v $backupDir:/mnt/backup \
      $IMAGE $DEV $PARAM
#
#      -v /dev:/dev \
#      -v /proc:/proc \
#      -v $backupDir:/mnt/backup \
#      $IMAGE $DEV $PARAM
    ;;
    *)
      docker run --rm -it \
      --privileged \
      $IMAGE $DEV $PARAM

#      -v /dev:/dev \
#      -v /proc:/proc \
#      $IMAGE $DEV $PARAM
    ;;
  esac

fi


