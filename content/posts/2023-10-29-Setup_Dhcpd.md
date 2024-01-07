---
title: "群晖NAS配置dhcpd"
date: 2023-10-29T17:07:27Z
draft: false
tags: ["pxe", "setup", "dhcpd"]
series: ["Install"]
categories: ["Setup"]
---

## 配置文件
NAS创建文件夹
/file/config/dhcpd/data/dhcpd.conf, 内容如下:  
```bash
option arch code 93 = unsigned integer 16;
  
subnet 192.168.0.0 netmask 255.255.255.0 {
  # --- Default gateway
  option routers 192.168.0.1;
  # --- Netmask
  option subnet-mask 255.255.255.0;
  # --- Broadcast Address
  option broadcast-address 192.168.0.255;
  # --- Domain name servers, tells the clients which DNS servers to use.
  option domain-name-servers 144.144.144.144, 114.114.115.115, 8.8.8.8, 8.8.4.4;
  # --- Range
  range  192.168.0.100 192.168.0.200;
  option time-offset 0;
  default-lease-time 1209600;
  max-lease-time 1814400;
  # --- Tftp server
  next-server 192.168.0.5;
  # --- PXE boot file
  if option arch = 00:07 {
        filename "/UEFI/bootx64.efi";
  } else {
        filename "/Legacy/pxelinux.0";
  }
}

# --- Reserved Address
host MR100GP-AC {
    hardware ethernet    4C:77:66:98:2C:0B;
    fixed-address        192.168.0.1;
    max-lease-time       84600; 
}
host taishanNAS {
    hardware ethernet    00:11:32:EE:07:DD;
    fixed-address        192.168.0.5;
    max-lease-time       84600; 
}
host PC {
    hardware ethernet    04:D9:F5:F6:44:51;
    fixed-address        192.168.0.6;
    max-lease-time       84600; 
}
host OpenWrt {
    hardware ethernet    54:48:E6:A8:9B:29;
    fixed-address        192.168.0.12;
    max-lease-time       84600; 
}

```
## docker 映像
networkboot-dhcpd  
## docker 配置
网络直接用host的  
映射目录  
`/file/config/dhcpd/data/` => `/data`  

## 关闭路由器dhcp服务