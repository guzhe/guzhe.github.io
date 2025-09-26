# 直接使用Nginx部署已有dist文件
FROM nginx:alpine
COPY public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
