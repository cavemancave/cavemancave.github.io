---
title: "代理折腾记录 - 总"
date: 2022-12-15T13:07:27Z
draft: false
tags: ["proxy", "setup", "caddy", "trojan-go"]
series: ["Proxy"]
categories: ["Setup"]
---

# 简介
记录本次设置代理的过程。  
本次采用Trojan-go + Caddy的方案。Shadowsocks太容易识别，IP已经被封一次，Vray的自研Vmess感觉以后也会被识别，Trojan-go伪装成https网页访问，听起来伪装性更好，不过没看到如何预防流量重放。Caddy配置简单，自动申请证书也很赞。  
计划服务端和客户端都使用容器，这样对环境的污染最小，备份一份compose.yaml和代理配置文件夹即可。  
目前在NAS上长期运行着代理客户端，并向局域网提供socks和http代理，局域网内部分设备设置代理服务器为NAS地址，经NAS代理出海。  
计划测试自动代理配置，不过听说有签名问题，待研究  

[代理折腾记录 - caddy]({{< ref "/posts/2022-12-15-Setup_Proxy_caddy" >}})  
[代理折腾记录 - trojan-go服务端]({{< ref "/posts/2022-12-15-Setup_Proxy_trojan-go-server" >}})  
[代理折腾记录 - trojan-go客户端]({{< ref "/posts/2022-12-15-Setup_Proxy_trojan-go-client" >}})  
[代理折腾记录 - trojan-go调试]({{< ref "/posts/2022-12-15-Setup_Proxy_trojan-go-debug" >}})  
[代理折腾记录 - NAS局域网代理]({{< ref "/posts/2022-12-15-Setup_Proxy_NAS" >}})  
