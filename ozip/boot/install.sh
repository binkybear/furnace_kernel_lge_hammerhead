#!/sbin/sh
echo "[furnace] recovery log start" | tee /dev/kmsg
gamma="stock"
kcal_r=255
kcal_g=255
kcal_b=255
if [ -f /tmp/furnace.cfg ]; then
	gamma=$(awk 'NR == 14' /tmp/furnace.cfg | cut -d "=" -f2)
	kcal_r=$(awk 'NR == 19' /tmp/furnace.cfg | cut -d "=" -f2)
	kcal_g=$(awk 'NR == 20' /tmp/furnace.cfg | cut -d "=" -f2)
	kcal_b=$(awk 'NR == 21' /tmp/furnace.cfg | cut -d "=" -f2)
else
	echo "[furnace] furnace.cfg not found - using stock values" | tee /dev/kmsg
fi

echo "console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 maxcpus=4 msm_watchdog_v2.enable=1 gamma=$gamma kcal_r=$kcal_r kcal_g=$kcal_g kcal_b=$kcal_b"  > /tmp/cmdline.cfg
echo "[furnace] cmdline: $(cat /tmp/cmdline.cfg)"

chmod 775 /tmp/boot/mkbootimg
/tmp/boot/mkbootimg --kernel /tmp/boot/zImage-dtb --ramdisk /tmp/boot/ramdisk.gz --cmdline "$(cat /tmp/cmdline.cfg)" --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --output /tmp/boot.img

if [ -f /tmp/boot.img ]; then
	echo "[furnace] boot.img created" | tee /dev/kmsg
else
	echo "[furnace] boot.img failed to create!" | tee /dev/kmsg
	exit 0;
fi

dd if=/tmp/boot.img of=/dev/block/platform/msm_sdcc.1/by-name/boot || exit 1;
echo "[furnace] boot.img installed" | tee /dev/kmsg
rm -rf /tmp/*
