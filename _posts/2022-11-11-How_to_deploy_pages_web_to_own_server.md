---
toc: true
toc_sticky: true
layout: single
title:  "如何将Github Pages构建结果部署到自己的服务器上"
date:   2022-11-11 17:39:53 +0800
categories: blog
description: 如何将Github Pages构建结果部署到自己的服务器上
keywords: blog
---

# 如何将github pages构建结果部署到自己的服务器上
## 简述
github pages默认会有一个Actions: pages-build-deployment, 观察源码发现此action会执行jekyll build构建出_site目录，只要把这个目录同步到自己的服务器上，再拉起http服务，就可以在自己的服务器上看到静态网页了，同步目录使用rsync命令，因为scp或者sftp每次都会重复拷贝，比较耗时
## 步骤：
1. 服务器安装rsync  
1. 准备服务器的密钥登录  
   - ssh-key-gen生成秘钥  
   - ssh-copy-id user@serverIp拷贝到服务器  
   - cat ~/.ssh/id_rsa 查看私钥  
1. 添加Secerts
   项目页 -> Settings -> Security -> Secrets -> Actions -> New repository secret添加4个密文  
   - DC_HOST 是服务器域名或者地址  
   - DC_PORT 是ssh登录服务器的端口  
   - DC_USER 是ssh登录服务器的用户名  
   - DC_PASS 是ssh登录服务器的私钥  
   ![img 1](/images/blog/2022-11-11-Action_secret.png)  
1. 添加Action  

## 参考代码
```yml
# Sample workflow for building and deploying a Jekyll site to GitHub Pages
name: Deploy Jekyll site to my own server

on:
  # Runs on pushes targeting the default branch
  push:
    branches: ["main"]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  rsync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Setup Pages
        uses: actions/configure-pages@v2
        
      - name: Build with Jekyll
        uses: actions/jekyll-build-pages@v1
        with:
          source: ./
          destination: ./_site
          
      - name: "Deploy to Staging" 
        uses: up9cloud/action-rsync@v1.3
        env:
          HOST: ${{secrets.DC_HOST}}
          PORT: ${{secrets.DC_PORT}}
          USER: ${{secrets.DC_USER}}
          # private key
          KEY: ${{secrets.DC_PASS}}
          TARGET: /root/www/
          RUN_SCRIPT_ON: remote
          POST_SCRIPT: "cd /root/www/_site/; caddy reload"
```
