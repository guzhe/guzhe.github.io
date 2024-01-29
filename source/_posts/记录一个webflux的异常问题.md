---
title: 记录一个webflux的异常问题
author: guz
tags:
  - webflux
categories:
  - 后端技术
cover: 'https://s11.ax1x.com/2024/01/11/pFCmN8S.jpg'
date: 2023-11-01 17:22:18
---


#### 问题描述

webflux 中发现一个正常接口中远程调用其他第三方接口，会出现系统阻塞假死。请看如下代码：

```java
@PostMapping("/messageList")
    public GpResponse<List<IWebSocketMessage>> messageList(@RequestBody @Validated MessageListReqVo reqVo) throws ExecutionException, InterruptedException {
      //post 请求本地服务的另一个接口
       HttpUtil.post("http://127.0.0.1:8087/messageDetail", "{\"messageId\":12345}");
        log.info(" === End ===");
        return GpResponse.success();
    }
```

用apifox 压测 例如：循环次数40次，线程数 5次  系统出现接口卡死无法返回的现象

#### 问题解决方案

1. 方法返回值定义为mono 或者 flux

```java
 @PostMapping("/getOnlineClient")
    public Flux<String> getOnlineClient(@RequestBody @Valid MessageListReqVo reqVo) {
        List<OnlineClientRespModel> ts = iWebSocketMessageService.getBaseMapper().selectList(queryWrapper);
        Flux<IWebSocketMessage> flux = Flux.fromIterable(ts)
                .delaySubscription(Duration.ofMillis(250))
                .delayElements(Duration.ofMillis(1000));
        flux.subscribe(f -> log.info("Here's some message:" + f));
        log.info(" === End ===");
       Mono.justOrEmpty(Optional.of(HttpUtil.post("http://127.0.0.1:8087/messageDetail", "{\"messageId\":12345}"))).subscribe(System.out::println); 
         return flux;
        }
        
```



1. 方法中调用第三方接口时采用异步方式处理 例如：

   ```java
   final ExecutorService executorService = Executors.newSingleThreadExecutor();   
   @PostMapping("/messageList")
       public GpResponse<List<IWebSocketMessage>> messageList(@RequestBody @Validated MessageListReqVo reqVo) throws ExecutionException, InterruptedException {
           //QueryWrapper<IWebSocketMessage> queryWrapper = new QueryWrapper<>();
           //queryWrapper.eq("message_platform", reqVo.getMessagePlatform());
           //queryWrapper.and(qr -> qr.eq("message_mode", "1")).or(qr -> qr.like(reqVo.getMessageReceiver() != null, "receiver", reqVo.getMessageReceiver()).like(reqVo.getMessageTitle() != null, "message_title", reqVo.getMessageTitle()));
          // queryWrapper.orderByDesc("created_time");
   //        PageHelper.startPage(1, 5);
   //        List<IWebSocketMessageEntity> ts = //iWebSocketMessageService.getBaseMapper().selectList(queryWrapper);
           Future future =executorService.submit(() ->
                   HttpUtil.post("http://127.0.0.1:8087/messageDetail", "{\"messageId\":12345}")
           );
           future.get();
           log.info(" === End ===");
           return GpResponse.success();
       }
   ```

   



#### 问题原因

待分析