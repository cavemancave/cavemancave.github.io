---
title: "OpenWrt恢复"
date: 2024-05-13T17:07:27Z
draft: false
tags: ["openwrt", "setup", "git"]
series: ["Proxy"]
categories: ["Setup"]
---
参考https://openwrt.org/docs/guide-user/troubleshooting/failsafe_and_factory_reset

启动时指示灯有三种状态：

黄色常亮bootbloader

黄色快闪（1秒5次） 等待输入

如果按下reset， 进入了failsafe模式，闪更快（1秒10次）

如果没按下，进入正常启动，闪更慢（1秒2次）

所以我在快闪的时候按了reset键，然后进入了failsafe模式，然后找根网线连接lan口和电脑，手动设置电脑ip为192.168.1.2， 然后ssh root@192.168.1.1，然后就进去了，然后执行firstboot，再reboot

然后等好几分钟，等待重启

然后网页就可以登录192.168.1.1了。

然后Network->Interfaces-可以看到LAN接口的Mac 地址，到上一级的路由器中配置固定的ip地址192.168.0.8。



然后Network->Interfaces->LAN->General Settings 页中的 Protocol 改成DHCP client, DHCP Server 页中的General Setup 中的IgnoreInterface 勾上，然后应用修改重启。

然后再登录192.168.0.8 就可以继续配置wifi了