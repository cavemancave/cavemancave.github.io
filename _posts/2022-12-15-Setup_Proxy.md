---
layout: single
title:  "Setup proxy"
date:   2022-12-15 17:39:53 +0800
categories: proxy
---

[TOC]

# 简介
记录本次设置代理的过程  

# 服务器  
1. 准备一个VPS，ip地址12.345.345.345  
2. 申请域名abc.com，新增一条A记录  
`A	www	12.345.345.345	600`  

# Caddy配置  
登陆VPS，新建Caddyfile, 在端口1234上拉起https服务  
```txt
cat Caddyfile 
www.abc.com:1234 {
	encode zstd gzip
	file_server
}
www.abc.com:80 {
	encode zstd gzip
	file_server
}
```
访问https://www.abc.com:1234，应该成功  
访问http://www.abc.com:80，应该成功  
访问https://www.abc.com，应该失败  

# trojan-go 配置  
/root/compose.yaml  
```yaml
services:
  trojan-go:
    image: "p4gefau1t/trojan-go"
    container_name: trojan-go
    network_mode: host
    volumes:
      - /root:/root/
      - /root/trojan-go:/etc/trojan-go
```
`docker compose up `   

/root/trojan-go/config.json  
```json
{
    "run_type": "server",
    "local_addr": "www.abc.com",
    "local_port": 443,
    "remote_addr": "www.abc.com",
    "remote_port": 80,
    "password": [
        "your_password"
    ],
    "ssl": {
        "cert": "/root/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/www.abc.com/www.abc.com.crt",
        "key": "/root/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/www.abc.com/www.abc.com.key",
	"fallback_port": 1234
    },
    "router": {
        "enabled": true,
        "block": [
            "geoip:private"
        ],
        "geoip": "/root/trojan-go/geoip.dat",
        "geosite": "/root/trojan-go/geosite.dat"
    }
}
```
访问https://www.abc.com，应该成功显示网页  

# 客户端

```json
 config.json 
{
    "log_file": "trojan-go.log",
    "run_type": "client",
    "local_addr": "0.0.0.0",
    "local_port": 1080,
    "remote_addr": "www.abc.com",
    "remote_port": 443,
    "password": [
        "your_password"
    ],
    "ssl": {
        "sni": ""
    },
    "mux": {
        "enabled": true
    },
    "router": {
        "enabled": false,
        "bypass": [
            "geoip:cn",
            "geoip:private",
            "geosite:cn",
            "geosite:private"
        ],
        "block": [
            "geosite:category-ads"
        ],
        "proxy": [
            "geosite:geolocation-!cn"
        ],
        "default_policy": "proxy",
        "geoip": "geoip.dat",
        "geosite": "geosite.dat"
    }
}
```

http_proxy="socks5://127.0.0.1:1080"; curl www.google.com  

# NAS  
新建2个文件夹  
/home/config/trojan-go/config.json  
/home/config/privoxy/config.json  
```json
forward-socks5   /               0.0.0.0:1080 .
listen-address 0.0.0.0:8118
```
拉起2个容器  
拉起时映射2个文件  
/home/config/trojan-go/config.json -> /etc/trojan-go/config.json  
/home/config/privoxy/config.json -> /etc/privoxy/config.json  

局域网代理都可以指向NAS  
socks5  192.168.0.5  1080  
http  192.168.0.5 8118  

# 调试
lsof -i :443 查看端口占用，杀掉进程  