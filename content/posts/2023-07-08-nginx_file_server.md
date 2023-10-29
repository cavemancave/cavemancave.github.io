---
title: "nginx搭建http文件下载服务"
date: 2023-07-08T17:07:27Z
draft: false
tags: ["proxy", "setup", "git"]
series: ["Proxy"]
categories: ["Setup"]
---

## 配置文件
NAS创建文件夹  
/home/nginx 放网站文件  
/home/nginx/file 共享的文件放这里  
/home/config/nginx/default.conf, 内容如下:  
```bash
#/etc/nginx/conf.d/default.conf
server {
  listen *:8119;
  root /nginx;
  location / {
    index index.html index.php;
  }
  location /file/ {
    autoindex on;
  }
}
```
## docker映射
创建docker， 映射目录  
`/home/config/nginx/default.conf` => `/etc/nginx/conf.d/default.conf`  
`/home/nginx/` => `/nginx/`  
## 访问
访问 `http://192.168.0.x:8119/file`就可以直接下载文件了  
