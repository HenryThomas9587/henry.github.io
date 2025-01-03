---
title: Flutter开发架构
createTime: 2025/01/03 23:01:24
permalink: /flutter/ai/arch/
---

## Clean 架构简介

Clean 架构是一种软件设计模式，旨在将系统分为不同的层次，每个层次都有明确的职责。它强调：

1. 独立于框架
2. 可测试性
3. 独立于 UI
4. 独立于数据库
5. 独立于任何外部代理

## Flutter 中的 Clean 架构分层

1. **表现层 (Presentation Layer)**

   - 负责 UI 展示和用户交互
   - 包含 Widget、Page、Provider 等
   - 不应包含业务逻辑

2. **领域层 (Domain Layer)**

   - 核心业务逻辑所在
   - 包含 Entity、UseCase、Repository Interface
   - 完全独立于其他层

3. **数据层 (Data Layer)**
   - 负责数据获取和持久化
   - 包含 Repository、DataSource、Model
   - 实现 Domain 层的 Repository 接口

## 开发规则

1. **依赖规则**

   - 依赖方向：presentation -> domain <- data
   - 内层不应知道外层存在

2. **接口隔离**

   - 层与层之间通过接口通信
   - 具体实现依赖抽象

3. **单一职责**

   - 每个类/方法只做一件事
   - 保持代码简洁易维护

4. **测试驱动**

   - 优先编写测试用例
   - 确保各层可独立测试

5. **命名规范**
   - 使用清晰、一致的命名
   - 体现层次和职责

## 目录结构

```dart

lib/
├── core/ # 核心通用代码
│ ├── constant/ # 常量定义
│ ├── error/ # 错误处理
│ ├── network/ # 网络相关
│ ├── util/ # 工具类
│ └── widget/ # 通用 Widgets
│
├── feature/ # 功能模块
│ └── feature_name/ # 具体功能模块
│ ├── data/ # 数据层
│ │ ├── datasource/ # 数据源
│ │ ├── model/ # 数据模型
│ │ └── repository/ # 仓库实现
│ ├── domain/ # 领域层
│ │ ├── entity/ # 实体
│ │ ├── repository/ # 仓库接口
│ │ └── usecase/ # 用例
│ └── presentation/ # 表现层
│ ├── state/ # 状态对象
│ ├── provider/ # Riverpod 状态管理
│ ├── page/ # 页面
│ ├── widget/ # 组件
│
├── app/ # 应用全局配置
│ ├── route/ # 路由配置
│ ├── theme/ # 主题配置
│ └── localization/ # 国际化
│
└── main.dart # 应用入口
```
