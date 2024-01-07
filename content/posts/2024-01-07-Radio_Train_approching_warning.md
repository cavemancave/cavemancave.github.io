---
title: "列车接近预警"
date: 2024-01-07T09:07:27Z
draft: false
tags: ["radio", "ham", "sdr", "train"]
series: ["Radio"]
categories: ["Radio"]
---

## 相关知识
新购入[rtl-sdr v4][], 测试一下接收列车接近预警。  
先看下国家标准：[《TB/T 3504-2018 列车接近预警地面设备》][], 里面提到使用的是POGSAG编码 调制DFSK(差分频移键控）速率1200bps, 不过没提到具体频率。  
从B站视频和其他列车频率表中可以找到列车接近预警使用频率为821.2375MHz，报警信道使用频率为866.2375MHz。官方的参考资料只在[北京世纪东方智汇科技股份有限公司 公开转让说明书1-1-138][]中提到一句
>2006 年工业和信息化部发布《关于同意铁道部列车安全预警系统使用频率的函》（信部无函（2006）35 号），同意在全国铁路范围内运用的行车车辆安全预警系统使用821.2375/866.2375MHz 频率。

## 安装SDRSharp
## 安装POGSAG插件
[Dustify/SdrSharpPocsagPlugin][]  
## 安装天线
## 解码
![img 1](/images/blog/2024-01-07-pocsagdecoder.png)  

## 参考
[rtl-sdr v4]: https://www.rtl-sdr.com/v4/
[《TB/T 3504-2018 列车接近预警地面设备》]: https://hbba.sacinfo.org.cn/attachment/onlineRead/5904054c34efe2dd71e9d44c009bb725  
[北京世纪东方智汇科技股份有限公司 公开转让说明书1-1-138]: https://www.neeq.com.cn/disclosure/2022/2022-08-15/1660534210_098980.pdf  
[Dustify/SdrSharpPocsagPlugin]: https://github.com/Dustify/SdrSharpPocsagPlugin  