#!/system/bin/sh
# Copyright (c) 2009-2014, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# Enable s2s default
if [ -e /sys/android_touch/sweep2wake ]; then
	echo "2" > /sys/android_touch/sweep2wake
	echo "Furnace: sweep2sleep enabled" | tee /dev/kmsg
else
	echo "Furnace: Failed to set s2s" | tee /dev/kmsg
fi

# Enable powersuspend
if [ -e /sys/kernel/power_suspend/power_suspend_mode ]; then
	echo "1" > /sys/kernel/power_suspend/power_suspend_mode
	echo "Furnace: Powersuspend enabled" | tee /dev/kmsg
else
	echo "Furnace: Failed to set powersuspend" | tee /dev/kmsg
fi

# Set RGB KCAL
if [ -e /sys/devices/platform/kcal_ctrl.0/kcal ]; then
	echo "232 226 238" > /sys/devices/platform/kcal_ctrl.0/kcal
	echo "1" > /sys/devices/platform/kcal_ctrl.0/kcal_ctrl
	echo "Furnace: RGB KCAL: red=[232], green=[226], blue=[238]" | tee /dev/kmsg
else
	echo "Furnace: Failed to set RGB KCAL" | tee /dev/kmsg
fi

# Set Gamma - Piereligio's TrueRGBv7
if [ -e /sys/module/dsi_panel/kgamma_bn ]; then
	echo "0 12 19 30 39 48 56 72 82 104 118 127 119 116 115 106 84 78 66 60 44 35 20" > /sys/module/dsi_panel/kgamma_bn;
	echo "0 12 19 30 39 48 56 72 82 104 118 131 120 116 114 107 100 78 66 60 44 35 20" > /sys/module/dsi_panel/kgamma_bp;
	echo "0 12 20 31 40 55 62 76 89 109 123 132 115 113 111 103 78 75 67 58 49 39 21" > /sys/module/dsi_panel/kgamma_gn;
	echo "0 12 20 31 40 55 62 79 84 109 123 134 116 112 112 104 101 76 67 58 49 39 21" > /sys/module/dsi_panel/kgamma_gp;
	echo "0 12 19 30 39 48 56 72 83 105 119 130 119 115 116 106 88 80 71 62 52 42 25" > /sys/module/dsi_panel/kgamma_rn;
	echo "0 12 19 30 39 48 56 72 83 105 121 130 118 115 114 108 100 80 66 60 48 38 22" > /sys/module/dsi_panel/kgamma_rp;
	echo "32" > /sys/module/dsi_panel/kgamma_w;
	echo "Furnace: Gamma values set - TrueRGBv7" | tee /dev/kmsg
else
	echo "Furnace: Failed to set gamma values" | tee /dev/kmsg
fi
