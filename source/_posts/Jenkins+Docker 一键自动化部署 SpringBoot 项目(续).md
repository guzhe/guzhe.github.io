---
title: Jenkins+Docker 一键自动化部署 SpringBoot 项目(续)
categories: 运维
tags:
  - jenkins
  - docker
top_img: 
cover: https://s11.ax1x.com/2024/01/29/pFuhRQx.jpg
# aplayer: true
date: 2024-01-24 16:50:00
---

#### 发布项目支持选择git 分支

-  安装插件Git Parameter

-  项目构建配置中配置 如下图配置参数

  ![img](https://img-blog.csdnimg.cn/3c94a62820bc48daa0c8fd509cb0d76a.png)

  

-  在branches to build 中引用 branch 参数 这样就完成配置了

  ![img](https://img-blog.csdnimg.cn/b1b9c47c205a43209c89f373ad5d06a9.png)

#### 支持服务项目远程部署

1. 安装插件 Publish over SSH

2. 系统配置中配置Publish over SSH

   - 下图圈起来的位置是 远程服务器登录密码或者是ssh 的key(取决于服务器认证方式)

     ![img](https://img-blog.csdnimg.cn/811f0134211f4ab7984d8c69ec5ad069.png)

   - 接着添加ssh servers 信息 

     ![img](https://img-blog.csdnimg.cn/98a89bdf49e7414b846ebee382c2b551.png)

3. 项目构建中添加构建步骤 send files or execute commands over ssh

   ![img](https://img-blog.csdnimg.cn/d27624a09cfb42e7a5f43849be9cddc5.png)

4. 步骤如下配置 选择ssh server 后配置 transfers

   其中 sources files 位置为工作空间的相对位置

   remove prefix 是去除前缀后的 文件会全部传入远程服务器

   remote directory  是与 上面系统配置ssh servers中的remote directory 结合的位置，此位置就是远程服务器存放传输文件的位置
   ![img](https://img-blog.csdnimg.cn/0387490e558c4634af8242d619aa9d76.png)

5. 最后一步 配置 exec command,如下图

   ![img](https://img-blog.csdnimg.cn/d7ef0ac5ff194027a2dc12172aaa1324.png)

    到此，简单的远程部署就结束了!



​	

