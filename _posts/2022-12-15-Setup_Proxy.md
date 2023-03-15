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
后续计划服务端和客户端都使用容器，这样对环境的污染最小，备份一份compose.yaml和代理配置文件夹即可。  
目前在NAS上长期运行着代理客户端，并向局域网提供socks和http代理，局域网内部分设备设置代理服务器为NAS地址，经NAS代理出海。  
计划测试自动代理配置，不过听说有签名问题，待研究  

# 服务器配置
1. 购买一个VPS，ip地址`1.2.3.4`，操作系统：Ubuntu 22.04 x86_64   
2. 购买一个域名`www.abc.com`  
3. 设置一条A记录  
    `A    www    1.2.3.4    600`

# caddy配置
## 安装caddy
参考[官方安装教程](https://caddyserver.com/docs/install#debian-ubuntu-raspbian)，依次执行下面的命令
```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

## 修改默认配置文件
caddy 安装完成后会启动一个systemd服务，这个服务是系统启动时自启动的，所以直接修改服务中指定的配置文件，可以保证重启后服务可以自启动。  
1. 打开默认配置文件 `/etc/caddy/Caddyfile`。  
1. 在`:80`后增加购买的域名, 改完后这一行应该像这样：`:80, www.cavemancave.tk {`  
1. 重启服务，`sudo systemctl restart caddy`  
1. 访问 `http://www.abc.com` 应该成功打开网页
1. 访问 `https://www.abc.com` 也应该成功打开网页。  
1. 如果出错，可以通过 `sudo systemctl status caddy` 查看日志。比如我的/var/lib目录没有权限创建文件夹，就需要手动增加权限 `sudo chmod 777 /var; sudo chmod 777 /var/lib`  

# trojan-go配置
## 查找证书文件
trojan-go需要使用caddy申请的证书文件来进行TLS握手，使用find命令查找caddy自动申请的证书文件。在我的环境上查找到的目录为：  
```bash
find / -name www.abc.com.key
/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/www.abc.com/www.abc.com.key
``` 

## 创建trojan-go服务端配置文件
创建trojan-go服务端配置文件 `/root/trojan-go/server.json` ，监听在端口 `1234`  
  
```json
{
    "run_type": "server",
    "local_addr": "www.cavemancave.tk",
    "local_port": 1234,
    "remote_addr": "www.cavemancave.tk",
    "remote_port": 80,
    "password": [
        "password"
    ],
    "ssl": {
        "cert": "/cert/www.cavemancave.tk.crt",
        "key": "/cert/www.cavemancave.tk.key",
        "fallback_port": 443
    }
}
```

## 启动trojan-go服务端容器
1. 安装docker  
    ```bash
    sudo apt-get install docker docker-compose
    ```
1. 创建容器配置文件  
    /root/compose.yaml  
    ```yaml
    services:
      trojan-go:
        image: p4gefau1t/trojan-go
        container_name: trojan-go
        network_mode: host
        volumes:
          - /root/trojan-go/server.json:/etc/trojan-go/config.json
          - /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.    letsencrypt.org-directory/www.abc.com:/cert
    ```
    上面的配置中映射了2个文件夹，一个是trojan-go服务端配置，另一个是caddy申请的证书文件夹。  
1. 执行 `docker-compose up -d` 拉起容器   
1. 访问 `https://www.abc.com:1234` 应该成功打开网页  
1. 如果出错的话，可以通过 `docker logs trojan-go` 查看docker日志

## 服务自启动
1. docker服务是开机自启动的，但是需要启动的容器需要在compose.yaml中增加 `restart: always` 字段，并拉起过一次  
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
        "remote_addr": "www.cavemancave.tk",
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
2. 如果不在VPS上测试，而是本地测试，compose.yaml应该删除服务端的段落  
    在本地测试连接时，经常受到DNS污染，可以使用下面的命令让DNS在远端解析，避免本地DNS污染导致的连接失败
    `curl --socks5-hostname localhost:1080 www.google.com`
## windows客户端
项目主页下载release包  
 https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-windows-arm64.zip  
解压  
修改config.json为上面的client.json的内容  
为trojan-go.exe创建快捷方式  
将快捷方式加入到`C:\ProgramData\Microsoft\Windows\Start Menu\Programs`目录  
开始-》输入trojan-》点击执行  

## android客户端
下载Igniter，不过我直接使用会报错，使用android studio编译后直接安装到手机上可以使用。  

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
2. 在NAS上新建2个文件夹和文件  
    /home/config/trojan-go/config.json
    内容如上一节  
    /home/config/privoxy/config  
    ```json
    forward-socks5   /               0.0.0.0:1080 .
    listen-address 0.0.0.0:8118
    ```
3. 拉起2个容器  
    `p4gefault-trojan-go`  
    `vimagick-privoxy`  
    拉起时使用与DockerHost相同的网络，根据Entrypoint确定默认配置文件路径，各自映射配置文件  
    `/home/config/trojan-go/config.json` => `/etc/trojan-go/config.json`  
    `/home/config/privoxy/config` => `/etc/privoxy/config`  
4. 局域网设备设置代理服务器为NAS  
    `socks5  192.168.0.5  1080`  
    `http  192.168.0.5 8118`  
1. 如果想让非本机设备使用代理，设置绑定地址local_addr时应该设置成0.0.0.0  
# 优化
1. 可以让caddy监听到1234端口，trojan-go服务端监听443端口，增加隐秘性，简化防火墙配置，不过caddy搭建的网站的访问速度会变慢。  
1. caddy默认的网站根目录是 `/usr/share/caddy`，如果需要更换到其他目录，应该在 `/etc/caddy/Caddyfile` 中增加root字段指定工作目录。  
## 更新geoip数据库  
trojan-go更新较慢，release包中还是比较旧的数据库，如果有需要，可以手动下载替换。  
https://github.com/v2fly/geoip/releases/latest/download/geoip.dat  
https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat  
geosite.dat最近版本已经变成dlc.dat，下载后需要重命名为geosite.dat  
容器中替换的话，可以增加一个目录映射,  
`      - /root/trojan-go:/geo`
客户端配置中router字段增加2行配置  
/root/trojan-go/client.json
```json
        "geoip": "/geo/geoip.dat",
        "geosite": "/geo/geosite.dat"
```

# 调试
1. 测试网页的时候可以使用命令测试，不用打开浏览器`curl -L http://www.abc.com:80`  
2. lsof -i :443 查看端口占用，杀掉进程
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
