---
toc: true
toc_sticky: true
layout: single
title:  "废旧安卓折腾记录-网络摄像头"
date:   2023-02-16 17:39:53 +0800
categories: android
description: OpenWrt折腾记录。
keywords: steam,android,ipcam
---

# 设备
Xiaomi Mi 6  
[LineageOS 20][1]   

# App
目前为止，测试到最好用的一个App是[Google Play - Astra Streaming Studio](https://play.google.com/store/apps/details?id=miv.astudio&hl=en_US&gl=US)  
它支持RTSP, RTMP, SRT, You Tube, Recoder 5种串流方式  
本次测试使用RTSP协议，RTSP是大部分摄像头支持的格式，[兼容更好][2]。  
设置步骤：右上角网络图标-》Add Service-》RTSP->Name: RTSP->Name: RTSP->Port:5554->OK->右上角播放图标-》左上角info图标可以看到地址192.168.0.30:5554  
本地PC安装VLC，媒体-》打开网络串流-》rtsp://192.168.0.30:5554->播放  
测试码率和帧率如下  
```txt
Xiaomi Mi 6 LineageOS 20
Video encoder: H264 1280x720 17.2 fps
Audio encoder: AAC 44kHz stereo
Encoders bitrate: 2.9 Mbps / 2.4 Mbps
Outgoing bandwidth: 2.9 Mbps
Sent data: 54.5 Mb
Duration: 2 min. 40 sec.
```
```txt
Xiaomi Mi 10 Lite Zoom MIUI 13
Video encoder: H264 1920x1080 30.2 fps
Audio encoder: AAC 44kHz stereo
Encoders bitrate: 7.7 Mbps / 6.2 Mbps
Outgoing bandwidth: 7.7 Mbps
Sent data: 47 Mb
Duration: 54 sec.
```
# Reference
[1]: <https://wiki.lineageos.org/devices/sagit/install> "LineageOS Wiki - Install LineageOS on sagit"
[2]: <https://www.gumlet.com/learn/rtsp-vs-rtmp/#:~:text=RTSP%20is%20commonly%20used%20for,stored%20and%20delivered%20when%20needed.> "gumlet - A Comprehensive Overview of RTSP vs RTMP"



# Draft
search "android camera stream"
->
https://stackoverflow.com/questions/2550847/streaming-video-from-android-camera-to-server
metioned 
  ->http://code.google.com/p/ipcamera-for-android 
  http://code.google.com/p/spydroid-ipcamera/ 
  
  ->https://github.com/Teaonly/android-eye
  
RTMP Camera
HLS

https://github.com/pedroSG94/rtmp-rtsp-stream-client-java  1.7k
https://github.com/begeekmyfriend/yasea 4.6k
