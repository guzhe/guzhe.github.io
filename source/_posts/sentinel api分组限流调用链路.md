---
title: sentinel api分组限流调用链路
categories: 后端技术
tags:
  - sentinel
cover: https://cdn.pixabay.com/photo/2026/05/14/06/42/ninalozej-jamniki-10279027_1280.jpg
date: 2026-05-14 11:29:00
---

#### 启动加载api分组
SpringCloudGatewayApiDefinitionChangeObserver -> GatewayApiMatcherManager.loadApiDefinitions  -> WebExchangeApiMatcher.initializeMatchers

#### 请求时调用链
SentinelGatewayFilter -> pickMatchingApiDefinitions -> GatewayApiMatcherManager.getApiMatcherMap().filter(m -> m.test(exchange))
 
