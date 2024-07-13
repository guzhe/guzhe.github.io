---
title: wmware centos7 虚拟机通过宿主机的Clash访问外网
categories: 运维
tags:
  - 虚拟机
cover: https://s11.ax1x.com/2024/01/11/pFCmGUP.jpg
# aplayer: true
date: 2024-07-13 21:40:18
---

#### 介绍  
在使用虚拟机的时候，经常拉取不到镜像包，这个时候需要开启代理

#### 开启服务
1. 允许局域网访问使用7890端口来提供网络代理服务。  
2. 获取宿主机服务IP  

#### 配置代理
1. 直接配置系统代理  
~~~
cat >> ~/.bashrc << EOF
export https_proxy=http://192.168.0.103:7897
export http_proxy=http://192.168.0.103:7897
export all_proxy=socks5://192.168.0.103:7897
EOF
source ~/.bashrc
~~~

2. 使用脚本来实现代理  
创建脚本 setproxy.sh
~~~source
#!/bin/bash
# encoding: utf-8

Proxy_IP=192.168.0.103
Proxy_Port=7897

# Set System Proxy
function xyon(){
    export https_proxy=http://$Proxy_IP:$Proxy_Port
    export http_proxy=http://$Proxy_IP:$Proxy_Port
    export all_proxy=socks5://$Proxy_IP:$Proxy_Port
    echo -e "System Proxy is $Proxy_IP:$Proxy_Port"
}

# unSet System Proxy
function xyoff(){
    unset all_proxy
    unset https_proxy
    unset http_proxy
    echo -e "System Proxy is Disabled"
}

# Default Function is Set Proxy
if [ $# != 0 ]
then
	if [ $1 == 'off' ]
	then
		xyoff
	elif [ $1 == 'on' ]
	then
		xyon
	else
		echo "Please Input on or off!"
	fi
else
	echo "Please input command."
fi
~~~

调用脚本

```text
chmod +x setproxy.sh
# 因为父子shell的问题，使用source来使得脚本设置来修改当前父Shell环境变量
# 开启代理
source setproxy.sh on
# 关闭代理
source setproxy.sh off
```

#### Windows Firewall 打开 tcp 7890 端口

- 按下 Windows + R 打开运行窗口
- 输入 wf.msc 然后回车即可

放行 tcp 7890 端口就足够。



#### 测试

```text
curl -I https://www.google.com
```