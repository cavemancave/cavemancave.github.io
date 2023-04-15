---
title: "代理折腾记录 - caddy"
date: 2022-12-15T14:08:27Z
draft: false
tags: ["proxy", "setup", "caddy", "trojan-go"]
series: ["Proxy"]
categories: ["Setup"]
---

# caddy配置
## 添加容器
创建/root/caddy.yaml  
```yaml
services:
  caddy:
    image: caddy:2
    container_name: caddy
    network_mode: host
    volumes:
      - /root/caddy/Caddyfile:/etc/caddy/Caddyfile
      - /root/www:/srv
      - /root/caddy/data:/data
      - /root/caddy/config:/config
```
创建需要的目录  
```bash
mkdir /root/caddy/ /root/caddy/data /root/caddy/config /root/www
```

## 添加caddy配置文件
创建/root/caddy/Caddyfile  
```txt
:80, www.abc.com {
  root * /srv
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
docker-compose -f /root/caddy.yaml up -d caddy
```
1. 访问 `http://www.abc.com` 应该成功打开网页  
1. 访问 `https://www.abc.com` 也应该成功打开网页。  
1. 如果出错，可以通过 `docker logs caddy` 查看日志  

## 参考
1. [Caddyfile Tutorial](https://caddyserver.com/docs/caddyfile-tutorial)
1. [docker-hub caddy](https://hub.docker.com/_/caddy)