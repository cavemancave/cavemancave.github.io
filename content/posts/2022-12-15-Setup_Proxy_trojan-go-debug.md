---
title: "代理折腾记录 - trojan-go调试"
date: 2022-12-15T17:07:27Z
draft: false
tags: ["proxy", "setup", "caddy", "trojan-go"]
series: ["Proxy"]
categories: ["Setup"]
---

# 优化
## 端口优化
1. 可以让caddy监听1234端口，trojan-go服务端监听443端口，增加隐秘性，简化防火墙配置，不过caddy搭建的网站的访问速度会变慢。  

## 更新geoip数据库  
1. trojan-go已经停止更新，release包中还是比较旧的数据库，如果有需要，可以手动下载替换。  
https://github.com/v2fly/geoip/releases/latest/download/geoip.dat  
https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat  
1. geosite.dat最近版本已经变成dlc.dat，下载后需要重命名为geosite.dat  
1. 容器中替换的话，可以增加一个目录映射,  
    ```yaml
          - /root/trojan-go:/geo
    ```
1. 客户端配置中router字段增加2行配置  
    /root/trojan-go/client.json
    ```json
            "geoip": "/geo/geoip.dat",
            "geosite": "/geo/geosite.dat"
    ```

# 调试
## 普通调试
1. 测试网页的时候可以使用命令测试，不用打开浏览器  
    ```bash
    # 查看网页头信息
    curl -I http://www.abc.com:80
    # 下载网页 
    curl -L http://www.abc.com:80 
    ```
1. 查看端口占用  
    ```bash
    lsof -i :443 
    ```

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
1. 拉起容器；进入容器；这样就可以查看文件映射结果或者手动执行entrypoint中的命令等操作
    ```bash
    docker exec -it trojan-go sh
    ```
