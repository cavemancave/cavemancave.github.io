---
title: "Jetson Orin NX Jetpack 6.1 安装 Intel WiFi 驱动"
date: 2026-06-02T10:00:00+08:00
draft: false
tags: ["jetson", "jetpack", "wifi", "driver", "intel"]
categories: ["Setup"]
---

## 环境信息

- 硬件: Jetson Orin NX
- 系统: Jetpack 6.1
- WiFi 模块: Intel 8265
- Linux 内核: 5.15.148-tegra
- Host PC: Ubuntu 22.04 x86_64

## 问题现象

Jetson 刷入 Jetpack 6.1 系统后，系统无法识别无线网卡，WiFi 设备不可见。

### 1. 网络接口检查

```bash
# No wifi releated link info

taishan@jetson:~$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN mode DEFAULT group default qlen 10
    link/can 
3: enP8p1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 48:b0:2d:eb:29:da brd ff:ff:ff:ff:ff:ff
4: l4tbr0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 3e:c7:e7:79:f3:87 brd ff:ff:ff:ff:ff:ff
5: usb0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master l4tbr0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 92:59:c4:3a:b3:71 brd ff:ff:ff:ff:ff:ff
6: usb1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master l4tbr0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 92:59:c4:3a:b3:73 brd ff:ff:ff:ff:ff:ff
```

结果仅包含本地回环、CAN 设备、以太网和 USB 设备，未见无线网卡接口。

### 2. network-manager 设备列表

```bash
# No wifi releated info
taishan@jetson:~$ nmcli device
DEVICE    TYPE      STATE      CONNECTION         
enP8p1s0  ethernet  connected  Wired connection 1 
l4tbr0    bridge    unmanaged  --                 
can0      can       unmanaged  --                 
usb0      ethernet  unmanaged  --                 
usb1      ethernet  unmanaged  --                 
lo        loopback  unmanaged  --                 
```

结果显示无线设备不存在。

### 3. rfkill 状态

```bash
# No rfkill block info
taishan@jetson:~$ rfkill list
0: hci0: Bluetooth
    Soft blocked: no
    Hard blocked: no
```

结果仅包含蓝牙设备，没有无线或硬件屏蔽信息。

### 4. iwlwifi 模块检查

```bash
# No iwlwifi module loaded 
taishan@jetson:~$ modinfo iwlwifi
modinfo: ERROR: Module iwlwifi not found.

# Manual load also failed 
taishan@jetson:~$ sudo modprobe iwlwifi
modprobe: ERROR: ../libkmod/libkmod-module.c:838 kmod_module_insert_module() could not find module by name='iwlwifi'
modprobe: ERROR: could not insert 'iwlwifi': Unknown symbol in module, or unknown parameter (see dmesg)
```

系统提示未找到模块，并且手动加载失败。

### 5. 内核配置检查

```bash
taishan@jetson:~$ zcat /proc/config.gz | grep IWLWIFI
# CONFIG_IWLWIFI is not set
```

结果显示 `CONFIG_IWLWIFI` 未启用。

### 6. 额外尝试

```bash
taishan@jetson:~$ sudo apt install linux-firmware
taishan@jetson:~$ sudo reboot
```

尝试安装 `linux-firmware` 后重启，问题仍然存在。

## 问题定位

从上述检查可知，系统本身已识别 PCI 设备，但无线驱动模块未编译或未启用，导致 `iwlwifi` 模块不可用。

因此，本次问题不是固件缺失，而是 Jetpack 6.1 默认内核配置未启用 Intel WiFi 驱动。

## 解决方案：编译并安装 iwlwifi 模块

### 1. 准备编译环境

```bash
mkdir -p ~/code/jetson
```

### 2. 获取 Jetson Linux 源码包

如果通过 SDK Manager 下载了 Jetson Linux，源码包通常已经存在：

```bash
cd ~/Downloads/nvidia/sdkm_downloads
ls
```

复制 Jetson Linux 包到工作目录：

```bash
cp Jetson_Linux_R36.4.0_aarch64.tbz2 ~/code/jetson/
cd ~/code/jetson
tar -xvf Jetson_Linux_R36.4.0_aarch64.tbz2
```

### 3. 同步内核源码

```bash
sudo apt install git-core build-essential bc
cd Linux_for_Tegra/source
./source_sync.sh -k -t jetson_36.4
```

### 4. 准备交叉编译工具链

参考 Jetson Linux 36.4 归档页面下载 Bootlin GCC 工具链：

```bash
# 官方链接有时会跳转到最新版本，建议使用以下链接下载对应版本：
# https://developer.nvidia.com/embedded/jetson-linux-archive -> 36.4
# https://developer.nvidia.com/embedded/jetson-linux-r3640 -> Bootlin Toolchain gcc 11.3
mkdir -p ~/l4t-gcc
cd ~/l4t-gcc
cp ~/Downloads/nvidia/sdkm_downloads/aarch64--glibc--stable-2022.08-1.tar.bz2 ./
tar xf aarch64--glibc--stable-2022.08-1.tar.bz2
export CROSS_COMPILE=$HOME/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
echo $CROSS_COMPILE
```

### 5. 安装必要依赖

```bash
sudo apt install -y build-essential bc flex bison libssl-dev libncurses5-dev libelf-dev dwarves rsync python3 cpio kmod
```

### 6. 启用 Intel WiFi 模块配置

`CONFIG_IWLWIFI` 用于构建 Intel 无线网卡通用驱动，负责与硬件交互和基本固件加载。
`CONFIG_IWLMVM` 用于启用 Intel MVM（Multi-Video Manager）固件支持，当前 Intel 8265 设备需要该子模块进行无线 MAC/PHY 管理。

进入内核源目录并修改配置：

```bash
cd ~/code/jetson/Linux_for_Tegra/source/
cd kernel/kernel-jammy-src/
./scripts/config --file "arch/arm64/configs/defconfig" --module CONFIG_IWLWIFI
./scripts/config --file "arch/arm64/configs/defconfig" --module CONFIG_IWLMVM
```

### 7. 编译 iwlwifi 模块

```bash
cd ~/code/jetson/Linux_for_Tegra/source/
make -C kernel
```

编译过程应生成以下目标：

- `drivers/net/wireless/intel/iwlwifi/iwlwifi.ko`
- `drivers/net/wireless/intel/iwlwifi/mvm/iwlmvm.ko`

示例输出：

```bash
Making kernel-jammy-src sources
  CC [M]  drivers/net/wireless/intel/iwlwifi/iwlwifi.mod.o
  LD [M]  drivers/net/wireless/intel/iwlwifi/iwlwifi.ko
  CC [M]  drivers/net/wireless/intel/iwlwifi/mvm/iwlmvm.mod.o
  LD [M]  drivers/net/wireless/intel/iwlwifi/mvm/iwlmvm.ko
Kernel Image: /home/taishan/code/jetson/Linux_for_Tegra/source/kernel/kernel-jammy-src/arch/arm64/boot/Image
Kernel sources compiled successfully.
```

### 8. 校验生成的模块版本

```bash
modinfo drivers/net/wireless/intel/iwlwifi/iwlwifi.ko | grep vermagic
```

输出应包含当前 Jetson 内核版本 `5.15.148-tegra`。

### 9. 拷贝模块到 Jetson 设备

```bash
scp drivers/net/wireless/intel/iwlwifi/iwlwifi.ko jetson:/tmp/
scp drivers/net/wireless/intel/iwlwifi/mvm/iwlmvm.ko jetson:/tmp/
```

### 10. 安装模块并加载

```bash
sudo mkdir -p /lib/modules/5.15.148-tegra/kernel/drivers/net/wireless/intel/iwlwifi/mvm
sudo cp /tmp/iwlwifi.ko /lib/modules/5.15.148-tegra/kernel/drivers/net/wireless/intel/iwlwifi/
sudo cp /tmp/iwlmvm.ko /lib/modules/5.15.148-tegra/kernel/drivers/net/wireless/intel/iwlwifi/mvm/
sudo depmod -a
sudo modprobe iwlwifi
```

## 调试结果

加载模块后，`dmesg` 输出如下：

```bash
dmesg | grep iwl
[51227.126836] iwlwifi: module verification failed: signature and/or required key missing - tainting kernel
[51227.130511] iwlwifi 0001:01:00.0: Adding to iommu group 3
[51227.130815] iwlwifi 0001:01:00.0: enabling device (0000 -> 0002)
[51227.137385] iwlwifi 0001:01:00.0: loaded firmware version 36.ca7b901d.0 8265-36.ucode op_mode iwlmvm
[51227.164430] iwlwifi 0001:01:00.0: Detected Intel(R) Dual Band Wireless AC 8265, REV=0x230
[51227.223855] iwlwifi 0001:01:00.0: base HW address: ac:82:47:31:c9:1e
[51227.299299] ieee80211 phy0: Selected rate control algorithm 'iwl-mvm-rs'
[51227.312550] iwlwifi 0001:01:00.0 wlP1p1s0: renamed from wlan0
```

说明 `iwlwifi` 驱动已经成功加载。

后续验证命令及结果如下：

```bash
sudo ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN mode DEFAULT group default qlen 10
    link/can
3: enP8p1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 48:b0:2d:eb:29:da brd ff:ff:ff:ff:ff:ff
4: l4tbr0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 3e:c7:e7:79:f3:87 brd ff:ff:ff:ff:ff:ff
5: usb0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master l4tbr0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 92:59:c4:3a:b3:71 brd ff:ff:ff:ff:ff:ff
6: usb1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master l4tbr0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 92:59:c4:3a:b3:73 brd ff:ff:ff:ff:ff:ff
7: wlP1p1s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DORMANT group default qlen 1000
    link/ether ac:82:47:31:c9:1e brd ff:ff:ff:ff:ff:ff
```

```bash
sudo nmcli device wifi list
IN-USE  BSSID              SSID        MODE   CHAN  RATE        SIGNAL  BARS  SECURITY
        44:56:E2:74:40:12  My-WIFI-5G  Infra  149   270 Mbit/s  100     ▂▄▆█  WPA1 WPA2
```

```bash
sudo nmcli device status
DEVICE            TYPE      STATE         CONNECTION
wlP1p1s0          wifi      disconnected  --
p2p-dev-wlP1p1s0  wifi-p2p  disconnected  --
enP8p1s0          ethernet  unavailable   --
l4tbr0            bridge    unmanaged     --
can0              can       unmanaged     --
usb0              ethernet  unmanaged     --
usb1              ethernet  unmanaged     --
lo                loopback  unmanaged     --
```

以上结果说明无线设备已被识别并可以扫描到 WiFi 信号。

## 结论

本次问题的根因是 Jetpack 6.1 默认内核配置未启用 Intel WiFi 驱动。通过同步源码、启用 `CONFIG_IWLWIFI` 和 `CONFIG_IWLMVM` 配置，并重新编译内核模块，最终成功恢复无线网络功能。

## 参考

- [Bilibili — 探索不倦：Jetson 内核编译](https://www.bilibili.com/video/BV1To1RYpE5r/?spm_id_from=333.1391.0.0&vd_source=19688293352d56a337de6fd06be07c7f)
 - [NVIDIA — Jetson Linux 36.4 内核定制说明](https://docs.nvidia.com/jetson/archives/r36.4/DeveloperGuide/SD/Kernel/KernelCustomization.html)
 - [NVIDIA — Jetson Linux 归档页面](https://developer.nvidia.com/embedded/jetson-linux-archive)
 - [NVIDIA — Jetson Linux R36.4 工具链页面](https://developer.nvidia.com/embedded/jetson-linux-r3640)
