---
toc: true
toc_sticky: true
layout: single
title: 环境准备：在WSL2上开发ESP32
date:   2022-03-26 17:39:53 +0800
categories: blog
description: 环境准备：在WSL2上开发ESP32。
keywords: esp32, environment, wsl, usbip, usb-serial
---

记录在wsl2上编译、烧录esp32程序，准备开发环境的过程
大致分为三部分：

1. wsl2 使能USB/IP特性
2. 安装cp120x驱动
3. USB串口使用
 
# ESP32 Development on WSL2 
win11 wsl-5.10.60.1 have firstly support usbip feature, it can attach usb device to wsl. The offical post [Connecting USB devices to WSL](https://devblogs.microsoft.com/commandline/connecting-usb-devices-to-wsl/) has a brief introduction.  

## Get latest kernel
1. [Building your own USB/IP enabled WSL 2 kernel](https://github.com/dorssel/usbipd-win/wiki/WSL-support#building-your-own-usbip-enabled-wsl-2-kernel) have a clear instruction. Or get latest kernel through updates by steps blow.   
2. Install Windows 11, open Windows Update – join Windows Insider Program (Beta channel) – install updates, reboot machine  
3. Windows Update – Advanced Options – check the option “Receive updates for other Microsoft products” – Back – Check for updates  
4. Reboot or shutdown WSL2 images  
5. start a new WSL2 image e.g. with Ubuntu 20 LTS, check that you have kernel 5.10: uname -a. It does not work on 4.x kernel from normal WSL2  

## Attach usb to wsl2
1. install https://github.com/dorssel/usbipd-win/releases on Windows  
2. in Linux – `sudo apt install linux-tools-5.4.0-77-generic hwdata`  
3. in Linux – `visudo`  
4. in Linux – prepend path Defaults secure_path=”/usr/lib/linux-tools/5.4.0-77-generic:  
5. connect ESP device with FTDI in Windows PowerShell (administrator) type: `usbipd wsl list`  
6. search for 5-3 Silicon Labs CP210x USB to UART Bridge Not attached  
7. type in Windows: `usbipd wsl attach -b 5-3 -d Ubuntu`  
8. type in Linux: `lsusb` can see   Silicon Labs CP210x UART Bridge

## Install cp120x dirver on wsl2.
some board don't need this step. My board usb serial chip is cp1202, and the dirver need to installed manully. Main referenced from  [Building your own USB/IP enabled WSL 2 kernel](https://github.com/dorssel/usbipd-win/wiki/WSL-support#building-your-own-usbip-enabled-wsl-2-kernel)  
```bash
# Update resources and Install prerequisites
sudo apt update
sudo apt upgrade
sudo apt install build-essential flex bison libssl-dev libelf-dev libncurses-dev autoconf libudev-dev libtool

# Clone kernel that matches wsl version
uname -r
git clone https://github.com/microsoft/WSL2-Linux-Kernel.git
cd WSL2-Linux-Kernel
git checkout linux-msft-wsl-5.10.60.1

# Copy current configuration file
cp /proc/config.gz config.gz
gunzip config.gz
mv config .config

# enable usb serial features
sudo make menuconfig
# Device Drivers -> USB support -> USB Serial Converter support -> USB Serial Console device support + USB Generic Serial Driver + USB CP210x family of UART Bridge Controllers
sudo make -j 8 && sudo make modules_install -j 8 && sudo make install -j 8
cp arch/x86/boot/bzImage /mnt/c/Users/<user>/usbip-bzImage

# Create .wslconfig file and add a reference to the created image with the following notes
vi /mnt/c/Users/<user>/.wslconfig
# [wsl2]
# kernel=c:\\users\\<user>\\usbip-bzImage
```
reboot system

## Connect ttyUSB device
After attached usb to wsl, you can use `dmesg` command to determine whether the driver works. The correct echo should look like this:
```txt
[ 1309.073610] usb 1-1: new full-speed USB device number 2 using vhci_hcd
[ 1309.153533] vhci_hcd: vhci_device speed not set
[ 1309.223539] usb 1-1: SetAddress Request (2) to port 0
[ 1309.290634] usb 1-1: New USB device found, idVendor=10c4, idProduct=ea60, bcdDevice= 1.00
[ 1309.290638] usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[ 1309.290641] usb 1-1: Product: CP2102 USB to UART Bridge Controller
[ 1309.290711] usb 1-1: Manufacturer: Silicon Labs
[ 1309.290714] usb 1-1: SerialNumber: 0001
[ 1309.301652] cp210x 1-1:1.0: cp210x converter detected
[ 1309.308748] usb 1-1: cp210x converter now attached to ttyUSB0
```
The last line indicates the corresponding serial port device name ttyUSB0.  
My environment still have permission problems, and I solved them with reference to  [Cannot open /dev/ttyUSB0: Permission denied](https://github.com/esp8266/source-code-examples/issues/26#issuecomment-706129191)  
```bash
sudo su
//type your password
cd /
cd dev
chown username ttyUSB0
```
Finally I can communicate with esp32.
```
cd examples/get-started/blink
idf.py build flash monitor
```

If an error occurs in the process, it may be solved by restarting the system.
