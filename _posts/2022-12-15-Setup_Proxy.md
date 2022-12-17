---
layout: single
title:  "代理折腾记录"
date:   2022-12-15 17:39:53 +0800
categories: proxy
---

[TOC]

# 简介
记录本次设置代理的过程。本次采用Trojan-go + Caddy的方案。Shadowsocks太容易识别，IP已经被封一次，Vray的自研Vmess感觉以后也会被识别，Trojan-go伪装成https网页访问，听起来伪装性更好，不过没看到如何预防流量重放。Caddy配置简单，自动申请证书也很赞。  
后续计划服务端和客户端都使用容器，这样对环境的污染最小，备份一份docker-compose.yaml和配置文件夹即可。  
目前在NAS上长期运行着代理客户端，并向局域网提供socks和http代理，局域网内部分设备设置代理服务器为NAS地址，经NAS代理出海。  
计划测试自动代理配置，不过听说有签名问题，待研究  

# 服务器  
1. 准备一个VPS，ip地址12.345.345.345  
2. 申请域名abc.com，新增一条A记录  
`A	www	12.345.345.345	600`  

# Caddy配置  
登陆VPS，找一个网站文件夹目录（可以搜索网站模板），新建Caddyfile, 在端口1234上拉起https服务  
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
1. 查找Caddy申请的证书文件，*.crt/*.key  
2. 创建配置文件  
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
3. 创建容器配置  
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
4. 执行`docker compose up `拉起容器   
5. 访问https://www.abc.com，应该成功显示网页  

# 客户端
1. 客户端配置文件
本地电脑  
/root/trojan-go/config.json 
```json
{
    "log_file": "",
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
注意，如果想让局域网都可以使用socks代理，监听地址需要设置成0.0.0.0  
2. 测试连接
http_proxy="socks5://127.0.0.1:1080"; curl www.google.com  

# NAS局域网代理  
1. 局域网内部分设备无法安装trojan客户端，只能配置http或者socks代理，考虑到功耗，暂由NAS长期打开trojan客户端，再向局域网提供socks代理，其他设备设置代理服务器为NAS的IP地址，端口1080。由privoxy提供http代理，端口8118。  
2. 新建2个文件夹  
/home/config/trojan-go/config.json
内容如上一节  
/home/config/privoxy/config.json  
```json
forward-socks5   /               0.0.0.0:1080 .
listen-address 0.0.0.0:8118
```
3. 拉起2个容器  
p4gefault-trojan-go
vimagick-privoxy
拉起时使用与DockerHost相同的网络，根据Entrypoint确定默认配置文件路径，各自映射配置文件  
/home/config/trojan-go/config.json -> /etc/trojan-go/config.json  
/home/config/privoxy/config.json -> /etc/privoxy/config.json  
4. 局域网设备设置代理服务器为NAS
socks5  192.168.0.5  1080  
http  192.168.0.5 8118  

# 调试
lsof -i :443 查看端口占用，杀掉进程  
通过log_file字段配置log文件，不带路径的话，就在容器根目录下，可以进容器查看。不过日志会不停增大，只在调试时打开  
```bash
taishan@taishanNAS:~$ sudo docker ps
Password:
CONTAINER ID   IMAGE                        COMMAND                  CREATED       STATUS        PORTS     NAMES
4cf1d609f6e9   p4gefau1t/trojan-go:latest   "/usr/local/bin/troj…"   13 days ago   Up 24 hours             p4gefau1t-trojan-go1
taishan@taishanNAS:~$ sudo docker exec -it 4cf1d609f6e9 sh
/ # ls -l *.log
-rw-r--r--    1 root     root       1245002 Dec 17 14:11 trojan-go.log
/ # tail  trojan-go.log
[INFO]  2022/12/17 14:13:04 socks connection from 127.0.0.1:60526 metadata dauth-lp1.ndas.srv.nintendo.net:443
```
cat /proc/1/fd/1 应该可以查看stdout，不过目前测试没有输出。