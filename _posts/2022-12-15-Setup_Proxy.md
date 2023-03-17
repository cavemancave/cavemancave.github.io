---
toc: true
toc_sticky: true
layout: single
title:  "代理折腾记录"
date:   2022-12-15 17:39:53 +0800
categories: proxy
description: 代理折腾记录。
keywords: proxy,setup
---

# 简介
记录本次设置代理的过程。  
本次采用Trojan-go + Caddy的方案。Shadowsocks太容易识别，IP已经被封一次，Vray的自研Vmess感觉以后也会被识别，Trojan-go伪装成https网页访问，听起来伪装性更好，不过没看到如何预防流量重放。Caddy配置简单，自动申请证书也很赞。  
计划服务端和客户端都使用容器，这样对环境的污染最小，备份一份compose.yaml和代理配置文件夹即可。  
目前在NAS上长期运行着代理客户端，并向局域网提供socks和http代理，局域网内部分设备设置代理服务器为NAS地址，经NAS代理出海。  
计划测试自动代理配置，不过听说有签名问题，待研究  

# 服务器配置
1. 购买一个VPS，ip地址`1.2.3.4`，操作系统：Ubuntu 22.04 x86_64   
2. 购买一个域名`abc.com`  
3. 设置一条A记录  
    `A    www    1.2.3.4    600`

# 安装容器环境
```bash
sudo apt install docker docker-compose
```

# caddy配置
## 添加docker
创建/root/compose.yaml
```yaml
services:
  caddy:
    image: caddy:2
    container_name: caddy
    network_mode: host
    restart: always
    volumes:
      - /root/caddy/Caddyfile:/etc/caddy/Caddyfile
      - /root/www:/www
      - /root/caddy/cert:/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory
 ```
## 创建caddy配置文件
创建/root/caddy/Caddyfile
```txt
:80, www.abc.com {
  root * /www
  file_server
}
```
## 添加网页
创建/root/www/index.html
```html
<html>
 <head>
 </head>
 <body>
   <h1>Hello World<h1>
 </body>
</html>
```
## 启动docker
```bash
docker-compose up -d caddy
```
1. 访问 `http://www.abc.com` 应该成功打开网页
1. 访问 `https://www.abc.com` 也应该成功打开网页。  
1.  如果出错，可以通过 `docker logs caddy` 查看日志

# trojan-go配置
## 添加容器配置
/root/compose.yaml  
```yaml
  trojan-go:
    image: p4gefau1t/trojan-go
    container_name: trojan-go
    network_mode: host
    restart: always
    volumes:
      - /root/trojan-go/server.json:/etc/trojan-go/config.json
      - /root/caddy/cert/www.abc.com:/cert
```
## 添加服务端配置
 `/root/trojan-go/server.json` ，监听在端口 `1234`  
```json
{
    "run_type": "server",
    "local_addr": "www.abc.com",
    "local_port": 1234,
    "remote_addr": "www.abc.com",
    "remote_port": 80,
    "password": [
        "password"
    ],
    "ssl": {
        "cert": "/cert/www.abc.com.crt",
        "key": "/cert/www.abc.com.key",
        "fallback_port": 443
    }
}
```
## 拉起容器
1. 执行 `docker-compose up -d trojan-go` 拉起容器   
1. 访问 `https://www.abc.com:1234` 应该成功打开网页  
1. 如果出错的话，可以通过 `docker logs trojan-go` 查看docker日志  
## 服务自启动
1. docker服务是开机自启动的，但是某个容器需要开机启动的话，需要在compose.yaml中增加 `restart: always` 字段，并拉起过一次  
1. 增加字段后，重新拉起容器，再重启VPS，访问 `https://www.abc.com:1234` 应该成功打开网页  
1. 刚开始调试时，不能加上 `restart: always` 字段，否则可能会因为配置错误，反复重启，打印大量日志，也无法进入容器调试  

# trojan-go客户端配置
## linux客户端
1. 创建一个客户端配置文件`/root/trojan-go/client.json`，监听在1080端口。  
    ```json
    {
        "run_type": "client",
        "local_addr": "0.0.0.0",
        "local_port": 1080,
        "remote_addr": "www.abc.com",
        "remote_port": 1234,
        "password": [
            "password"
        ],
        "ssl": {
            "sni": "www.cavemancave.tk"
        },
        "mux" :{
            "enabled": true
        },
        "router":{
            "enabled": false
        }
    }
    ```
1. /root/compose.yaml在服务端下面增加一个客户端容器  
    ```yaml
      trojan-client:
        image: p4gefau1t/trojan-go
        container_name: trojan-client
        network_mode: host
        volumes:
          - /root/trojan-go/client.json:/etc/trojan-go/config.json
    ```
1. 拉起客户端容器 `docker-compose up -d trojan-client`  
1. 访问 google, baidu 应该成功，查看日志没有错误  
    ```bash
    curl -x "socks5://0.0.0.0:1080" -I https://www.google.com
    curl -x "socks5://0.0.0.0:1080" -I https://www.baidu.com
    docker logs trojan-client
    ```
1. 如果不在VPS上测试，而是本地测试，compose.yaml应该删除服务端的段落  
   在本地测试连接时，经常受到DNS污染，可以使用下面的命令让DNS在远端解析，避免本地DNS污染导致的连接失败
    `curl --socks5-hostname localhost:1080 www.google.com`  

## windows客户端
1. 项目主页下载[release包](https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-windows-amd64.zip)  
1. 解压  
1. 修改config.json为上面的client.json的内容  
1. 为trojan-go.exe创建快捷方式  
1. 将快捷方式加入到`C:\ProgramData\Microsoft\Windows\Start Menu\Programs`目录  
1. 开始-》输入trojan-》点击执行  

## android客户端
使用[trojan-go-android](https://github.com/p4gefau1t/trojan-go-android)，不过没找到apk，使用android studio编译后直接安装到手机上可以使用。  

## 国内直连和广告屏蔽
国内直连可以使用Trojan-Go内建的路由模块：  
修改客户端配置文件router字段为：  
/root/trojan-go/client.json
```json
    "router":{
        "enabled": true,
        "bypass": [
            "geoip:cn",
            "geoip:private",
            "geosite:cn",
            "geosite:geolocation-cn",
            "cidr:192.168.0.0/24",
            "cidr:192.168.1.0/24"
        ],
        "block": [
            "geosite:category-ads"
        ],
        "proxy": [
            "geosite:geolocation-!cn"
        ]
    }
```

# NAS局域网代理  
1. 局域网内部分设备无法安装trojan客户端，只能配置http或者socks代理，考虑到功耗，暂由NAS长期打开trojan客户端，再向局域网提供socks代理，其他设备设置代理服务器为NAS的IP地址，端口1080。由privoxy提供http代理，端口8118。  
1. 在NAS上新建2个文件夹和文件  
    /home/config/trojan-go/config.json
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
    `/home/config/trojan-go/config.json` => `/etc/trojan-go/config.json`  
    `/home/config/privoxy/config` => `/etc/privoxy/config`  
1. 局域网设备设置代理服务器为NAS  
    `socks5  192.168.0.5  1080`  
    `http  192.168.0.5 8118`  
1. 如果想让非本机设备使用代理，设置绑定地址local_addr时应该设置成0.0.0.0  

# 优化
## 端口优化
1. 可以让caddy监听1234端口，trojan-go服务端监听443端口，增加隐秘性，简化防火墙配置，不过caddy搭建的网站的访问速度会变慢。  

## 更新geoip数据库  
1. trojan-go更新较慢，release包中还是比较旧的数据库，如果有需要，可以手动下载替换。  
https://github.com/v2fly/geoip/releases/latest/download/geoip.dat  
https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat  
1. geosite.dat最近版本已经变成dlc.dat，下载后需要重命名为geosite.dat  
1. 容器中替换的话，可以增加一个目录映射,  
`      - /root/trojan-go:/geo`
1. 客户端配置中router字段增加2行配置  
/root/trojan-go/client.json
```json
        "geoip": "/geo/geoip.dat",
        "geosite": "/geo/geosite.dat"
```

# 调试
## 普通调试
1. 测试网页的时候可以使用命令测试，不用打开浏览器
   `curl -I http://www.abc.com:80` 查看网页头信息  
   `curl -L http://www.abc.com:80` 下载网页  
1. lsof -i :443 查看端口占用  

## 容器异常退出调试
1. 在compose.yaml中，修改entrypoint  
    ```yaml
    entrypoint :
      - /bin/sh
      - /test.sh
    ```
1. 在测试脚本test.sh中增加一条阻塞命令  
    ```bash
    tail -f /dev/null
    ```
1. 进入容器调试
    ```bash
    docker exec -it trojan-go sh
    ```
