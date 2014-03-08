#!/sbin/sh
dd if=/dev/block/platform/msm_sdcc.1/by-name/boot of=/tmp/boot.img
./tmp/unpackbootimg -i /tmp/boot.img -o /tmp
./tmp/mkbootimg --kernel /tmp/zImage-dtb --ramdisk /tmp/boot.img-ramdisk.gz --cmdline "$(cat /tmp/boot.img-cmdline)" --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 -o /tmp/newboot.img
dd if=/tmp/newboot.img of=/dev/block/platform/msm_sdcc.1/by-name/boot
return $?
