---
layout: single
title:  "博客搭建记录-添加图片"
date:   2022-11-18 15:39:53 +0800
categories: www
---
# 方案选择
保存位置：图床，github仓库，服务器自建图床  
公开图床都存在不稳定的问题，可能使用一段时间后就不再提供服务，github仓库也有断供风险，即使使用也要备份到自己服务器上，自建图床应该是比较好的选择，不过目前暂时没有时间弄，先使用上传到github仓库再备份到服务器上的方案  

# 图片子仓库
git历史记录中会保存删除和修改的图片文件，后期会逐渐膨胀，虽然有方法处理，不过还未研究，先建立子仓库存储，避免污染博客仓库  
github新建仓库image  
博客仓库中新增image目录  
博客仓库添加子模块 `git submodule add <url> <path>`  
提交  
以后换服务器克隆记得要下载子模块  
`git clone --recurse-submodules git@github.com:cavemancave/cavemancave.github.io.git`  
如果子仓库远端更新了，需要在本地也更新下  
`git submodule update --recursive --remote`  
主仓和子仓一起更新也可以使用  
`git pull --recurse-submodules`  

# 待做
自建图床  
CDN  
