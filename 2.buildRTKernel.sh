#!/bin/bash

# Red is 1
# Green is 2
# Reset is sgr0

BUILD_DIR=~/RTJetsonBuild/R36.3.0
cd $BUILD_DIR

tput setaf 2
echo "Extract files"
tput sgr0
sudo tar xpf Jetson_Linux_R36.3.0_aarch64.tbz2
cd Linux_for_Tegra/rootfs/
sudo tar xpf ../../Tegra_Linux_Sample-Root-Filesystem_R36.3.0_aarch64.tbz2
cd ../../
tar -xvf aarch64--glibc--stable-2022.08-1.tar.bz2
sudo tar -xjf public_sources.tbz2
tar -xjf Linux_for_Tegra/source/kernel_src.tbz2

tput setaf 2
echo "Apply PREEMPT-RT patches"
tput sgr0
sudo ./generic_rt_build.sh enable

tput setaf 2
echo "Compile kernel"
tput sgr0
TEGRA_KERNEL_OUT=kernel_out
mkdir $TEGRA_KERNEL_OUT
export CROSS_COMPILE=$BUILD_DIR/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
cd kernel/kernel-jammy-src
make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig

tput setaf 2
echo "Confirm if these config options are chosen."
echo "General setup -> Preemption Model (Fully Preemptible Kernel (Real-Time))"
echo "Kernel Features -> Timer frequency: 1000 HZ "
echo "If not, choose them in menuconfig interface."
echo "Else, quit menuconfig and compile will auto start."
echo "Press Return Key to continue........"
tput sgr0
read
make ARCH=arm64 O=$TEGRA_KERNEL_OUT menuconfig
make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j$(nproc)

tput setaf 2
echo "Copying results"
tput sgr0
sudo cp kernel_out/arch/arm64/boot/Image $BUILD_DIR/Linux_for_Tegra/kernel/Image
sudo cp kernel_out/arch/arm64/boot/Image.gz $BUILD_DIR/Linux_for_Tegra/kernel/Image.gz
sudo cp -r kernel_out/arch/arm64/boot/dts/nvidia/* $BUILD_DIR/Linux_for_Tegra/kernel/dtb/
sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=$BUILD_DIR/Linux_for_Tegra/rootfs/
cd $BUILD_DIR/Linux_for_Tegra/rootfs/
sudo tar --owner root --group root -cjf kernel_supplements.tbz2 lib/modules
sudo mv kernel_supplements.tbz2  ../kernel/

tput setaf 2
echo "Appling binaries"
tput sgr0
cd ..
sudo ./apply_binaries.sh
