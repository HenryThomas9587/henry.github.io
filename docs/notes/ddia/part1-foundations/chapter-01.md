---
title: 第1章 可靠性、可扩展性与可维护性
createTime: 2025/12/26 16:04:08
permalink: /ddia/670y7cuq/
---

# 第1章 可靠性、可扩展性与可维护性

> 本章基于 [DDIA 中文翻译](https://ddia.vonng.com/ch1/) 整理

## 章节概览

```mermaid
graph LR
    ROOT[第1章 总览] --> A[三大目标]
    ROOT --> B[核心概念]
    ROOT --> C[架构权衡]
    ROOT --> D[法律与社会因素]

    A --> A1[可靠性]
    A --> A2[可扩展性]
    A --> A3[可维护性]

    B --> B1[数据密集型 vs 计算密集型]
    B --> B2[数据系统的组合]

    C --> C1[OLTP vs OLAP]
    C --> C2[单节点 vs 分布式]
    C --> C3[云服务 vs 自托管]

    style ROOT fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style A fill:#FFAB91,stroke:#D84315,stroke-width:2px
    style B fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style C fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style D fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
    style A1 fill:#FFCDD2,stroke:#E57373,stroke-width:2px
    style A2 fill:#FFCDD2,stroke:#E57373,stroke-width:2px
    style A3 fill:#FFCDD2,stroke:#E57373,stroke-width:2px
    style B1 fill:#C8E6C9,stroke:#81C784,stroke-width:2px
    style B2 fill:#C8E6C9,stroke:#81C784,stroke-width:2px
    style C1 fill:#FFECB3,stroke:#FFC107,stroke-width:2px
    style C2 fill:#FFECB3,stroke:#FFC107,stroke-width:2px
    style C3 fill:#FFECB3,stroke:#FFC107,stroke-width:2px
```

## 核心概念

### 什么是数据密集型应用

当数据存储与处理成为系统主要挑战时，该系统就是**数据密集型**应用。与"计算密集型"不同，这类系统关注的是**大规模数据的存储、变化管理、一致性和高可用性设计**。

### 数据系统的构成

数据密集型应用通常由多个系统组合而成：

```mermaid
graph TB
    subgraph 应用层
        APP[应用程序代码]
    end

    subgraph 数据存储层
        DB[(数据库<br/>持久化)]
        CACHE[(缓存<br/>加速)]
        SEARCH[(搜索引擎<br/>检索)]
        MQ[(消息队列<br/>异步)]
    end

    subgraph 数据处理层
        BATCH[批处理/流处理<br/>数据分析]
    end

    APP --> DB
    APP --> CACHE
    APP --> SEARCH
    APP --> MQ

    DB --> BATCH
    CACHE --> BATCH
    SEARCH --> BATCH
    MQ --> BATCH

    style APP fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style DB fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style CACHE fill:#FFAB91,stroke:#D84315,stroke-width:2px
    style SEARCH fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style MQ fill:#B39DDB,stroke:#512DA8,stroke-width:2px
    style BATCH fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
```

| 组件 | 作用 |
|------|------|
| 数据库 | 持久存储数据 |
| 缓存 | 加速频繁访问 |
| 搜索引擎/索引 | 支持复杂搜索 |
| 流处理 | 实时事件处理 |
| 批处理 | 周期性处理大量数据 |

## 三大设计目标

```mermaid
graph LR
    ROOT[数据密集型应用设计] --> R[可靠性<br/>Reliability]
    ROOT --> S[可扩展性<br/>Scalability]
    ROOT --> M[可维护性<br/>Maintainability]

    R --> R1[硬件故障]
    R --> R2[软件Bug]
    R --> R3[人为错误]

    S --> S1[数据量增长]
    S --> S2[流量增长]
    S --> S3[并发用户增长]

    M --> M1[可操作性]
    M --> M2[简单性]
    M --> M3[可演化性]

    style ROOT fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style R fill:#FFAB91,stroke:#D84315,stroke-width:2px
    style S fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style M fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style R1 fill:#FFCDD2,stroke:#E57373,stroke-width:2px
    style R2 fill:#FFCDD2,stroke:#E57373,stroke-width:2px
    style R3 fill:#FFCDD2,stroke:#E57373,stroke-width:2px
    style S1 fill:#C8E6C9,stroke:#81C784,stroke-width:2px
    style S2 fill:#C8E6C9,stroke:#81C784,stroke-width:2px
    style S3 fill:#C8E6C9,stroke:#81C784,stroke-width:2px
    style M1 fill:#FFECB3,stroke:#FFC107,stroke-width:2px
    style M2 fill:#FFECB3,stroke:#FFC107,stroke-width:2px
    style M3 fill:#FFECB3,stroke:#FFC107,stroke-width:2px
```

### 可靠性（Reliability）

系统在发生故障时仍能正确工作，包括应对：
- 硬件故障
- 软件 Bug
- 人为错误

> **故障（fault）不可避免，但失败（failure）是可以避免的。**

### 可扩展性（Scalability）

系统在负载增长时仍能保持性能。需要关注：
- 数据量增长
- 流量增长
- 并发用户数增长

**性能衡量指标**：推荐使用百分位延迟（p50/p95/p99）而非平均值，因为平均值会掩盖尾部延迟问题。

### 可维护性（Maintainability）

包含三个方面：
- **可操作性**：易监控、易诊断、易恢复
- **简单性**：降低系统复杂度
- **可演化性**：面对需求变化可调整

## 架构权衡

### 事务型系统 vs 分析型系统

| 特性 | OLTP（事务型） | OLAP（分析型） |
|------|---------------|---------------|
| 访问模式 | 点查询（读/写少量记录） | 聚合查询（扫描大量数据） |
| 典型用途 | 实时业务操作 | 商业分析、报表 |
| 数据大小 | 中等 | 通常很大 |
| 延迟要求 | 毫秒级 | 秒/分钟级 |
| 优化目标 | 响应时间 | 数据吞吐量 |

两者常分离部署以避免互相影响性能。

### 单节点系统 vs 分布式系统

| 维度 | 单机系统 | 分布式系统 |
|------|---------|-----------|
| 复杂性 | 低 | 高 |
| 可扩展性 | 有限 | 强 |
| 容错性 | 弱 | 强 |
| 适用场景 | 小负载 | 海量负载 |

> **不要为了"看起来高级"而做分布式。** 分布式是被"逼出来的"选择。

### 云服务 vs 自托管

**云服务**：
- 优势：自动扩缩、内建高可用、降低运维成本
- 劣势：成本不可预测、控制性有限

**自托管**：
- 优势：高可控、可自定义优化
- 劣势：运维复杂、弹性资源较弱

## 数据系统与社会

现代系统设计还需考虑：
- 数据隐私与安全合规（如 GDPR）
- 用户权利与审计要求
- 社会影响与伦理问题

## 核心理念

- 系统设计的核心是理解各种选择的利弊，在需求和资源之间找到最合适的平衡点
- 没有完美方案，只有权衡
- 简单，是一种长期竞争力
