---
layout: single
title:  "制作一个两个客户端联网交互的小游戏"
date:   2022-11-27 17:39:53 +0800
categories: game
---

如何用面向对象设计一个程序，经典推荐？ - rufeng2000的回答 - 知乎
https://www.zhihu.com/question/36113705/answer/2405176382

# 目的
学习并实践socket编程

# 游戏选择
pong

# 联网逻辑设计
客户端：循环读取键盘输入，写入到发送缓冲区，并刷新位置，读取接收缓冲区刷新对方位置。
服务器：等待2个连接，当有2个连接后，循环读取A的接收缓冲区写到B的发送缓冲区，读取B的接收缓冲写到A的发送缓冲区。

# 打印逻辑
利用clear清屏再输出，但是必须在linux上

## 进展
221128 命令行无法获取按键按下的事件，必须回车后才能拿到按键，需要切换到GUI继续测试
```java

import java.util.Scanner;


public class Pong {
	public int fieldLen;
	public int racketLen;
	public int racketPos;
	public Pong(int fieldLen, int racketLen, int racketPos) {
		this.fieldLen = fieldLen;
		this.racketLen = racketLen;
		this.racketPos = racketPos;
	}
	public void RacketUp() {
		if(this.racketPos<=0) {
			return;
		}
		this.racketPos--;
	}
	public void RacketDown() {
		if((this.racketPos+this.racketLen)>=this.fieldLen) {
			return;
		}
		this.racketPos++;
	}
	public void printRacket() {
		for(int i=0;i<racketPos;i++) {
			System.out.println("|");
		}
		for(int i=racketPos;i<racketPos+racketLen;i++) {
			System.out.println("||");
		}
		for(int i=racketPos+racketLen;i<fieldLen;i++) {
			System.out.println("|");
		}
	}
	public static void main(String[] args) {
		Pong pong = new Pong(10, 1, 5);
        Scanner input = new Scanner(System.in);
    	while(true) {
    		int number = input.nextInt();
            System.out.println(number);
            if(number==9) {
            	break;
            }
            if(number==1) {
            	pong.RacketUp();
            }else {
            	pong.RacketDown();
            }
            pong.printRacket();
    	}
        
        input.close();
	}
}


```
