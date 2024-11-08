---
title: docker常用镜像运行
categories: hexo
tags:
  - hexo
  - others
cover: https://vip.helloimg.com/i/2024/01/13/65a270d4ec2d8.jpg
date: 2024-02-28 22:40:00
---



#### ELK 简单搭建

docker pull docker.elastic.co/elasticsearch/elasticsearch:7.15.1 

docker pull docker.elastic.co/logstash/logstash:7.15.1 

docker pull docker.elastic.co/kibana/kibana:7.15.1

（也有docker主将 elk 打包成一个镜像 elk,这种方式也简单）

docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300  -e "discovery.type=single-node"  -m 2g   docker.elastic.co/elasticsearch/elasticsearch:7.15.1

该命令会在后台启动一个名为elasticsearch的容器，并将主机的9200端口映射到容器的9200端口，同时将主机的9300端口映射到容器的9300端口。

docker run -d --name logstash --link elasticsearch:elasticsearch -p 5044:5044 -m 1g -v /path/to/logstash.conf:/usr/share/logstash/pipeline/logstash.conf docker.elastic.co/logstash/logstash:7.15.1

请将/path/to/logstash.conf替换为你本地存储Logstash配置文件的路径。

docker run -d --name kibana --link elasticsearch:elasticsearch -p 5601:5601 -m 1g docker.elastic.co/kibana/kibana:7.15.1

Elasticsearch配置：你可以通过访问http://localhost:9200来验证Elasticsearch是否成功运行。

Logstash配置：你可以通过编辑Logstash配置文件/path/to/logstash.conf来定义你的日志处理逻辑。

Kibana配置：你可以通过访问http://localhost:5601来打开Kibana的Web界面，并通过它进行数据可视化和管理。



ps:  es 可以安装中文分词器插件可以支持中文分词

​       logstash 可以配置beat 和kafka等等多种input方式 

​		虚拟机内存不够的一定需要带个 -m 参数限制下 容器启动后可以用docker stats 容器 查看 不够可以用 docker update -m 改下（只能改大）

​	  
> 例如： docker update -m 1G --memory-swap=1G  mysql

#### filebeat 安装运行

```
docker pull docker.elastic.co/beats/filebeat:7.15.1

mkdir filebeat 

cd filebeat 

nano filebeat.yml

docker run -d --name=filebeat --user=root --v="$(pwd)/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro" --v="/var/lib/docker/containers:/var/lib/docker/containers:ro" --v="/var/log:/var/log:ro" --v="/var/run/docker.sock:/var/run/docker.sock:ro" docker.elastic.co/beats/filebeat:7.15.1
```



#### zookeeper

```text
docker run -d --name zookeeper -p 2181:2181 -m 300M -v /etc/localtime:/etc/localtime --restart=always wurstmeister/zookeeper:3.4.13
```

#### zk ui

```
docker run -d --name zkui -p 9090:9090 -e ZKUI_ZK_SERVER=192.168.136.130:2181 -m 500M qnib/zkui
注意这个地方有点坑，容器启动却访问不了，进容器执行 curl http://127.0.0.1:9090 发现没有启动服务
手动启动就可以了或者重新拉去源码方式编译打包成可执行镜像也成
简单点手动启动下：
进入容器 docker exec -it zkui bash
cd /opt/zkui/target/  发现这里没有config.cfg启动会报错
将 /opt/zkui 目录下的这个文件拷贝到 /opt/zkui/target/ 下
手动配置下文件中的 zkserver （这个地方如果用不了VI命令的话，需要将文件拷贝到宿主机改完后，在拷贝回来 docker cp xxx:xx /xxx  docker /xxxx xxx:xx）
最后只需要启动下jar就可以了 
nohup java -jar zkui-2.0-SNAPSHOT-jar-with-dependencies.jar >out.log 2>&1 &

记：第一次发现启动成功，然后删除容器，又run了一把同样的操作发现启动失败，看来日志和源码发现配置文件（config.cfg）中需要配置这个属性 X-Forwarded-For=xxx
配置完后启动就成功了，不知道为啥一次成功一次还需要加配置。。。

```

#### kafka

为方便测试，起的zookeeper 容器都在一起 ，直接用--link 方式，如果容器不在KAFKA_ZOOKEEPER_CONNECT需要设置

docker run -d --name kafka -p 9092:9092 -m 512M --link zookeeper:zookeeper --restart=always --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --env KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 --env KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 --env KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 wurstmeister/kafka:2.8.1





查询topic列表

/opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper:2181 --list

发送消息

/opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic myTopic （）

消费消息

/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic myTopic --from-beginning

#### kafka-manager (cmak 3.0.0.6)

```bash
https://github.com/yahoo/cmak/releases 下载最新zip 需要自己打包生成镜像文件

#Dockerfile
FROM adoptopenjdk:11-jdk-hotspot-bionic
ADD cmak-3.0.0.6/ /opt/km3006/
CMD ["/opt/km3006/bin/cmak","-Dconfig.file=/opt/km3006/conf/application.conf"]

docker build -t km:3006 .

docker run -d --name km --link zookeeper:kafka-manager-zookeeper -e ZK_HOSTS=kafka-manager-zookeeper:2181 -m 300M -p 9104:9000 km:3006
```

**cmak第一次启动添加会报错：**

**KeeperErrorCode = Unimplemented for /kafka-manager/mutex Try again.**

解决：

```
docker exec -it zookeeper bash 

root@zookeeper:/opt/zookeeper-3.4.13/bin#./zkCli.sh 

[zk: localhost:2181(CONNECTED) 0] ls /kafka-manager

[configs, clusters, deleteClusters]

[zk: localhost:2181(CONNECTED) 1] create /kafka-manager/mutex ""

Created /kafka-manager/mutex

[zk: localhost:2181(CONNECTED) 2] create /kafka-manager/mutex/locks ""

Created /kafka-manager/mutex/locks

[zk: localhost:2181(CONNECTED) 3] create /kafka-manager/mutex/leases ""

Created /kafka-manager/mutex/leases
```

完美解决。（可以使用zk ui界面上添加比较方便）

#### jenkins

docker run -d --name jenkins -u root -p 14639:8080 -p 50000:50000 --privileged=true  -v /var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean

ps： 如果知道 tag 可以给 image 打上 docker tag image:latest image:version

#### xwiki
docker run -d --name xwiki -p 8051:8080 -v D:\share\home\xwiki:/usr/local/xwiki -e DB_USER=root -e DB_PASSWORD=123456 -e DB_DATABASE=xwiki -e DB_HOST=10.92.32.33 xwiki:mysql-tomcat  （这里的运行环境是docker for window 也可以运行起来）

#### redis
1.首先创建数据卷 D:\share\home\redis 下载 http://download.redis.io/redis-stable/redis.conf 放在目录下
2.更改 redis.conf 将 bind 127.0.0.1 注释掉 ，设置appendonly yes开启持久化配置等等
3.docker run -d --name redis -p 6377:6379 -v D:\share\home\redis\redis.conf:/etc/redis/redis.conf -v D:\share\home\redis\data:/data  redis:7.2.3

#### hertzbeat 监控
docker run -d -p 1157:1157 -p 1158:1158 -e LANG=zh_CN.UTF-8 -e TZ=Asia/Shanghai -v D:\share\home\hertzbeat\data:/opt/hertzbeat/data -v D:\share\home\hertzbeat\logs:/opt/hertzbeat/logs -v D:\share\home\hertzbeat\application.yml:/opt/hertzbeat/config/application.yml -v D:\share\home\hertzbeat\sureness.yml:/opt/hertzbeat/config/sureness.yml --restart=always --name hertzbeat tancloud/hertzbeat:v1.4.3
浏览器访问http://localhost:1157 默认账号密码 admin/hertzbeat
部署采集器集群
docker run -d -e IDENTITY=custom-collector-name -e MANAGER_HOST=10.92.32.33 -e MANAGER_PORT=1158 --name hertzbeat-collector tancloud/hertzbeat-collector:v1.4.3
-e IDENTITY=custom-collector-name : 配置此采集器的唯一性标识符名称，多个采集器名称不能相同，建议自定义英文名称。
-e MODE=public : 配置运行模式(public or private), 公共集群模式或私有云边模式。
-e MANAGER_HOST=127.0.0.1 : 配置连接主HertaBeat服务的对外IP。
-e MANAGER_PORT=1158 : 配置连接主HertzBeat服务的对外端口，默认1158

#### postgres sql
> docker run --name pgsql --privileged -e POSTGRES_PASSWORD=123456 -p 5432:5432 -v D:\docker_mapping\pgsql\data:/var/lib/postgresql/data -d postgres:14.11


#### mysql8
> * 先随便启动一个mysql8 ,然后复制出配置文件
>> * docker run -p 3306:3306 --name mysql8 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:8.3.0
>> * docker cp  mysql8:/etc/mysql D:\docker_mapping\mysql
> * docker rm -f mysql8
> * docker run  -p 3306:3306  --name mysql8  --privileged=true -v D:\docker_mapping\mysql:/etc/mysql  -v D:\docker_mapping\mysql\data:/var/lib/mysql  -v /etc/localtime:/etc/localtime  -e MYSQL_ROOT_PASSWORD=123456  -d mysql:8.3.0


#### MongoDB
```
docker run --name mongodb -v D:\docker_mapping\mongo\mongodb:/data/db -p 27017:27017 -d mongo:6.0.13 --auth
docker exec -it mongodb mongosh admin (mongo 5.0以下 使用mongo 命令)
db.createUser({ user:'root',pwd:'123456',roles:[ { role:'userAdminAnyDatabase', db: 'admin'},"readWriteAnyDatabase"]> });
db.auth('root', '123456');
```
#### NIFI
docker run --privileged=true --name nifi -p 8443:8443 -p 9999:9999 -e NIFI_WEB_HTTP_PORT=8443 -d apache/nifi:1.24.0

#### nacos
1. 安装容器
docker run --name nacos -d -p 8848:8848 -e MODE=standalone  nacos/nacos-server:v2.3.1
2. 创建挂载需要的目录
mkdir -p /mydata/nacos/logs/                      #新建logs目录
mkdir -p /mydata/nacos/conf/            #新建conf目录
mkdir -p /mydata/nacos/data/            #新建data目录
3. 复制文件到挂载目录
docker cp nacos:/home/nacos/logs/ D:\docker_mapping\nacos
docker cp nacos:/home/nacos/conf/ D:\docker_mapping\nacos
docker cp nacos:/home/nacos/data/ D:\docker_mapping\nacos
4. 删除容器
docker rm -f nacos
5. 进入挂载目录找到application.properties完成配置
6. 重新安装（完成配置文件挂载）
docker run -d --name nacos \
-p 8848:8848 \
-p 9848:9848 \
-p 9849:9849 \
--env MODE=standalone \
--env NACOS_AUTH_ENABLE=true \
-v D:\docker_mapping\nacos\conf:/home/nacos/conf \
-v D:\docker_mapping\nacos\logs:/home/nacos/logs \
-v D:\docker_mapping\nacos\data:/home/nacos/data \
nacos/nacos-server:v2.3.1
> 注意如果使用数据库方式需要先执行脚本，然后在启动容器不然会报错

<<<<<<< HEAD
#### Apollo 多环境分布式部署（dev,pro）
1. 新建数据库（多个环境需要建立多个config库）执行sql 文件 文件参考：  
  config库： https://github.com/apolloconfig/apollo/blob/master/scripts/sql/src/apolloconfigdb.sql
  portal库： https://github.com/apolloconfig/apollo/blob/master/scripts/sql/src/apolloportaldb.sql
建立完成后应该有两个config库 和一个 protal库 例如：apollo_config_dev，apollo_config_pro，apollo_portal_db

2. 建立本地映射目录 例如D盘下新建Apollo文件夹，随便起一个apollo-configservice容器和apollo-adminservice容器
将这两个服务的配置文件拷贝一份到对应的目录中  
> docker cp apollo-configservice:/apollo-configservice/config D:\docker_mapping\apollo\config-service-dev  
> docker cp apollo-adminservice容器:/apollo-adminservice/config D:\docker_mapping\apollo\admin-service-dev 
3. 将配置也复制一份到对应的pro文件夹里  

完成后的目录结构：
~~~
├─admin-service-dev
│  └─config
├─admin-service-pro
│  └─config
├─config-service-dev
│  └─config
├─config-service-pro
│  └─config
└─protal
    └─config
~~~

3. 修改本地config-service-dev和config-service-pro下config目录下的配置文件application-github.properties  
里面只需要配置数据库相关信息即可

4. 启动apollo-configservice容器
~~~
docker run -d -p 8109:8080 --name apollo-configservice-dev -v D:\docker_mapping\apollo\config-service-dev\config:/apollo-configservice/config apolloconfig/apollo-configservice:2.2.0  
docker run -d -p 8110:8080 --name apollo-configservice-pro -v D:\docker_mapping\apollo\config-service-pro\config:/apollo-configservice/config apolloconfig/apollo-configservice:2.2.0  
~~~
> 注意configservice 服务自带注册中心

5. 注意在 apollo_config 对应的库中找到表ServerConfig，修改eureka.service.url地址，地址为上面的config-service注册中心地址例如：http://本机IP:8109/eureka/  
dev和 pro config库都需要配置好，否则apollo-adminservice服务注册不上来

6. 启动apollo-adminservice容器
~~~
docker run -d -p 8111:8090 --name apollo-adminservice-dev -v D:\docker_mapping\apollo\admin-service-dev\config:/apollo-adminservice/config apolloconfig/apollo-adminservice:2.2.0  
docker run -d -p 8112:8090 --name apollo-adminservice-pro -v D:\docker_mapping\apollo\admin-service-pro\config:/apollo-adminservice/config apolloconfig/apollo-adminservice:2.2.0  
~~~
7. 启动apollo-portal容器  

  * 在apollo_portal_db 中 找到表ServerConfig  
    * 修改apollo.portal.envs 配置多环境例如：DEV,PRO 
    * 修改apollo.portal.meta.servers地址，地址为上面的config-service地址例如：{"DEV":"http://10.92.33.112:8109","PRO":"http://10.92.33.112:8110"}  
  * 执行命令  
docker run -p 8120:8070 -d --name apollo-portal -v D:\docker_mapping\apollo\protal\config:/apollo-portal/config apolloconfig/apollo-portal:2.2.0  

#### naxus3
docker run --privileged=true --name nexus -p 43633:43633 -p 9081:8081 -v D:\docker_mapping\nexus:/nexus-data -d sonatype/nexus3

#### rabbitMQ
1. 单节点部署
~~~
* 运行镜像 - 方式一：默认guest 用户，密码也是 guest
docker run -d --hostname my-rabbit --name rabbit -p 15672:15672 -p 5672:5672 rabbitmq:management

* 运行镜像 - 方式二：设置用户名和密码
docker run -d --hostname my-rabbit --name rabbit -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=password -p 15672:15672 -p 5672:5672 rabbitmq:management
~~~
2. 集群部署
命令：
~~~
docker run -d --hostname myRabbit1 --name rabbit1 -p 15672:15672 -p 5672:5672 -e RABBITMQ_ERLANG_COOKIE='rabbitcookie' rabbitmq:management
docker run -d --hostname myRabbit2 --name rabbit2 -p 15672:15672 -p 5672:5672 --link rabbit1:myRabbit1 -e RABBITMQ_ERLANG_COOKIE='rabbitcookie' rabbitmq:management
docker run -d --hostname myRabbit3 --name rabbit3 -p 15672:15672 -p 5672:5672 --link rabbit1:myRabbit1 --link rabbit2:myRabbit2 -e RABBITMQ_ERLANG_COOKIE='rabbitcookie' rabbitmq:management
~~~
注意：
* -e RABBITMQ_ERLANG_COOKIE='rabbitcookie' 必须设置为相同，因为 Erlang节点间是通过认证Erlang cookie的方式来允许互相通信的。
* --link rabbit1:myRabbit1 --link rabbit2:myRabbit2 不要漏掉，否则会 一直处在 Cluster status of node rabbit@myRabbit3 ... 没有反应
加入集群：
内存节点和磁盘节点的选择：

每个RabbitMQ节点，要么是内存节点，要么是磁盘节点。内存节点将所有的队列、交换器、绑定、用户等元数据定义都存储在内存中；而磁盘节点将元数据存储在磁盘中。单节点系统只允许磁盘类型的节点，否则当节点重启以后，所有的配置信息都会丢失。如果采用集群的方式，可以选择至少配置一个节点为磁盘节点，其余部分配置为内存节点，，这样可以获得更快的响应。所以本集群中配置节点1位磁盘节点，节点2和节点3位内存节点。

集群中的第一个节点将初始元数据代入集群中，并且无须被告知加入。而第2个和之后加入的节点将加入它并获取它的元数据。要加入节点，需要进入Docker容器，重启RabbitMQ。
设置节点1：
~~~
[root@localhost ~]# docker exec -it rabbit1 bash
root@myRabbit1:/# rabbitmqctl stop_app
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Stopping rabbit application on node rabbit@myRabbit1 ...
root@myRabbit1:/# rabbitmqctl reset
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Resetting node rabbit@myRabbit1 ...
root@myRabbit1:/# rabbitmqctl start_app
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Starting node rabbit@myRabbit1 ...
root@myRabbit1:/# exit
exit
~~~
设置节点2：
~~~
[root@localhost ~]# docker exec -it rabbit2 bash
root@myRabbit2:/# rabbitmqctl stop_app
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Stopping rabbit application on node rabbit@myRabbit2 ...
root@myRabbit2:/# rabbitmqctl reset
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Resetting node rabbit@myRabbit2 ...
root@myRabbit2:/# rabbitmqctl join_cluster --ram rabbit@myRabbit1 
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Clustering node rabbit@myRabbit2 with rabbit@myRabbit1
root@myRabbit2:/# rabbitmqctl start_app
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Starting node rabbit@myRabbit2 ...
root@myRabbit2:/# exit
exit
~~~
设置节点3：
~~~
[root@localhost ~]# docker exec -it rabbit3 bash
root@myRabbit3:/# rabbitmqctl stop_app
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Stopping rabbit application on node rabbit@myRabbit3 ...
root@myRabbit3:/# rabbitmqctl reset
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Resetting node rabbit@myRabbit3 ...
root@myRabbit3:/# rabbitmqctl join_cluster --ram rabbit@myRabbit1 
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Clustering node rabbit@myRabbit3 with rabbit@myRabbit1
root@myRabbit3:/# rabbitmqctl start_app
RABBITMQ_ERLANG_COOKIE env variable support is deprecated and will be REMOVED in a future version. Use the $HOME/.erlang.cookie file or the --erlang-cookie switch instead.
Starting node rabbit@myRabbit3 ...
root@myRabbit3:/# exit
exit
~~~

#### RocketMQ5.0 (Local模式)部署
> 详细官方文档参考： https://rocketmq.apache.org/zh/docs/quickStart/02quickstartWithDocker （也有中文）
> 详细中文文档参考： https://rocketmq.io/
* 拉取RocketMQ镜像  
docker pull apache/rocketmq:5.3.1

* 创建容器共享网络  
docker network create rocketmq

* 启动 NameServer  
docker run -d --name rmqnamesrv -p 9876:9876 --network rocketmq apache/rocketmq:5.3.1 sh mqnamesrv

* 验证 NameServer 是否启动成功  
docker logs -f rmqnamesrv

* 启动 Broker+Proxy  
{% tabs Broker_Proxy %}

<!-- tab Linux -->
* 配置 Broker 的 IP 地址
{% note warning simple %}
注意这里官方文档： echo "brokerIP1=127.0.0.1" > broker.conf 这种方式配置后，代码连不上proxy 8081端口
{% endnote %}  
所以改成：本地新建 broker.conf ，写入内容：  
brokerIP1=127.0.0.1
namesrvAddr=xxxx.xxxx.xxx.xxxx:9876 （换成自己服务IP）
autoCreateTopicEnable = true
brokerClusterName = DefaultCluster
~~~
* 启动 Broker 和 Proxy
docker run -d ^
--name rmqbroker ^
--net rocketmq ^
-p 10912:10912 -p 10911:10911 -p 10909:10909 ^
-p 8080:8080 -p 8081:8081 \
-e "NAMESRV_ADDR=rmqnamesrv:9876" ^
-v %cd%\broker.conf:/home/rocketmq/rocketmq-5.3.1/conf/broker.conf ^
apache/rocketmq:5.3.1 sh mqbroker --enable-proxy \
-c /home/rocketmq/rocketmq-5.3.1/conf/broker.conf

* 验证 Broker 是否启动成功
docker exec -it rmqbroker bash -c "tail -n 10 /home/rocketmq/logs/rocketmqlogs/proxy.log"
~~~
<!-- endtab -->

<!-- tab Windows -->

* 配置 Broker 的 IP 地址  
跟上面方式一样
~~~
* 启动 Broker 和 Proxy
docker run -d ^
--name rmqbroker ^
--net rocketmq ^
-p 10912:10912 -p 10911:10911 -p 10909:10909 ^
-p 8080:8080 -p 8081:8081 \
-e "NAMESRV_ADDR=rmqnamesrv:9876" ^
-v %cd%\broker.conf:/home/rocketmq/rocketmq-5.3.1/conf/broker.conf ^
apache/rocketmq:5.3.1 sh mqbroker --enable-proxy \
-c /home/rocketmq/rocketmq-5.3.1/conf/broker.conf

* 验证 Broker 是否启动成功
docker exec -it rmqbroker bash -c "tail -n 10 /home/rocketmq/logs/rocketmqlogs/proxy.log"
~~~
<!-- endtab -->

{% endtabs %}

{% note simple %}
至此，一个单节点副本的 RocketMQ 集群已经部署起来了，我们可以利用脚本进行简单的消息收发。
{% endnote %}

* SDK测试消息收发验证省略（参照官方文档） 

{% note warning simple %}
注意部署的是rocketmq5.0以上的版时，协议为gprc,而老版本用的是remoting协议，故以前的sdk可能连不上新部署的mq,具体参照官方文档
{% endnote %}

