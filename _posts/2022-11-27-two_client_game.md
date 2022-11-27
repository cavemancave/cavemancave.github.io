---
layout: single
title:  "制作一个两个客户端联网交互的小游戏"
date:   2022-11-27 17:39:53 +0800
categories: game
---

# 目的
学习并实践socket编程

# 游戏选择
pong

# 联网逻辑设计
客户端：循环读取键盘输入，写入到发送缓冲区，并刷新位置，读取接收缓冲区刷新对方位置。
服务器：等待2个连接，当有2个连接后，循环读取A的接收缓冲区写到B的发送缓冲区，读取B的接收缓冲写到A的发送缓冲区。

# 打印逻辑
利用clear清屏再输出，但是必须在linux上
```java

package pongOne;
import java.util.Scanner;


public class PongOne {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		Scanner input = new Scanner (System.in);
		while(true) {
			int USER =  input.nextInt();
			
		}
		
		if(USER == 1)
		System.out.println("\033[H\033[2J");
	}

}

```
