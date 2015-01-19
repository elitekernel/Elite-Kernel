#!/bin/bash

export ARCH=arm

build=/home/luca/Documenti/Unnamed-Kernel-Build
export CROSS_COMPILE=~/toolchain/android_prebuilts_gcc_linux-x86_arm_sabermod-arm-eabi-4.8-master/bin/arm-eabi-

kernel="Unnamed-Kernel"
date="$(date +'%d_%m_%Y')"
rom="cm-12.0"
variant="titan"
config="titan_defconfig"
kerneltype="zImage"
jobcount="-j$(grep -c ^processor /proc/cpuinfo)"
ps=2048
base_offset=0x00000000
ramdisk_offset=0x01000000
tags_offset=0x00000100
cmdline="console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 androidboot.bootdevice=msm_sdcc.1 vmalloc=400M utags.blkdev=/dev/block/platform/msm_sdcc.1/by-name/utags androidboot.write_protect=0"

function cleanme {
	if [ -f arch/arm/boot/"$kerneltype" ]; then
		echo "  CLEAN   ozip"
	fi
	rm -rf ozip/boot.img
	rm -rf arch/arm/boot/"$kerneltype"
	make clean && make mrproper
	echo "Working directory cleaned..."
}

rm -rf out
mkdir out
mkdir out/tmp
echo "Checking for build..."
if [ -f ozip/boot.img ]; then
	read -p "Previous build found, clean working directory..(y/n)? : " cchoice
	case "$cchoice" in
		y|Y )
			cleanme;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
	read -p "Begin build now..(y/n)? : " dchoice
	case "$dchoice" in
		y|Y)
			make "$config"
			make "$jobcount"
			exit 0;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
fi
echo "Extracting files..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cp arch/arm/boot/"$kerneltype" out/"$kerneltype"
else
	echo "Nothing has been made..."
	read -p "Clean working directory..(y/n)? : " achoice
	case "$achoice" in
		y|Y )
			cleanme;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
	read -p "Begin build now..(y/n)? : " bchoice
	case "$bchoice" in
		y|Y)
			make "$config"
			make "$jobcount"
			exit 0;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
fi

echo "Making dt.img..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	./dtbToolCM -o out/dt.img -s 2048 -p scripts/dtc/ arch/arm/boot/
	echo "dt.img created"
else
	echo "No build found..."
	exit 0;
fi

echo "Making boot.img..."
if [ -f out/"$kerneltype" ]; then
	./mkbootimg --kernel out/"$kerneltype" --ramdisk resources/ramdisk.cpio.gz --cmdline "$cmdline" --pagesize $ps --base $base_offset --ramdisk_offset $ramdisk_offset --tags_offset $tags_offset --dt out/dt.img --output ozip/boot.img
	if [ -z ozip/boot.img ]; then
		echo "mkbootimg failed..."
		exit 0;
	fi
else
	echo "No $kerneltype found..."
	exit 0;
fi

echo "Zipping..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cd ozip
	zip -r ../"$kernel"-"$rom"-"$variant"-"$date".zip .
	mv ../"$kernel"-"$rom"-"$variant"-"$date".zip $build
	cd ..
	rm -rf out
	echo "Done..."
	echo "Output zip: $build/$kernel-$version-$(echo $rom)_$variant.zip"
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi

# Build script by Savoca
