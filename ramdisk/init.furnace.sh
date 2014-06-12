#!/system/bin/sh
# Copyright (c) 2014, Savoca <adeddo27@gmail.com>
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

# The Redundancy Department of Redundance Inc. needs to pay this file a visit.

# Enable s2s default
if [ -e /sys/android_touch/sweep2wake ]; then
	echo "2" > /sys/android_touch/sweep2wake
	echo "[furnace] sweep2sleep enabled" | tee /dev/kmsg
else
	echo "[furnace] Failed to set s2s" | tee /dev/kmsg
fi

# Enable powersuspend
if [ -e /sys/kernel/power_suspend/power_suspend_mode ]; then
	echo "1" > /sys/kernel/power_suspend/power_suspend_mode
	echo "[furnace] Powersuspend enabled" | tee /dev/kmsg
else
	echo "[furnace] Failed to set powersuspend" | tee /dev/kmsg
fi

if [ -e /sdcard/furnace/furnace.cfg ]; then
	echo "[furnace] furnace.cfg found - using config values" | tee /dev/kmsg
	sd_gamma=`awk 'NR == 1' /sdcard/furnace/furnace.cfg | cut -d "=" -f2`
	sd_r=`awk 'NR == 2' /sdcard/furnace/furnace.cfg | cut -d "=" -f2`
	sd_g=`awk 'NR == 3' /sdcard/furnace/furnace.cfg | cut -d "=" -f2`
	sd_b=`awk 'NR == 4' /sdcard/furnace/furnace.cfg | cut -d "=" -f2`
else
	echo "[furnace] furnace.cfg not found - using cmdline values" | tee /dev/kmsg
	if [ -e /sys/module/mdss_dsi/parameters/kcal_profile_r ]; then
		sd_gamma=`cat /sys/module/mdss_dsi/parameters/gamma_profile`
		sd_r=`cat /sys/module/mdss_dsi/parameters/kcal_profile_r`
		sd_g=`cat /sys/module/mdss_dsi/parameters/kcal_profile_g`
		sd_b=`cat /sys/module/mdss_dsi/parameters/kcal_profile_b`
	fi
fi
# Set RGB KCAL
if [ -e /sys/devices/platform/kcal_ctrl.0/kcal ]; then
	kcal="$sd_r $sd_g $sd_b"
	echo "$kcal" > /sys/devices/platform/kcal_ctrl.0/kcal
	echo "1" > /sys/devices/platform/kcal_ctrl.0/kcal_ctrl
	echo "[furnace] RGB KCAL: red=[$sd_r], green=[$sd_g], blue=[$sd_b]" | tee /dev/kmsg
else
	echo "[furnace] Failed to set RGB KCAL" | tee /dev/kmsg
fi

# Gamma Presets
function set_TrueRGB {
	echo "0 12 19 30 39 48 56 72 82 104 118 127 119 116 115 106 84 78 66 60 44 35 20" > /sys/module/dsi_panel/kgamma_bn
	echo "0 12 19 30 39 48 56 72 82 104 118 131 120 116 114 107 100 78 66 60 44 35 20" > /sys/module/dsi_panel/kgamma_bp
	echo "0 12 20 31 40 55 62 76 89 109 123 132 115 113 111 103 78 75 67 58 49 39 21" > /sys/module/dsi_panel/kgamma_gn
	echo "0 12 20 31 40 55 62 79 84 109 123 134 116 112 112 104 101 76 67 58 49 39 21" > /sys/module/dsi_panel/kgamma_gp
	echo "0 12 19 30 39 48 56 72 83 105 119 130 119 115 116 106 88 80 71 62 52 42 25" > /sys/module/dsi_panel/kgamma_rn
	echo "0 12 19 30 39 48 56 72 83 105 121 130 118 115 114 108 100 80 66 60 48 38 22" > /sys/module/dsi_panel/kgamma_rp
	echo "32" > /sys/module/dsi_panel/kgamma_w
	echo "[furnace] Gamma values set: TrueRGB" | tee /dev/kmsg
}

function set_Yorici_v3 {
	echo "107 108 111 109 112 115 118 123 124 130 133 136 115 111 104 85 73 58 48 38 28 17 9" > /sys/module/dsi_panel/kgamma_bn
	echo "107 108 111 109 113 115 117 123 123 130 133 136 116 112 104 86 73 58 48 37 28 17 8" > /sys/module/dsi_panel/kgamma_bp
	echo "90 90 94 91 96 97 102 113 116 125 130 134 117 113 106 90 76 58 46 38 30 20 9" > /sys/module/dsi_panel/kgamma_gn
	echo "90 90 94 91 96 98 101 113 115 125 130 134 117 113 106 90 76 58 50 40 30 20 9" > /sys/module/dsi_panel/kgamma_gp
	echo "0 0 17 28 38 39 49 73 87 103 114 122 127 121 113 98 78 60 50 40 30 20 9" > /sys/module/dsi_panel/kgamma_rn
	echo "0 0 17 28 37 37 47 73 87 103 114 122 127 122 114 97 78 60 50 40 30 20 9" > /sys/module/dsi_panel/kgamma_rp
	echo "31" > /sys/module/dsi_panel/kgamma_w
	echo "[furnace] Gamma values set: Yorici_v3" | tee /dev/kmsg
}

function set_faux123 {
	echo "78 87 89 91 94 96 101 109 111 123 126 131 120 116 110 99 84 71 61 52 40 33 20" > /sys/module/dsi_panel/kgamma_bn
	echo "78 87 89 91 94 96 101 109 111 123 126 131 120 116 110 99 84 71 61 52 40 33 20" > /sys/module/dsi_panel/kgamma_bp
	echo "73 73 75 78 81 84 90 100 105 117 124 130 121 117 111 100 85 73 64 58 50 37 21" > /sys/module/dsi_panel/kgamma_gn
	echo "73 73 75 78 81 84 90 100 105 117 124 130 121 117 111 100 85 73 64 58 50 37 21" > /sys/module/dsi_panel/kgamma_gp
	echo "0 10 17 27 37 45 56 72 83 107 112 121 128 123 117 106 91 78 68 62 53 38 22" > /sys/module/dsi_panel/kgamma_rn
	echo "0 10 17 27 37 45 56 72 83 100 112 121 128 123 117 106 91 78 68 62 53 38 22" > /sys/module/dsi_panel/kgamma_rp
	echo "30" > /sys/module/dsi_panel/kgamma_w
	echo "[furnace] Gamma values set: faux123" | tee /dev/kmsg
}

function set_perfect {
	echo "6 12 19 30 39 48 56 72 83 113 119 126 121 113 106 98 88 73 63 54 40 33 20" > /sys/module/dsi_panel/kgamma_bn
	echo "6 12 19 30 39 48 56 72 83 113 119 130 121 113 108 99 88 74 63 54 40 33 20" > /sys/module/dsi_panel/kgamma_bp
	echo "6 12 19 30 39 48 56 72 83 118 123 131 118 111 105 97 86 73 63 54 45 37 21" > /sys/module/dsi_panel/kgamma_gn
	echo "6 12 19 30 39 48 56 72 83 118 123 131 118 111 105 98 86 73 63 54 45 37 21" > /sys/module/dsi_panel/kgamma_gp
	echo "6 12 19 30 39 48 56 72 83 111 122 126 119 113 106 99 88 73 63 53 44 36 22" > /sys/module/dsi_panel/kgamma_rn
	echo "6 12 19 30 39 48 56 72 83 111 122 134 119 113 106 99 88 72 59 50 44 36 22" > /sys/module/dsi_panel/kgamma_rp
	echo "32" > /sys/module/dsi_panel/kgamma_w
	echo "[furnace] Gamma values set: Perfect" | tee /dev/kmsg
}

function set_vomer {
	echo "0 12 19 30 39 48 56 72 83 105 118 126 121 114 109 102 93 73 63 54 40 33 20" > /sys/module/dsi_panel/kgamma_bn
	echo "0 12 19 30 39 48 56 72 83 105 118 130 121 115 114 102 82 76 63 54 40 33 20" > /sys/module/dsi_panel/kgamma_bp
	echo "0 12 19 30 39 54 61 78 84 107 123 132 117 110 108 97 90 71 61 52 45 37 21" > /sys/module/dsi_panel/kgamma_gn
	echo "0 12 19 30 39 54 61 78 84 107 121 130 119 112 107 99 76 72 57 50 45 37 21" > /sys/module/dsi_panel/kgamma_gp
	echo "0 12 19 30 39 48 56 72 83 105 121 126 119 112 107 99 91 71 63 53 44 36 22" > /sys/module/dsi_panel/kgamma_rn
	echo "0 12 19 30 39 48 56 72 83 105 121 134 119 113 110 98 78 72 59 50 44 36 22" > /sys/module/dsi_panel/kgamma_rp
	echo "32" > /sys/module/dsi_panel/kgamma_w
	echo "[furnace] Gamma values set: vomer" | tee /dev/kmsg
}

function set_TGM {
	echo "90 91 93 95 98 100 105 114 116 125 131 135 117 112 106 92 75 65 56 48 36 29 16" > /sys/module/dsi_panel/kgamma_bn
	echo "90 91 93 95 98 100 105 114 116 125 131 135 117 112 106 92 75 65 56 48 36 29 16" > /sys/module/dsi_panel/kgamma_bp
	echo "84 85 86 88 91 94 101 111 115 127 132 136 115 111 106 94 78 69 63 57 49 36 20" > /sys/module/dsi_panel/kgamma_gn
	echo "84 85 86 88 91 94 101 111 115 127 132 136 115 111 106 94 78 69 63 57 49 36 20" > /sys/module/dsi_panel/kgamma_gp
	echo "0 10 17 27 37 45 57 75 86 120 117 125 125 119 113 100 85 75 67 61 52 37 21" > /sys/module/dsi_panel/kgamma_rn
	echo "0 10 17 27 37 45 57 75 86 120 117 125 125 119 113 100 85 75 67 61 52 37 21" > /sys/module/dsi_panel/kgamma_rp
	echo "32" > /sys/module/dsi_panel/kgamma_w
	echo "[furnace] Gamma values set: TheGingerbreadMan" | tee /dev/kmsg
}

function set_stock {
	echo "86 87 89 91 94 96 101 109 111 121 126 131 120 116 110 99 84 71 61 52 40 33 20" > /sys/module/dsi_panel/kgamma_bn
	echo "86 87 89 91 94 96 101 109 111 121 126 131 120 116 110 99 84 71 61 52 40 33 20" > /sys/module/dsi_panel/kgamma_bp
	echo "71 73 75 78 81 84 90 100 105 117 124 130 121 117 111 100 85 73 64 58 50 37 21" > /sys/module/dsi_panel/kgamma_gn
	echo "71 73 75 78 81 84 90 100 105 117 124 130 121 117 111 100 85 73 64 58 50 37 21" > /sys/module/dsi_panel/kgamma_gp
	echo "0 10 17 27 37 45 56 72 83 101 112 121 128 123 117 106 91 78 68 62 53 38 22" > /sys/module/dsi_panel/kgamma_rn
	echo "0 10 17 27 37 45 56 72 83 101 112 121 128 123 117 106 91 78 68 62 53 38 22" > /sys/module/dsi_panel/kgamma_rp
	echo "32" > /sys/module/dsi_panel/kgamma_w
	echo "[furnace] Gamma values set: stock" | tee /dev/kmsg
}

# Fallback Gamma
function set_fallback {
	echo "[furnace] config missing - setting cmdline gamma" | tee /dev/kmsg
	gamma=`cat /sys/module/mdss_dsi/parameters/gamma_profile`
	if [ $gamma == 1 ]; then
		set_TrueRGB
	elif [ $gamma == 2 ]; then
		set_Yorici_v3
	elif [ $gamma == 3 ]; then
		set_faux123
	elif [ $gamma == 4 ]; then
		set_perfect
	elif [ $gamma == 5 ]; then
		set_vomer
	elif [ $gamma == 6 ]; then
		set_TGM
	else
		set_stock
	fi
}

# Set Gamma
if [ -e /sys/module/dsi_panel/kgamma_w ]; then
	if [ "$sd_gamma" == "TrueRGB" ]; then
		set_TrueRGB
	elif [ "$sd_gamma" == "Yorici_v3" ]; then
		set_Yorici_v3
	elif [ "sd_gamma" == "faux123" ]; then
		set_faux123
	elif [ "sd_gamma" == "perfect" ]; then
		set_perfect
	elif [ "sd_gamma" == "vomer" ]; then
		set_vomer
	elif [ "sd_gamma" == "TGM" ]; then
		set_TGM
	elif [ "sd_gamma" == "stock" ]; then
		set_stock
	else
		set_fallback
	fi
fi
