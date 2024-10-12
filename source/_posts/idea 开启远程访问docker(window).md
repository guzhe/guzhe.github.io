---
title: idea 开启远程访问docker(window)
author: guz
tags:
  - 工具
categories:
  - 开发
cover: https://www.helloimg.com/i/2024/01/13/65a270d862900.jpg
date: 2024-10-12 15:22:18
---
#### docker for window

1. 在设置里找到 General 将 “Expose daemon on tcp://localhost:2375 without TLS” 一项勾选中  
2. 设置里找到 docker engine 将配置新增节点： "hosts":["tcp://0.0.0.0:2375"] 参考配置如下：  
~~~
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "hosts": [
    "tcp://0.0.0.0:2375"
  ]
}
~~~

#### 用管理员身份运行CMD命令

netsh interface portproxy reset
netsh interface portproxy add v4tov4 listenport=2375 connectaddress=localhost connectport=2375
net start iphlpsvc
> 查看命令： netsh interface portproxy all

#### idea 配置
在services窗口中添加docker connection  
如果docker for Window 运行在本电脑中，则直接勾选“docker for Window ”选项即可  
如果是远程访问，则需要选择TCP socket 填写 Engine API URL 例如： tcp://远程计算机IP地址:2375  