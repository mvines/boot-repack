#!/bin/bash

LOCAL_PATH=$(dirname $(readlink -f $0))

ORG_BOOT_IMG=boot.img
NEW_BOOT_IMG=newboot.img

if [[ ! -f $ORG_BOOT_IMG ]]; then
  echo $ORG_BOOT_IMG not found
  exit
fi

set -ex
source <($LOCAL_PATH/split_bootimg.pl $ORG_BOOT_IMG)

rm -rf ramdisk
mkdir ramdisk
cd ramdisk
gunzip -c $LOCAL_PATH/$RAMDISK | cpio -i

find . | cpio -o -H newc | gzip > $LOCAL_PATH/$RAMDISK
cd ..

COMMANDLINE_EXTRA="androidboot.selinux=permissive"

if [[ ! -d $LOCAL_PATH/mkbootimg_tools ]]; then
  git clone https://github.com/xiaolu/mkbootimg_tools.git $LOCAL_PATH/mkbootimg_tools
fi

$LOCAL_PATH/mkbootimg_tools/mkbootimg --kernel $KERNEL --ramdisk $RAMDISK --pagesize $PAGESIZE \
  --base $BASEADDRESS --dt $DTB --cmdline "$COMMANDLINE_EXTRA $COMMANDLINE" -o $NEW_BOOT_IMG

ls -l $NEW_BOOT_IMG
