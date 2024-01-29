---
title: apifox接口测试工具使用分享
author: guz
tags:
  - 工具
categories:
  - 开发
cover: https://s11.ax1x.com/2024/01/11/pFCmavQ.jpg
date: 2023-10-21 21:22:18
---
#### apifox介绍
> 今天分享一下apifox工具使用
> apifox是阿里开发的一款集API 文档、API 调试、API Mock、API 自动化测试于一体的协助工具
> Apifox = Postman + Swagger + Mock + JMeter
>
> 基础的使用就不用多介绍了，下面介绍一些常用的高级特性





#### apifox-环境维护

> 使用场景：为了方便一个项目服务在多个环境发布后中进行接口测试，比如本地开发环境、mit、sit、prod等等
>
> 使用介绍：新建一个演示项目001后，点击右上角可以进入管理环境页面可以维护本地开发，测试，生产等环境
>
> 通过gayway路由的微服务添加测试环境时带上服务名，本地测试不加



#### apifox-接口维护

> 在项目接口管理中维护一个接口有三种方式
>
> - 手动添加
>
>   在接口管理中新建接口手动维护，如果只是想简单测一下项目接口地址可以建一个快捷请求
>
> - 手动导入添加
>
>   点击项目设置，在数据管理中有个导入数据, 导入分手动导入和定时导入，手动导入都是导入各种类型的数据文件 支持的还挺全面
>
> - 定时同步添加或更新
>
>   在项目设置->数据管理中的定时导入可以根据设置的url 和频次进行定时更新接口文档，维护好后可以手动触发更新

#### 	

#### apifox-压测

> 在项目自动化测试中添加测试场景 - 测试场景001， 添加步骤 可以接口导入，测试用例导入也可以自定义
>
> 接口导入选择需要测试的接口，最右边有设置运行配置 如：循环次数，线程数。

​	

#### apifox-脚本使用

> 接口中前置操作或后置操作可以添加脚本。例如以下接口脚本，此接口请求前需要获取上个接口中的响应token，然后放置在请求头上再去请求
>
> ```javascript
> // 获取环境里的 前置 URL
> const baseUrl = pm.request.getBaseUrl();
> 
> const loginRequest = {
>   url: baseUrl + "/ehr-service/foreignApi/token/getToken",
>   method: "POST",
>    header: {
>     "Content-Type": "application/json", // 注意：header 需要加上 Content-Type
>   },
>   body: {
>     mode: 'raw',// 此处为 raw
>     raw: JSON.stringify({ appId: 'wlxz0001', appSecret:'135873E92784809A0B68B5511456CB85' }), // 序列化后的 json 字符串
>   }
> }
> pm.sendRequest(loginRequest, function(err, response) {
>   console.log(response.json());
> 
> // 获取 Header 参数对象
>   var headers = pm.request.headers;
>   // 修改 header 参数（如不存在则新增）
>   headers.upsert({
>   key: "token",
>   value: response.json().body.token,
>   });
> });
> 
> ```
>
> 可以参考：[登录态（Auth）如何处理 | Apifox 帮助文档](https://apifox.com/help/best-practices/how-to-handle-auth)
>
> 提示：最后饭有代码片段提示，点高级功能可以调转到帮助文档
>
> 1. 环境变量
>
>    ```javascript
>    *// 设置环境变量*
>    pm.environment.set('variable_key', 'variable_value');
>          
>    *// 获取环境变量*
>    var variable_key = pm.environment.get('variable_key');
>          
>    *// unset 环境变量*
>    pm.environment.unset('variable_key');
>    ```
>
>    读取的时候，需要使用`JSON.parse`转换回来
>
>    ```javascript
>    var array = [1, 2, 3, 4];
>    pm.environment.set('array', JSON.stringify(array));
>          
>    var obj = { a: [1, 2, 3, 4], b: { c: 'val' } };
>    pm.environment.set('obj', JSON.stringify(obj));
>          
>    try {
>      var array = JSON.parse(pm.environment.get('array'));
>      var obj = JSON.parse(pm.environment.get('obj'));
>    } catch (e) {
>      // 处理异常
>    }
>    ```
>
>    
>
> 2. 全局变量
>
>    ```javascript
>    // 设置全局变量
>    pm.globals.set('variable_key', 'variable_value');
>          
>    // 获取全局变量
>    var variable_key = pm.globals.get('variable_key');
>          
>    // unset 全局变量
>    pm.globals.unset('variable_key');
>    ```
>
>    
>
> 3. 临时变量
>
>    ```javascript
>    // 设置临时变量
>    pm.variables.set('variable_key', 'variable_value');
>          
>    // 获取临时变量
>    var variable_key = pm.variables.get('variable_key');
>          
>    // unset 临时变量
>    pm.variables.unset('variable_key');
>    ```
>
>    
>
> 4. URL 相关信息
>
>    ```javascript
>    // 获取 url 对象
>    var urlObj = pm.request.url;
>          
>    // 获取完整接口请求 URL，包含 query 参数
>    var url = urlObj.toString();
>          
>    // 获取协议（http 或 https）
>    var protocol = urlObj.protocol;
>          
>    // 获取 端口
>    var port = urlObj.port;
>    ```
>
>    
>
> 5. Header 参数
>
>    获取header参数
>
>    ```javascript
>    // 获取 Header 参数对象
>    var headers = pm.request.headers;
>          
>    // 获取 key 为 field1 的 header 参数的值
>    var field1 = headers.get("field1");
>          
>    // 已键值对象方式获取所有 header 参数
>    var headersObject = headers.toObject();
>          
>    // 遍历整个 header
>    headers.each((item) => {
>      console.log(item.key); // 输出参数名
>      console.log(item.value); // 输出参数值
>    });
>    ```
>
>    修改 header 参数
>
>    ```javascript
>    // 获取 Header 参数对象
>    var headers = pm.request.headers;
>          
>    // 增加 header 参数
>    headers.add({
>      key: "field1",
>      value: "value1",
>    });
>          
>    // 修改 header 参数（如不存在则新增）
>    headers.upsert({
>      key: "field2",
>      value: "value2",
>    });
>    ```
>
>    更多使用示例：
>
>    [脚本使用变量 | Apifox 帮助文档](https://apifox.com/help/pre-post-processors-and-scripts/scripts/examples/variables)
>
>    [pm 对象 API | Apifox 帮助文档](https://apifox.com/help/pre-post-processors-and-scripts/scripts/api-references/pm-reference)
>
>    
>
>    
>
>    
>
>    

