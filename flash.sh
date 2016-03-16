#!/bin/bash -x
cp kernel.img /media/krinkle/boot
sync
umount /dev/mmcblk0p1
umount /dev/mmcblk0p2
