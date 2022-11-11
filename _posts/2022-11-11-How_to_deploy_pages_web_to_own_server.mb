将github原有的action会执行jekyll build构建出_site目录，利用rsync同步推送到自己的服务器上
步骤：
1. 准备服务器的密钥登录

2. 添加Secerts

3. 添加step


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
