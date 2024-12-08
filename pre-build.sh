#!/bin/bash

# Red is 1
# Green is 2
# Reset is sgr0 

tput setaf 2
echo "Install Dependencies"
tput sgr0
sudo apt update && sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install -y build-essential bc libncurses5-dev lbzip2 pkg-config flex bison libssl-dev qemu-user-static

BUILD_DIR=~/RTJetsonBuild/R36.4.0
tput setaf 2
echo "Create build folder to $BUILD_DIR"
tput sgr0
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p $BUILD_DIR
fi
cd $BUILD_DIR

tput setaf 2
echo "Manually download files from links below since NVIDIA's website need login..."
echo "https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2"
echo "https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/release/Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2"
echo "https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/sources/public_sources.tbz2"
echo "https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/toolchain/aarch64--glibc--stable-2022.08-1.tar.bz2"
echo "and put them into $BUILD_DIR folder"
tput sgr0
