---
title: "代理折腾记录 - git proxy"
date: 2023-05-19T17:07:27Z
draft: false
tags: ["proxy", "setup", "git"]
series: ["Proxy"]
categories: ["Setup"]
---

## 配置
需要先在本地配置启动好socks代理和http代理，我用的是trojan-go和privoxy，然后
```bash
# 配置http代理
git config --global http.proxy "http://127.0.0.1:8118"
# 配置socks代理
git config --global core.gitproxy "socks5://127.0.0.1:1080"
# 查看配置
git config --global -l 
```
