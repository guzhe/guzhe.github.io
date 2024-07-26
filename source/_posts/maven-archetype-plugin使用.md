---
title: maven-archetype-plugin使用
author: guz
tags:
  - maven
categories:
  - 后端技术
cover: 'https://s11.ax1x.com/2024/01/12/pFCrIcF.jpg'
date: 2024-07-28 21:22:18
---
> 导语： 做项目架构时发现公司项目结构不一致导致建项问题多，为了统一使用模版建项，故此使用此maven功能插件

#### 使用总结
1. 在项目 pom.xml 中 添加一下内容  
~~~
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-archetype-plugin</artifactId>
                <version>3.2.0</version>
                <configuration>
                    <propertyFile>archetype.properties</propertyFile>
                </configuration>
            </plugin>
       
~~~
2. 在项目根目录下新建 archetype.properties 内容如下
~~~
# 定义模板groupId
archetype.groupId=org.voice
# 定义模板artifactId（一般以 ‘-archetype’结尾区分）
archetype.artifactId=webTemplateApplication-archetype
archetype.version=1.0
# 排除的文件
excludePatterns=**/.idea/**,**/*.iml
~~~
3. 创建archetype骨架  
在项目根目录下运行以下代码：
~~~
mvn clean archetype:create-from-project
~~~
4.  安装archetype到本地  
进入target/generated-sources/archetype目录下，执行指令：
~~~
mvn clean install
~~~

5.  生成archetype-catalog.xml文件  
~~~
mvn archetype:crawl
~~~

#### 如果需要安装archetype到远程naxus私服  
进入target/generated-sources/archetype目录下，打开此目录下的pom.xml 文件 添加distributionManagement配置后执行 mvn deploy 命令   
> 注：需在maven settings.xml 中增加私服账号密码配置  
~~~
 <distributionManagement>
    <repository>
      <id>maven-releases</id>
      <name>Nexus Releases</name>
      <url>http://10.92.33.112:9081/repository/maven-releases</url>
    </repository>
    <snapshotRepository>
      <id>maven-snapshots</id><!-- id 需要对应 settings 中的配置 id -->
      <name>Nexus Snapshot</name>
      <url>http://10.92.33.112:9081/repository/maven-snapshots/</url>
    </snapshotRepository>
  </distributionManagement>
~~~

#### 使用模版创建项目
1. 工具生成 以idea为例  
 依次选择菜单 file--> new --> project   
 在打开的弹框中 catalog  选择 Default_Local (这个从本地maven仓库中找到模版，之前步骤中已将模版坐标生成到本地的archetype-catalog.xml中)  
 archetype 点击 add 在弹框输入 在（archetype.properties）文件中对应的信息即可

2. 使用脚本bat或shell生成项目

shell

~~~
mvn --version
mvn archetype:generate -B 
-DarchetypeCatalog=http://127.0.0.1:8081/nexus/content/repositories/releases/
-DarchetypeGroupId=xx 
-DarchetypeArtifactId=xx
-DarchetypeVersion=xx
-DgroupId=xx
-DartifactId=xx
-Dversion=xx
~~~

bat
~~~
mvn --version
mvn archetype:generate -B ^
-DarchetypeCatalog=http://127.0.0.1:8081/nexus/content/repositories/releases/
-DarchetypeGroupId=xx
-DarchetypeArtifactId=xx
-DarchetypeVersion=1.0.0 
-DgroupId=xx.xx
-DartifactId=xx
-Dversion=xx
~~~
