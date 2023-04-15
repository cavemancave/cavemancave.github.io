---
title: "代理折腾记录 - trojan-go客户端"
date: 2022-12-15T16:07:27Z
draft: false
tags: ["proxy", "setup", "caddy", "trojan-go"]
series: ["Proxy"]
categories: ["Setup"]
---

# trojan-go客户端配置
## linux客户端
先在服务器上测试下
### 添加容器配置
在/root/compose.yaml中增加一个段落  
```yaml
  trojan-client:
    image: p4gefau1t/trojan-go
    container_name: trojan-client
    network_mode: host
    volumes:
      - /root/trojan-go/client.json:/etc/trojan-go/config.json
```
### 添加客户端配置文件
创建`/root/trojan-go/client.json`，监听在1080端口。  
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
        "sni": "www.abc.com"
    },
    "mux" :{
        "enabled": true
    }
}
```
### 拉起客户端容器  
```bash
docker-compose up -d trojan-client
```
### 测试连接
访问 google, baidu 应该成功，查看日志没有错误  
```bash
curl -x "socks5://0.0.0.0:1080" -I https://www.google.com
curl -x "socks5://0.0.0.0:1080" -I https://www.baidu.com
docker logs trojan-client
```
本地linux客户端配置和服务器上客户端配置基本一致：
 - 安装docker和docker-compose，
 - 创建/root/compose.yaml，
 - 创建/root/trojan-go/client.json。 

在本地测试连接时，有时会受到DNS污染，可以使用下面的命令让DNS在远端解析，避免本地DNS污染导致的连接失败  
```bash
curl --socks5-hostname 0.0.0.0:1080 www.google.com
```

## windows客户端
1. 项目主页下载[release包](https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-windows-amd64.zip)  
1. 解压  
1. 修改config.json为上面的client.json的内容  
1. 为trojan-go.exe创建快捷方式  
1. 将快捷方式加入到`C:\ProgramData\Microsoft\Windows\Start Menu\Programs`目录  
1. 开始-》输入trojan-》点击执行  

## android客户端
使用[trojan-go-android](https://github.com/p4gefau1t/trojan-go-android)，不过没找到apk，使用android studio编译后直接安装到手机上可以使用。  

## 网页插件
SwitchyOmega可以根据条件自动选择是否走代理
自动切换规则增加gfwlist：
PROFILES->auto switch->Rule List Config -> AutoProxy -> Rule List URL:  
`https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt`    

## 国内直连和广告屏蔽
如果除了网页浏览，还有其他软件需要根据条件自动切换，可以使用trojan-go内建的路由模块：  
修改客户端配置文件, 增加router字段：  
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

