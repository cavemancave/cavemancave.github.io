---
title: "小米体脂秤2接入 Home Assistant（ESP32 蓝牙网关 + bodymiscale）"
date: 2026-04-11T23:30:00+08:00
draft: false
tags: ["homeassistant", "esphome", "xiaomi", "ble", "bodymiscale"]
series: ["SmartHome"]
categories: ["Setup"]
---

# 小米体脂秤2接入 Home Assistant（ESP32 蓝牙网关 + bodymiscale）

## 简介

小米体脂秤2默认主要通过 Zepp Life App 查看历史数据，不方便在智能家居场景中做统一展示和自动化联动。本文整理了一套可落地的接入方案：使用 ESP32 充当蓝牙网关，把体重与阻抗数据接入 Home Assistant，再由 bodymiscale 计算体脂相关指标，并通过自动化区分不同家庭成员。

你将获得以下能力：

- 在 Home Assistant 中查看体重、阻抗及多项体脂计算指标
- 自动将称重数据分配到不同家庭成员
- 使用可视化卡片展示身体数据趋势

---

## 硬件信息

- 小米体脂秤2（型号：`XMTZC05HM`）
- ESP32-S3-N16R8 Dev Board

![小米体脂秤2](/images/blog/2026-04-11-HA_MiScale2_ESPHome/01_xiaomi_scale_XMTZC05HM.png)

![ESP32-S3-N16R8 Dev Board](/images/blog/2026-04-11-HA_MiScale2_ESPHome/02_esp32_s3_devboard.png)

---

## 配套版本信息

- Home Assistant `2025.11.0`（容器化安装）
- bodymiscale `2026.1.0-beta`
- ESPHome `2025.10.4`

---

## 安装步骤

### 1. ESP32 通过 ESPHome 配置为蓝牙网关

ESPHome 安装与刷机步骤这里不展开，仅保留关键配置。最重要的是最后两项：

- `esp32_ble_tracker:`
- `bluetooth_proxy:`

```yaml
esphome:
  name: ble-gateway-s3
  friendly_name: ble-gateway-s3

esp32:
  board: esp32-s3-devkitc-1
  framework:
    type: esp-idf

logger:

api:
  encryption:
    key: "XXXr9wv11Z14cjNY0tOYwYQmSE3YES8633nLIxKdLug="

ota:
  - platform: esphome
    password: "XXXc86444f8772960d1528401bd157"

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password
  ap:
    ssid: "Ble-Gateway-S3 Fallback Hotspot"
    password: !secret wifi_password

captive_portal:

# Enable BLE scan
esp32_ble_tracker:

# Enable BLE proxy
bluetooth_proxy:
```

---

### 2. Home Assistant 添加 ESPHome 设备

路径：`设置 -> 设备与服务 -> 添加集成 -> ESPHome`

- 主机：`ble-gateway-s3.local`
- 端口：`6053`
- API 密钥：填写 ESPHome YAML 中 `api.encryption.key`

---

### 3. 添加 Xiaomi BLE 集成

先在体脂秤上完整测量一次，然后：

路径：`设置 -> 设备与服务 -> 添加集成 -> Xiaomi -> Xiaomi BLE`

选择设备类型：**Mi Body Composition Scale**。

添加完成后，在实体中应能看到刚测得的体重和阻抗。

![Xiaomi BLE 集成与数据](/images/blog/2026-04-11-HA_MiScale2_ESPHome/03_xiaomi_ble_integration.png)

---

### 4. 添加自动化脚本，区分多人体重

路径：`设置 -> 自动化与场景 -> 蓝图 -> 导入蓝图`

原始蓝图：
- https://github.com/dckiller51/bodymiscale/blob/main/example_config/weight_impedance_update.yaml

你使用的修改版（在 HA 侧生成 `last_weight_time`）：
- https://github.com/cavemancave/bodymiscale/blob/main/example_config/weight_impedance_update.yaml

配置示例：

- Weight Sensor：`Mi Body Composition Scale`
- Impedance Sensor：`Mi Body Composition Scale 阻抗`
- Number of Users：`2`

#### User 1（hao）

- User 1 Name：`hao`
- User 1 Min Weight：`60`
- User 1 Max Weight：`100`

创建数值辅助元素（体重）：
- 名称：`hao-weight`
- 图标：`mdi:weight-kilogram`
- 最小值：`0`
- 最大值：`100`
- 单位：`kg`

![创建体重辅助元素](/images/blog/2026-04-11-HA_MiScale2_ESPHome/04_blueprint_config.png)

创建数值辅助元素（阻抗）：
- 名称：`hao-impedance`
- 图标：`mdi:omega`
- 最小值：`0`
- 最大值：`1000`
- 单位：`ohm`

创建日期/时间辅助元素（上次称重时间）：
- 名称：`hao-last-weight-time`
- 图标：`mdi:omega`
- 类型：`日期和时间`

#### User 2（hui）

- User 2 Name：`hui`
- User 2 Min Weight：`40`
- User 2 Max Weight：`59`

同样创建 3 个辅助元素（weight / impedance / last-weight-time）。

> ⚠️ 关键提示：不同成员的体重区间必须有明显差异，且**不能重叠**，否则同一次称重可能命中多个区间，系统无法准确判断归属。  
> 例如：成员 A 为 `60~100kg`，成员 B 为 `40~59kg`。

配置完成后，建议每位成员各测量一次，并在 `设置 -> 设备与服务 -> 实体` 中筛选新建辅助实体，确认体重、阻抗和时间都已正确更新。

---

### 5. 添加 bodymiscale 集成

该集成可通过 HACS 安装。为了使用更新版本，这里采用手动安装方式：

下载：
- https://codeload.github.com/dckiller51/bodymiscale/zip/refs/tags/2026.1.0-beta

解压后将：
- `bodymiscale-2026.1.0-beta/custom_components/bodymiscale`

复制到：
- `/config/custom_components/bodymiscale`

重启 HA 后添加 `bodymiscale` 集成，按用户逐个配置。例如：

- 姓名：`hao`
- 生日：`01/01/1990`
- 性别：`male`
- 身高：`180`
- 体重传感器：`hao-weight`
- 阻抗传感器：`hao-impedance`
- 上次称重时间传感器：`hao-last-weight-time`

提交后，按相同方式再添加另一位成员。

---

### 6. 添加 lovelace-body-miscale-card

项目地址：
- https://github.com/dckiller51/lovelace-body-miscale-card

手动安装方式：

1. 将 `body-miscale-card.js` 和 `images` 文件夹放到 HA 的 `www` 目录（即 `/config/www`）
2. 在 HA 中添加前端资源：
   - 路径：`/local/body-miscale-card.js`
   - 类型：`JavaScript 模块`
3. 重启 HA，浏览器按 `Ctrl + F5` 强制刷新

在仪表盘中添加卡片（Custom: BodyMiScale Card）：

- account：`bodymiscale.hao`
- background image：`/local/images/miscale2.jpg`
- Icons path：`/local/images/bodyscoreIcon`
- 勾选 `Enable impedance`

![卡片配置示例](/images/blog/2026-04-11-HA_MiScale2_ESPHome/05_lovelace_card_config.png)

---

### 7. 最终效果

点击卡片下方按钮可展开并查看更多身体指标。

![最终效果](/images/blog/2026-04-11-HA_MiScale2_ESPHome/06_final_result.png)

---

## 备注

- 若后续 bodymiscale 版本支持直接指定 `last-weight-time`，ESP32 可只作为纯 BLE Gateway，整体架构会更简洁
