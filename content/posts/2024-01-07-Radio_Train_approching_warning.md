---
title: "列车接近预警"
date: 2024-01-07T10:07:27+08:00
draft: false
tags: ["radio", "ham", "sdr", "train"]
series: ["Radio"]
categories: ["Radio"]
---

## 相关知识
新购入[rtl-sdr v4][], 测试一下接收列车接近预警。<br>
先看下国家标准：[《TB/T 3504-2018 列车接近预警地面设备》][], 第9章提到有2个信道：接近预警信道和报警信道，接近预警信道使用的是POGSAG编码 调制DFSK(差分频移键控）速率1200bps, 不过没提到具体频率。<br>
从B站视频和其他列车频率表中可以找到接近预警信道使用频率为821.2375MHz，报警信道使用频率为866.2375MHz。官方的参考资料只在[《北京世纪东方智汇科技股份有限公司 公开转让说明书》][] 1-1-138中提到一句:<br>
>2006 年工业和信息化部发布《关于同意铁道部列车安全预警系统使用频率的函》（信部无函（2006）35 号），同意在全国铁路范围内运用的行车车辆安全预警系统使用821.2375/866.2375MHz 频率。

## 安装SDRSharp

## 安装POGSAG插件
[Dustify/SdrSharpPocsagPlugin][]<br>

## 安装天线
参考[天线工作原理以及如何计算天线长度][], 天线长度大概在0.09m，参考[USING OUR NEW DIPOLE ANTENNA KIT][]，基座相当于2cm天线，使用2节的小天线，拉伸到7cm，大概可以在821MHz共振。<br>

## 解码
不知道是不是接收位置不太好，高铁预警不太能接收到，慢速的货车能够清晰的接收到。57828是列车编号，41是速度，2102是公里标。<br> 

![img 1](/images/blog/2024-01-07-pocsagdecoder.png)

## 参考
[rtl-sdr v4]: https://www.rtl-sdr.com/v4/ "rtl-sdr v4"
[《TB/T 3504-2018 列车接近预警地面设备》]: https://hbba.sacinfo.org.cn/attachment/onlineRead/5904054c34efe2dd71e9d44c009bb725
[《北京世纪东方智汇科技股份有限公司 公开转让说明书》]: https://www.neeq.com.cn/disclosure/2022/2022-08-15/1660534210_098980.pdf
[Dustify/SdrSharpPocsagPlugin]: https://github.com/Dustify/SdrSharpPocsagPlugin
[USING OUR NEW DIPOLE ANTENNA KIT]: https://www.rtl-sdr.com/using-our-new-dipole-antenna-kit/ "使用我们全新的偶极子天线套件"
[天线工作原理以及如何计算天线长度]: https://blog.csdn.net/dxy0219/article/details/122856027
