---
title: sentinel api分组限流调用链路
categories: 后端技术
tags:
  - git
cover: https://www.helloimg.com/i/2025/06/06/68428fa6d7a82.jpg
date: 2026-05-14 11:29:00
---

#### 启动加载api分组
SpringCloudGatewayApiDefinitionChangeObserver -> GatewayApiMatcherManager.loadApiDefinitions  -> WebExchangeApiMatcher.initializeMatchers

#### 请求时调用链
SentinelGatewayFilter -> pickMatchingApiDefinitions -> GatewayApiMatcherManager.getApiMatcherMap().filter(m -> m.test(exchange))
 
