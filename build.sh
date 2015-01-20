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
if [ -f kernel/zImage ]; then
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
	cp arch/arm/boot/"$kerneltype" out/ozip/kernel/
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

echo "Zipping..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cd ozip
	zip -r ../"$kernel"-"$rom"-"$variant"-"$date".zip .
	mv ../"$kernel"-"$rom"-"$variant"-"$date".zip $build
	cd ..
	rm -rf out
	echo "Done..."
	echo "Output zip: $build/$kernel-$rom-$variant-$date.zip"
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi

# Build script by Savoca
