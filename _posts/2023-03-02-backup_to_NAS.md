---
toc: true
toc_sticky: true
layout: single
title: rsync备份文件到NAS上
date:   2023-03-02 17:39:53 +0800
categories: NAS
description: rsync备份文件到NAS上。
keywords: NAS, rsync
---

# 整理文件夹
因为Synology Photos应用将照片按日期分目录归档，所以其他的零散照片也要分文件夹整理后上传到Photos文件夹
[stackexchange - move millions of files into dated folders](https://unix.stackexchange.com/a/633157)
```bash
for f in *.jpg; do
    date=$(date +%F -r "$f")
    y=${date:0:4}
    m=${date:5:2}
    d=${date:8:2}
    target="$y/$m/$d/"
    mkdir -p "$target"
    mv "$f" "$target"
done
```
# rsync上传
之前尝试过远程挂载NAS文件夹，在windows中直接复制粘贴过去的方式，但是经常意外中断，意外中断后，不知道文件有没有破损，也不知道之前拷贝到多少了。所以这次利用rsync增量备份，更放心。rsync是linux命令，可以在WSL中操作，我没装WSL，所以这次是用hyper-v中创建的ubuntu虚拟机。
1. NAS中使能rsync
   控制面板-》终端机和SNMP-》启动SSH功能；控制面板-》文件服务-》rsync-》启动rsync服务
2. windows上共享文件夹
3. linux中挂载宿主机文件夹
  `sudo mount.cifs //192.168.0.6/Users/taishan/Pictures /home/taishan/pic -o user=taishan`
4. 查看下文件夹内容，验证下挂载成功
5. 预运行一下
   `rsync -avzn /home/taishan/pic/ taishan@192.168.0.5:/volume1/photo/Photos/mi10/ |more`
6. 去掉n正式运行
   `rsync -avz /home/taishan/pic/ taishan@192.168.0.5:/volume1/photo/Photos/mi10/`
7. 卸载宿主机文件夹
   `sudo umount /home/taishan/pic`