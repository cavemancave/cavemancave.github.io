---
title: "代理折腾记录 - trojan-go api"
date: 2023-04-30T17:07:27Z
draft: false
tags: ["proxy", "setup", "trojan-go"]
series: ["Proxy"]
categories: ["Setup"]
---

# 使用api
## 配置
过程参考[使用API动态管理用户](https://p4gefau1t.github.io/trojan-go/advance/api/)

## list
```bash
root@brave-cat-2:~# docker exec -it trojan-go sh -c "trojan-go -api-addr 127.0.0.1:10005 -api list" 
[{"status":{"user":{"hash":"ae3d5ff7c27d9f7972104af0ce08e61b50f8a5d5519b3e3a17fe5b5a"},"traffic_total":{"upload_traffic":30032266,"download_traffic":11098243382},"speed_current":{},"speed_limit":{}}}]
```
## jq
使用jq格式化输出，第一个[会导致jq格式化出错，直接cut掉
```bash
root@brave-cat-2:~# docker exec -it trojan-go sh -c "trojan-go -api-addr 127.0.0.1:10005 -api list" |cut -c 2- |jq
{
  "status": {
    "user": {
      "hash": "ae3d5ff7c27d9f7972104af0ce08e61b50f8a5d5519b3e3a17fe5b5a"
    },
    "traffic_total": {
      "upload_traffic": 30069318,
      "download_traffic": 11134051359
    },
    "speed_current": {
      "upload_speed": 534,
      "download_speed": 11610901
    },
    "speed_limit": {}
  }
}
parse error: Unmatched ']' at line 1, column 243
```
## 单个用户
单个用户的输出可以直接用jq格式化
```bash
root@brave-cat-2:~# docker exec -it trojan-go sh -c "trojan-go -api-addr 127.0.0.1:10005 -api get -target-hash ae3d5ff7c27d9f7972104af0ce08e61b50f8a5d5519b3e3a17fe5b5a"  | jq
{
  "success": true,
  "status": {
    "user": {
      "hash": "ae3d5ff7c27d9f7972104af0ce08e61b50f8a5d5519b3e3a17fe5b5a"
    },
    "traffic_total": {
      "upload_traffic": 30274617,
      "download_traffic": 11219438560
    },
    "speed_current": {},
    "speed_limit": {}
  }
}
```
# 客户端查看网速
查看issue，应该还没有实现，但是这个项目不再更新了，可以参考peter-tank的修改自己修改下，简单试了下，没改成功，以后需要再试。 [add client-side traffic query api cmd #79](https://github.com/p4gefau1t/trojan-go/pull/79)