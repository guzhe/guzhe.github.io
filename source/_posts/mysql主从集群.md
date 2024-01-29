---
title: docker之mysql主从集群
categories: 运维
tags:
  - docker
  - mysql
cover: https://s11.ax1x.com/2024/01/11/pFCmGUP.jpg
# aplayer: true
date: 2024-01-09 22:46:01
---

#### 创建两个docker环境下的mysql 

1.新建两个my.cnf 分别放在 /home/guji/Volume/mysql5.7_3306/conf  ，  /home/guji/Volume/mysql5.7_3307/conf

分别在两个my.cnf 开启binlog

```
#注意这个，搭建主从这个ID不能重复
server_id=1
#可以填容器内的可访问日志路径+文件名 例如：/var/log/mysql/mybinlog
log_bin = mysql-bin
# 3种不同的格式可选：mixed,statement,row，默认格式是 statement 推荐使用MIXED
binlog_format = MIXED
# 日志过期(注意mysql8 版本此参数废弃，文章结尾参数里有说明)
expire_logs_days = 30
# 可设置忽略库

# 可设置单独需同步库 
```

> **更多参数参考最后给出my.cnf配置**



#### 运行mysql 容器（注意这里拉取的mysql版本）

```
#master
docker run -p 3306:3306 --name mysql -m 500m -v /home/guji/Volume/mysql5.7/log:/var/log/mysql -v /home/guji/Volume/mysql5.7/data:/var/lib/mysql -v /home/guji/Volume/mysql5.7_3306/conf:/etc/mysql -e MYSQL_ROOT_PASSWORD=root -d mysql:5.7.12

#slave
docker run -p 3307:3306 --name mysql -m 500m -v /home/guji/Volume/mysql5.7/log:/var/log/mysql -v /home/guji/Volume/mysql5.7/data:/var/lib/mysql -v /home/guji/Volume/mysql5.7_3307/conf:/etc/mysql -e MYSQL_ROOT_PASSWORD=root -d mysql:5.7.12

```

> *注意一个问题：**mysql8.0**以上 配置文件挂载位置是 /etc/mysql/conf.d 即：/home/guji/Volume/mysql5.7_3307/conf:/etc/mysql/conf.d*

#### 主库授予用户远程访问权限

+ 进入master mysql容器中输入 mysql -u root -p 输入密码后进去执行：

  //注意一个很重要的地方

  **如果登录出现  [Warning] World-writable config file '/xxx/my.cnf' is ignored.,需要对容器内这个文件进行赋权 （chmod 644 /xxx/my.cnf），否则配置文件不生效！（这个地方有坑）**

+ 看下binlog 是否开启 SHOW VARIABLES LIKE '%log_bin%';开启后继续以下操作

+ CREATE USER 'root'@'%' IDENTIFIED BY 'root';

+ GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';

其中% 可配置成允许访问的IP,可以根据实际情况配置

> *注意两个点问题：**mysql8**版本授权必须要先create user 然后才能执行grant ，mysql8还需要注意用户密码加密方式，老的一些连接客户端可能没有新的加密方式出现无法认证*  例如执行以下语句：
>
> alter user 'root'@'%' identified with mysql_native_password by 'root';

+ 执行 show master status; 查看主机的binlog 文件与位置 拿到master_log_file 和 master_log_pos 参数以下需要用

#### 从库添加配置主库bin信息并开启slave

进入从库 mysql容器中输入 mysql -u root -p 输入密码后进去执行以下操作

+ 看下binlog 是否开启 SHOW VARIABLES LIKE '%log_bin%';开启后继续以下操作

+ 先停止slave 

  > stop slave;

+ 添加主服务器binlog采集信息

  >  change master to master_host='10.92.32.33', master_user='root', master_password='root', master_log_file='mybinlog.000004', master_log_pos=1447;

*如果这个命令执行如果报错，可能容器以及由这个主库信息了，可以执行**reset slave**操作*

+ 开启slave

  > start slave;

+ 查看slave状态

  > show slave status \G;
  >
  > 具体的错误日志可以执行查看错误日志sql
  >
  > select * from replication_applier_status_by_worker;
  >
  > 然后一步步排查解决直到 slave 的 **Slave_IO_Running**和 **Slave_SQL_Running**都为**yes**
  >
  > 并且**Slave_IO_State** 为 **Waiting for master to send event** 就初步成功了

#### my.cnf完整配置
***
```
[mysqld]
#Mysql服务的唯一编号 每个mysql服务Id需唯一
server-id=2001

#服务端口号 默认3306
port=3306

#mysql安装根目录
#basedir=/usr/local/mysql

#mysql数据文件所在位置
datadir=/var/lib/mysql

#pid
#pid-file=/var/run/mysqld/mysqld.pid

#设置socke文件所在目录
socket=mysql.sock

#设置临时目录
#tmpdir=/tmp

#用户

user=mysql

#允许访问的IP网段

bind-address=0.0.0.0

#跳过密码登录

#skip-grant-tables

#主要用于MyISAM存储引擎,如果多台服务器连接一个数据库则建议注释下面内容
#skip-external-locking

#只能用IP地址检查客户端的登录，不用主机名
#skip_name_resolve=1

#事务隔离级别，默认为可重复读，mysql默认可重复读级别（此级别下可能参数很多间隙锁，影响性能）
#transaction_isolation=READ-COMMITTED

#数据库默认字符集,主流字符集支持一些特殊表情符号（特殊表情符占用4个字节）
character-set-server=utf8mb4

#数据库字符集对应一些排序等规则，注意要和character-set-server对应
collation-server=utf8mb4_general_ci

#设置client连接mysql时的字符集,防止乱码
init_connect='SET NAMES utf8mb4'

#是否对sql语句大小写敏感，1表示不敏感
lower_case_table_names=1

#最大连接数
max_connections=400

#最大错误连接数
max_connect_errors=1000

#TIMESTAMP如果没有显示声明NOT NULL，允许NULL值
explicit_defaults_for_timestamp=true

#SQL数据包发送的大小，如果有BLOB对象建议修改成1G
max_allowed_packet=128M

#MySQL连接闲置超过一定时间后(单位：秒)将会被强行关闭
#MySQL默认的wait_timeout  值为8个小时, interactive_timeout参数需要同时配置才能生效
interactive_timeout=1800
wait_timeout=1800

#内部内存临时表的最大值 ，设置成128M。
#比如大数据量的group by ,order by时可能用到临时表，
#超过了这个值将写入磁盘，系统IO压力增大
tmp_table_size=134217728
max_heap_table_size=134217728

#禁用mysql的缓存查询结果集功能
#后期根据业务情况测试决定是否开启
#大部分情况下关闭下面两项
#query_cache_size = 0
#query_cache_type = 0

#数据库错误日志文件
#log-error=/var/log/mysqld.log

#慢查询sql日志设置
#slow_query_log=1
#slow_query_log_file=/var/log/mysqld_slow.log

#检查未使用到索引的sql
log_queries_not_using_indexes=1

#针对log_queries_not_using_indexes开启后，记录慢sql的频次、每分钟记录的条数
log_throttle_queries_not_using_indexes=5

#作为从库时生效,从库复制中如何有慢sql也将被记录
log_slow_slave_statements=1

#慢查询执行的秒数，必须达到此值可被记录
long_query_time=8

#检索的行数必须达到此值才可被记为慢查询
min_examined_row_limit=100


log_bin = mysql-bin
log_error_verbosity = 2
binlog_cache_size=2M
max_binlog_size = 256M
binlog_checksum = NONE
binlog_format = MIXED
binlog_rows_query_log_events = 1
sync_binlog = 1
#mysql8此参数废弃；
#expire_logs_days = 7
#mysql8 默认设置的binlog过期时间是30天；
binlog_expire_logs_seconds=604800

#replication settings

#server_id = 101
#gtid_mode = on
#enforce_gtid_consistency = 1
#skip_slave_start = 1
#master_info_repository = TABLE
#relay_log_info_repository = TABLE
#relay_log_recovery = 1
#slave_rows_search_algorithms = 'INDEX_SCAN,HASH_SCAN'
#slave_parallel_type = logical_clock
#slave_parallel_workers = 4 #执行relay log的线程数
```



***