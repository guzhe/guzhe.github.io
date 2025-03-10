---
title: 父工程从springboot2.7.18升级到3.4.2总结
categories: 后端技术 
tags:
  - java
  - springboot
  - gradle
cover: https://www.helloimg.com/i/2024/01/13/65a26dddeb175.jpg
date: 2024-04-23 15:56:00
---

#### 包冲突
1. 组织变更导致 javax.xxx 需要改成 jakarta.xxx 
2. mybatisplus 版本需要升级，本次升级到3.5.9; baomidou的dynamic-datasource升级至4.2.0
3. hutool 从5.7.10升级到5.8.34, guava 从30.0-jre升级到33.3.1-jre
4. 如果项目应用了apollo老版本也需要升级，本次升级到2.3.0
5. jdk升级到17,项目以及maven编译等级也需要升到17
6. 如果使用了spring cloud 升级到2024.0.0之后

#### 配置写法问题

redis原来写法为：
~~~
spring:
  redis:
    # MIT
    database: 0
    host: 10.92.33.193
    password: root
    jedis:
      pool:
        max-active: 2
        max-idle: 2
        max-wait: -1
        min-idle: 2
    port: 6379
    timeout: 60000
~~~
现在写法为：
~~~
spring:
  data:
    redis:
      # MIT
      database: 0
      host: 10.92.33.193
      password: root
      jedis:
        pool:
          max-active: 2
          max-idle: 2
          max-wait: -1
          min-idle: 2
      port: 6379
      timeout: 60000
~~~



#### 可接入Spring AI 1.0.0-M6
~~~
<dependencyManagement>
            <dependency>
                <groupId>org.springframework.ai</groupId>
                <artifactId>spring-ai-bom</artifactId>
                <version>1.0.0-M6</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
</dependencyManagement>

<dependency>
    <groupId>org.springframework.ai</groupId>
    <artifactId>spring-ai-openai-spring-boot-starter</artifactId>
</dependency>
~~~
