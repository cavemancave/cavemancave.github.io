---
title: "代理折腾记录 - trojan-go服务端"
date: 2022-12-15T15:07:27Z
draft: false
tags: ["proxy", "setup", "caddy", "trojan-go"]
series: ["Proxy"]
categories: ["Setup"]
---

# trojan-go服务端配置
## 添加容器配置
/root/compose.yaml  
```yaml
services:
  trojan-go:
    image: p4gefau1t/trojan-go
    container_name: trojan-go
    network_mode: host
    volumes:
      - /root/trojan-go/server.json:/etc/trojan-go/config.json
      - /root/caddy/data/caddy/certificates/acme-v02.api.letsencrypt.org-directory:/cert
```
## 添加服务端配置文件
创建`/root/trojan-go/server.json` ，监听在端口 `1234`  
```json
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 1234,
    "remote_addr": "www.abc.com",
    "remote_port": 80,
    "password": [
        "password"
    ],
    "ssl": {
        "cert": "/cert/www.abc.com/www.abc.com.crt",
        "key": "/cert/www.abc.com/www.abc.com.key",
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
1. 增加字段并重新拉起容器后，尝试重启服务器，启动成功后，访问`https://www.abc.com:1234`应该成功打开  
1. 刚开始调试时，不能加上 `restart: always` 字段，否则可能会因为配置错误，反复重启，打印大量日志，也无法进入容器调试  

