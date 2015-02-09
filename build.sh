#!/bin/bash

export ARCH=arm
export SUBARCH=arm

build="/home/luca/Documenti/Unnamed-Kernel-Build"
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

echo "Which toolchain would you like to use?"

while read -p "sabernaro, linaromod, linaro or linaro-a7? " cchoice
do
echo
case "$cchoice" in
        sabernaro )
                toolchain="sabernaro"
                export CROSS_COMPILE=/home/luca/android/toolchain/SaberNaro-arm-eabi-4.9/bin/arm-eabi-
                break
                ;;
        linaromod )
                toolchain="linaromod"
                export CROSS_COMPILE=/home/luca/android/toolchain/LinaroMod-arm-eabi-4.9/bin/arm-eabi-
                break
                ;;
        linaro )
                toolchain="linaro"
                export CROSS_COMPILE=/home/luca/android/toolchain/linaro-arm-eabi-4.9/bin/arm-eabi-
                break
                ;;
        linaro-a7 )
                toolchain="linaro-a7"
                export CROSS_COMPILE=~/toolchain/android/arm-cortex_a7-linux-gnueabihf-linaro_4.9/bin/arm-cortex_a7-linux-gnueabihf-
                break
                ;;
esac
done

echo "Checking for build..."
if [ -f .done ]; then
	rm .done
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
	cp arch/arm/boot/"$kerneltype" ozip/kernel/
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
	./dtbToolCM -o ozip/kernel/dt.img -s 2048 -p scripts/dtc/ arch/arm/boot/
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
	echo "Done..."
	echo "Output zip: $build/$kernel-$rom-$variant-$date.zip"
	touch .done
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi

# Build script by Savoca
