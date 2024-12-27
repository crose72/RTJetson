#!/bin/bash

# Red is 1
# Green is 2
# Reset is sgr0

BUILD_DIR=/home/<user>/jp61/R36.4.0
TOOLCHAIN_DIR=<path-to-toolchain>/aarch64--glibc--stable-2022.08-1

# Check and create BUILD_DIR if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
fi

# Check and create TOOLCHAIN_DIR if it doesn't exist
if [ ! -d "$TOOLCHAIN_DIR" ]; then
    echo "Creating toolchain directory: $TOOLCHAIN_DIR"
    mkdir -p "$TOOLCHAIN_DIR"
fi

echo "Copy the required files to the folder: $BUILD_DIR"
read -p "Press Enter to continue after copying the files..."

cd $BUILD_DIR

# Unzip source files and prepare rootfs
# For now I already have it unzipped
# tar -xvf aarch64--glibc--stable-2022.08-1.tar.bz2
ls
tar xpf Jetson_Linux_R36.4.0_aarch64.tbz2
sudo tar xpf Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2 -C Linux_for_Tegra/rootfs/
cd Linux_for_Tegra/
sudo ./tools/l4t_flash_prerequisites.sh
sudo ./apply_binaries.sh

# cd $BUILD_DIR/Linux_for_Tegra/source
# ./source_sync.sh -k -t r36.4
cd $BUILD_DIR
tar xf public_sources.tbz2 -C $BUILD_DIR/Linux_for_Tegra/..
cd $BUILD_DIR/Linux_for_Tegra/source
tar xf kernel_src.tbz2
tar xf kernel_oot_modules_src.tbz2
tar xf nvidia_kernel_display_driver_source.tbz2

cd $BUILD_DIR/Linux_for_Tegra/source/kernel/kernel-jammy-src
echo "Ensure the following options are chosen in menuconfig:"
echo "1. General setup -> Preemption Model (Fully Preemptible Kernel (Real-Time))"
echo "2. Kernel Features -> Timer frequency: 1000 HZ"
echo "Enter menuconfig to check and modify these settings. Press Enter to continue..."
read
make ARCH=arm64 O=$BUILD_DIR menuconfig
make ARCH=arm64 O=$BUILD_DIR -j$(nproc)

# Building the RT kernel
cd $BUILD_DIR/Linux_for_Tegra/source
./generic_rt_build.sh "enable"

export CROSS_COMPILE=$TOOLCHAIN_DIR/bin/aarch64-buildroot-linux-gnu-
make -C kernel

export INSTALL_MOD_PATH=$BUILD_DIR/Linux_for_Tegra/rootfs/
sudo -E make install -C kernel
cp kernel/kernel-jammy-src/arch/arm64/boot/Image \
  $BUILD_DIR/Linux_for_Tegra/kernel/Image

# Building the NVIDIA Out-of-Tree Modules

cd $BUILD_DIR/Linux_for_Tegra/source

export IGNORE_PREEMPT_RT_PRESENCE=1

export KERNEL_HEADERS=$PWD/kernel/kernel-jammy-src
make modules

sudo -E make modules_install

cd $BUILD_DIR/Linux_for_Tegra
sudo ./tools/l4t_update_initrd.sh

# Building the DTBs

cd $BUILD_DIR/Linux_for_Tegra/source

make dtbs

cp kernel-devicetree/generic-dts/dtbs/* $BUILD_DIR/Linux_for_Tegra/kernel/dtb/