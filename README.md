# RT Jetson

Preempt-RT Kernel Build Guide for NVIDIA Development Board

The system used to build the image is Ubuntu 22.04.6 LTS (also works on Ubuntu 20.04 LTS), which is recommended because the current version of L4T is based on Ubuntu 20.04.

- Jetpack version: 6.1
- Jetson Linux version: 36.4.0
- Linux Kernel version: 5.15
- GCC Toolchain: 11.3

This guide and this [Reference](https://forums.developer.nvidia.com/t/preempt-rt-patches-for-jetson-nano/72941/10) only tested on the Xavier developer kit and Jetson Nano development board.

Since L4T and related source codes are common to all NVIDIA development boards, so this tutorial is theoretically applicable to all NVIDIA development boards supported by L4T.

The only thing to note is that a specific version of L4T and related source codes only support the development platforms supported by this version of L4T, and cross-version hardware support is hard to guarantee.

**Modify the $BUILD_DIR Parameter in the two scripts before you use them if you need a different Build Path other than ~/RTJetsonBuild.**

## Download the following files in the nvidia-rt folder:

The source files can be found at [Jetson-Linux-Archive](https://developer.nvidia.com/embedded/jetson-linux-archive).  Clickable links can be found below as well.

- [L4T Jetson Driver Package](https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2)

- [L4T Sample Root File System](https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/release/Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2)

- [L4T Sources](https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v4.0/sources/public_sources.tbz2)

- [GCC Tool Chain for 64-bit BSP](https://developer.download.nvidia.cn/embedded/L4T/r36_Release_v3.0/toolchain/aarch64--glibc--stable-2022.08-1.tar.bz2)

## Building the PREEMPT_RT kernel

The script is based on the instructions at [Quickstart](https://docs.nvidia.com/jetson/archives/r36.4/DeveloperGuide/IN/QuickStart.html#to-flash-the-jetson-developer-kit-operating-software) and [Kernel Customization](https://docs.nvidia.com/jetson/archives/r36.4/DeveloperGuide/SD/Kernel/KernelCustomization.html#kernel-customization).

Create a build folder.
- `mkdir ~/jp61`

Go to build folder.
- `cd ~/jp61`

Unzip the toolchain to your build folder or desired location.
- `tar -xvf aarch64--glibc--stable-2022.08-1.tar.bz2`

Copy the source files (`Jetson_Linux_R36.4.0_aarch64.tbz2`, `public_sources.tbz2`, `Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2`, `aarch64--glibc--stable-2022.08-1.tar.bz2`) into the build folder if they are not already there.

Update `buildRTKernel.sh` so that `BUILD_DIR` points to the location of `Jetson_Linux_R36.4.0_aarch64.tbz2`, `public_sources.tbz2`, - `Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2`, `aarch64--glibc--stable-2022.08-1.tar`, and `TOOLCHAIN_DIR` points to the location of the unzipped `aarch64--glibc--stable-2022.08-1`.

Execute `buildRTKernel.sh` script and follow the instructions.  
- If the build folder doesn't exist then the script will create it.

