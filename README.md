# RT Jetson

Preempt-RT Kernel Build Guide for NVIDIA Development Board

The system used to build the image is Ubuntu 20.04.6 LTS, which is recommended because the current version of L4T is based on Ubuntu 20.04.

- Jetpack version: 6.0
- Jetson Linux version: 36.4.0
- Linux Kernel version: 5.15
- GCC Toolchain: 11.3

This guide and this [Reference](https://forums.developer.nvidia.com/t/preempt-rt-patches-for-jetson-nano/72941/10) only tested on the Xavier developer kit and Jetson Nano development board.

Since L4T and related source codes are common to all NVIDIA development boards, so this tutorial is theoretically applicable to all NVIDIA development boards supported by L4T.

The only thing to note is that a specific version of L4T and related source codes only support the development platforms supported by this version of L4T, and cross-version hardware support is hard to guarantee.

**Modify the $BUILD_DIR Parameter in the two scripts before you use them if you need a different Build Path other than ~/RTJetsonBuild.**

## Install Dependencies

	sudo apt update && sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
	sudo apt install -y build-essential bc libncurses5-dev lbzip2 pkg-config flex bison libssl-dev qemu-user-static

## Create build folder

	mkdir ~/RTJetsonBuild 
	cd ~/RTJetsonBuild

## Download the following files in the nvidia-rt folder:

- [L4T Jetson Driver Package](https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2)

- [L4T Sample Root File System](https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/release/Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2)

- [L4T Sources](https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/sources/public_sources.tbz2)

- [GCC Tool Chain for 64-bit BSP](https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v3.0/toolchain/aarch64--glibc--stable-2022.08-1.tar.bz2)


## Extract files

	sudo tar xpf Jetson_Linux_R36.4.0_aarch64.tbz2 
	cd Linux_for_Tegra/rootfs/ 
	sudo tar xpf ../../Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2
	cd ../../ 
	tar -xvf aarch64--glibc--stable-2022.08-1.tar.bz2
	sudo tar -xjf public_sources.tbz2
	tar -xjf Linux_for_Tegra/source/kernel_src.tbz2

## Apply PREEMPT-RT patches

	sudo ./generic_rt_build.sh enable

## Compile kernel

	TEGRA_KERNEL_OUT=kernel_out 
	mkdir $TEGRA_KERNEL_OUT 
	export CROSS_COMPILE=$BUILD_DIR/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
	make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig 
	make ARCH=arm64 O=$TEGRA_KERNEL_OUT menuconfig 

## This option should already be selected:

	General setup -> Preemption Model (Fully Preemptible Kernel (Real-Time))

## You can modify other options for your kernel, like the timer frequency (or anything you need):

	Kernel Features -> Timer frequency: 1000 HZ 

## After saving the configuration and exiting, start the kernel compilation

	make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j$(nproc) 

## Copy results

	sudo cp kernel_out/arch/arm64/boot/Image ~/RTJetsonBuild/Linux_for_Tegra/kernel/Image
	sudo cp kernel_out/arch/arm64/boot/Image.gz ~/RTJetsonBuild/Linux_for_Tegra/kernel/Image.gz
	sudo cp -r kernel_out/arch/arm64/boot/dts/nvidia/* ~/RTJetsonBuild/Linux_for_Tegra/kernel/dtb/ 
	sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=~/RTJetsonBuild/Linux_for_Tegra/rootfs/ 
	cd ~/RTJetsonBuild/Linux_for_Tegra/rootfs/ 
	sudo tar --owner root --group root -cjf kernel_supplements.tbz2 lib/modules 
	sudo mv kernel_supplements.tbz2  ../kernel/ 

## Apply binaries

	cd .. 
	sudo ./apply_binaries.sh

## Choose flash method and flash compiled system image

- Generate System Image for SD flash

    This method is mostly used in the case of directly using the SD card as the boot device and is not limited to Xavier, it can also support other NVIDIA development boards in theory, such as Jetson Nano.

	    cd tools
	    sudo ./jetson-disk-image-creator.sh -o nvidia-rt.img -b jetson-agx-xavier-devkit -d SD
        sudo ./create-jetson-nano-sd-card-image.sh -o jetson_nano.img -s 12G -r 100

- Set AGX Xavier at Recovery Mode and directly flash image to Xavier's onboard EMMC

	    cd tools
        sudo ./flash.sh jetson-agx-xavier-devkit mmcblk0p1
