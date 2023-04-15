---
title: "代理折腾记录 - NAS局域网代理"
date: 2022-12-15T19:07:27Z
draft: false
tags: ["proxy", "setup", "caddy", "trojan-go"]
series: ["Proxy"]
categories: ["Setup"]
---

# NAS局域网代理  
1. 局域网内部分设备无法安装trojan客户端，只能配置http或者socks代理，考虑到功耗，暂由NAS长期打开trojan客户端，再向局域网提供socks代理，其他设备设置代理服务器为NAS的IP地址，端口1080。由privoxy提供http代理，端口8118。  
1. 在NAS上新建2个文件夹和文件  
    /home/config/trojan-go/client.json
    内容如上一节  
    /home/config/privoxy/config  
    ```json
    forward-socks5   /               0.0.0.0:1080 .
    listen-address 0.0.0.0:8118
    ```
1. 拉起2个容器  
    `p4gefault-trojan-go`  
    `vimagick-privoxy`  
    拉起时使用与DockerHost相同的网络，根据Entrypoint确定默认配置文件路径，各自映射配置文件  
    `/home/config/trojan-go/client.json` => `/etc/trojan-go/config.json`  
    `/home/config/privoxy/config` => `/etc/privoxy/config`  
1. 局域网设备设置代理服务器为NAS
    比如我的NAS地址固定为192.168.0.5   
    `socks5  192.168.0.5  1080`  
    `http  192.168.0.5 8118`  
1. 如果想让非本机设备使用代理，设置绑定地址local_addr时应该设置成0.0.0.0  
1. 最好在路由器中绑定NAS的ip地址，要不然每次NAS重启，配置都要变  