---
title: maven清除仓库未下载文件
categories: 后端技术
tags:
  - maven
  - others
cover: https://www.helloimg.com/i/2025/06/06/68428fa6d7a82.jpg
date: 2025-06-06 22:40:00
---

#### 脚本
~~~dos

@echo off
rem create by NettQun
  
rem 仓库路径
set REPOSITORY_PATH=D:\maven_repository
rem 搜索中
for /f "delims=" %%i in ('dir /b /s "%REPOSITORY_PATH%\*lastUpdated*"') do (
    echo %%i
    del /s /q "%%i"
)
rem 搜索完毕
pause

~~~
