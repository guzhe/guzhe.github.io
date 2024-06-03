---
title: 父工程从springboot1.5.x 升级到2.5.15总结.md
categories: 后端技术 
tags:
  - java
  - springboot
  - gradle
cover: https://vip.helloimg.com/i/2024/01/13/65a271780a72b.jpg 
date: 2024-04-23 15:56:00
---

#### 包冲突
1. log4j高版本与框架其他引入的jar可能会产生冲突 
2. 如果项目是gradle项目坑巨多 最大的问题是这个springboot2.5.15 不能用gradle4.9进行编译打包，需要使用更高版本进行编译，而更高版本的gradle语法糖很多地方不兼容老版本导致只能遇到一个坑就填一个...

#### 配置写法问题
1. eureka 配置写法改动  
老版本eureka.instance.hostname 配置 写法${spring.cloud.client.ipAddress}  
新版本eureka.instance.hostname 配置 写法 ${spring.cloud.client.ip-address}:${server.port}  
2. 配置下划线写法  
老版本配置中的属性节点可以使用下划线不，不会有报错提示  
新版本配置中属性节点使用下划线会有报错提示  
3. 会废弃配置
4. 废弃hystrix，ribbon等，如需要引用需要单独引入包，springcloud官方bom等父工程并不包含hystrix

#### mysql 驱动兼容性问题
首先看个例子：
```xml
<select id="TestList" resultType="com.vx.TestModel">
	select '' as startDate from test 
</select>
```
以上sql 查出的startDate属性如果在TestModel定义为Date类型时
在msyql8.0.xx版本的驱动下会报以下错
> Error attempting to get column 'startDate' from result set.  Cause: java.sql.SQLDataException: Unsupported conversion from LONG to java.sql.Timestamp  

而老版本（5.0.xx）驱动不会报错


#### 连接池参数问题
druild 数据库连接参数以及连接池有些参数影响到线上空闲连接池回收机制，在和老版本相同配置情况下，新版本会出现以下错误：
```
	2024-04-14 09:35:35.045 [Druid-ConnectionPool-Create-223696575] ERROR com.alibaba.druid.pool.DruidDataSource - create connection SQLException, 
	url: jdbc:mysql://172.24.0.24:33306/ibp_platform?useUnicode=true&characterEncoding=UTF8&zeroDateTimeBehavior=convertToNull&useSSL=false&allowMultiQueries=true, 
	errorCode 0, state 08S01
	com.mysql.cj.jdbc.exceptions.CommunicationsException: Communications link failure

The last packet sent successfully to the server was 0 milliseconds ago. The driver has not received any packets from the server.
	at com.mysql.cj.jdbc.exceptions.SQLError.createCommunicationsException(SQLError.java:174)
	at com.mysql.cj.jdbc.exceptions.SQLExceptionsMapping.translateException(SQLExceptionsMapping.java:64)
	at com.mysql.cj.jdbc.ConnectionImpl.createNewIO(ConnectionImpl.java:836)
	at com.mysql.cj.jdbc.ConnectionImpl.<init>(ConnectionImpl.java:456)
	at com.mysql.cj.jdbc.ConnectionImpl.getInstance(ConnectionImpl.java:246)
	at com.mysql.cj.jdbc.NonRegisteringDriver.connect(NonRegisteringDriver.java:197)
	at com.alibaba.druid.filter.FilterChainImpl.connection_connect(FilterChainImpl.java:118)
	at com.alibaba.druid.filter.stat.StatFilter.connection_connect(StatFilter.java:232)
	at com.alibaba.druid.filter.FilterChainImpl.connection_connect(FilterChainImpl.java:112)
	at com.alibaba.druid.pool.DruidAbstractDataSource.createPhysicalConnection(DruidAbstractDataSource.java:1703)
	at com.alibaba.druid.pool.DruidAbstractDataSource.createPhysicalConnection(DruidAbstractDataSource.java:1786)
	at com.alibaba.druid.pool.DruidDataSource$CreateConnectionThread.run(DruidDataSource.java:2910)
Caused by: com.mysql.cj.exceptions.CJCommunicationsException: Communications link failure

The last packet sent successfully to the server was 0 milliseconds ago. The driver has not received any packets from the server.
	at sun.reflect.GeneratedConstructorAccessor112.newInstance(Unknown Source)
	at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
	at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
	at com.mysql.cj.exceptions.ExceptionFactory.createException(ExceptionFactory.java:61)
	at com.mysql.cj.exceptions.ExceptionFactory.createException(ExceptionFactory.java:105)
	at com.mysql.cj.exceptions.ExceptionFactory.createException(ExceptionFactory.java:151)
	at com.mysql.cj.exceptions.ExceptionFactory.createCommunicationsException(ExceptionFactory.java:167)
	at com.mysql.cj.protocol.a.NativeSocketConnection.connect(NativeSocketConnection.java:91)
	at com.mysql.cj.NativeSession.connect(NativeSession.java:144)
	at com.mysql.cj.jdbc.ConnectionImpl.connectOneTryOnly(ConnectionImpl.java:956)
	at com.mysql.cj.jdbc.ConnectionImpl.createNewIO(ConnectionImpl.java:826)
	... 9 common frames omitted
Caused by: java.net.ConnectException: Connection timed out (Connection timed out)
	at java.net.PlainSocketImpl.socketConnect(Native Method)
	at java.net.AbstractPlainSocketImpl.doConnect(AbstractPlainSocketImpl.java:350)
	at java.net.AbstractPlainSocketImpl.connectToAddress(AbstractPlainSocketImpl.java:206)
	at java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:188)
	at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)
	at java.net.Socket.connect(Socket.java:607)
	at com.mysql.cj.protocol.StandardSocketFactory.connect(StandardSocketFactory.java:155)
	at com.mysql.cj.protocol.a.NativeSocketConnection.connect(NativeSocketConnection.java:65)
	... 12 common frames omitted
```