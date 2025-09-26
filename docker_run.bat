@echo off
chcp 65001 > nul
echo 开始初始化
call C:\Users\c-guz\Desktop\init_docker.bat github-page
echo ----- 开始编译 -----
call hexo clean
call  hexo g & pause
echo ----- 编译完成 -----
echo ----- 开始构建镜像 -----
docker build -t github-page . & pause
echo ----- 构建镜像完成 -----
echo ----- 开始运行 -----
docker run -d -p 4343:80 --name github-page github-page
echo ----- 运行完成 -----
pause