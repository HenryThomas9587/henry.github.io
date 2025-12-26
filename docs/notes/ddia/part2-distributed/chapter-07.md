---
title: 第7章 分区
createTime: 2025/12/26 16:13:52
permalink: /ddia/bxqsc20o/
---

# 第7章 分区

> 本章基于 [DDIA 中文翻译](https://ddia.vonng.com/ch7/) 整理

## 章节概览

```mermaid
graph LR
    Root[分区 Partitioning] --> Strategy[分区策略]
    Root --> Index[二级索引分区]
    Root --> Rebalance[再平衡]
    Root --> Routing[请求路由]
    Root --> Hotspot[热点处理]

    Strategy --> KeyRange[键范围分区]
    KeyRange --> KR1[优点: 范围查询高效]
    KeyRange --> KR2[缺点: 热点风险高]

    Strategy --> Hash[哈希分区]
    Hash --> H1[哈希取模: 简单但扩展性差]
    Hash --> H2[一致性哈希: 扩展性好]
    Hash --> H3[固定分区数: 运维可预测]

    Strategy --> Composite[复合分区键]
    Composite --> C1[结合哈希和范围的优点]

    Index --> Local[本地索引 文档分区]
    Local --> L1[写入简单]
    Local --> L2[读取需分散/聚集]

    Index --> Global[全局索引 词条分区]
    Global --> G1[读取高效]
    Global --> G2[写入复杂]

    Rebalance --> R1[固定分区数]
    Rebalance --> R2[动态分区]
    Rebalance --> R3[按节点比例]
    Rebalance --> R4[自动 vs 手动]

    Routing --> RT1[节点转发]
    Routing --> RT2[路由层]
    Routing --> RT3[客户端直连]
    Routing --> RT4[协调服务 ZooKeeper]

    Hotspot --> HS1[应用层分散]
    Hotspot --> HS2[专用分区]
    Hotspot --> HS3[系统自动处理]

    style Root fill:#90CAF9,stroke:#1565C0,stroke-width:3px
    style Strategy fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style Index fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style Rebalance fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style Routing fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style Hotspot fill:#FFE082,stroke:#FF8F00,stroke-width:2px

    style KeyRange fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style Hash fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style Composite fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style Local fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style Global fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px

    style KR1 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style KR2 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style H1 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style H2 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style H3 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style C1 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style L1 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style L2 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style G1 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style G2 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px

    style R1 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style R2 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style R3 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style R4 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style RT1 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style RT2 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style RT3 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style RT4 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style HS1 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style HS2 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
    style HS3 fill:#CE93D8,stroke:#6A1B9A,stroke-width:1px
```

## 概述

分区（Partitioning/Sharding）是将大型数据集分割成更小部分并分布到多个节点的技术。与复制不同，分区的目标是**将数据和查询负载均匀地分布在各节点上**，实现水平扩展。

### 分区的目标

- **可扩展性**：数据量超过单机容量时，分布到多台机器
- **性能**：查询负载分散到多个节点并行处理
- **可用性**：结合复制，提高系统容错能力

## 分区策略

### 键范围分区

为每个分区分配连续的键范围：

```mermaid
graph LR
    A[键空间] --> P1[分区1: A-F]
    A --> P2[分区2: G-M]
    A --> P3[分区3: N-S]
    A --> P4[分区4: T-Z]

    style A fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style P1 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style P2 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style P3 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style P4 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
```

| 优点 | 缺点 |
|------|------|
| 支持高效范围查询 | 容易产生热点 |
| 键在分区内有序存储 | 时间戳等顺序键问题严重 |
| 分区边界可动态调整 | 需要维护分区元数据 |

**热点问题示例**：如果按时间戳分区，所有当天的写入都会集中到同一分区。

### 哈希分区

使用哈希函数将键映射到分区：

#### 哈希取模

```mermaid
graph LR
    K[Key] --> H[hash函数]
    H --> M[取模 % N]
    M --> P[分区编号]

    style K fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style H fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style M fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style P fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
```

**问题**：节点数 N 变化时，几乎所有数据都需要重新分配。

#### 一致性哈希

```mermaid
graph LR
    K[Key] --> H[hash函数]
    H --> R[哈希环上的位置]
    R --> S[顺时针查找]
    S --> N[第一个节点]

    style K fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style H fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style R fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
    style S fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
    style N fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
```

**优点**：节点变化时只影响相邻节点的数据。

#### 固定数量分区

```mermaid
graph LR
    S[系统] --> P[创建固定数量分区<br/>如1000个]
    P --> N1[节点1<br/>管理分区1-250]
    P --> N2[节点2<br/>管理分区251-500]
    P --> N3[节点3<br/>管理分区501-750]
    P --> N4[节点4<br/>管理分区751-1000]

    style S fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style P fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style N1 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style N2 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style N3 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style N4 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
```

**优点**：
- 添加/删除节点时只需重新分配整个分区
- 分区大小相对均匀
- 运维可预测

### 分区策略对比

| 策略 | 范围查询 | 负载均衡 | 热点风险 | 实现复杂度 |
|------|---------|---------|---------|-----------|
| 键范围 | 高效 | 较差 | 高 | 中等 |
| 哈希取模 | 不支持 | 好 | 低 | 简单 |
| 一致性哈希 | 不支持 | 好 | 低 | 中等 |
| 固定分区 | 取决于键 | 好 | 中等 | 中等 |

### 复合分区键

结合哈希和范围分区的优点：

```mermaid
graph LR
    K[复合键:<br/>user_id, timestamp] --> H[按user_id哈希]
    H --> P[确定分区]
    P --> S[分区内按timestamp排序]

    style K fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style H fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style P fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style S fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
```

**应用场景**：社交媒体时间线、用户活动日志等。

## 分区与二级索引

### 本地索引（文档分区）

每个分区维护自己的二级索引，仅覆盖本分区数据：

```mermaid
graph LR
    P1[分区1] --> D1[数据]
    P1 --> I1[本地索引]

    P2[分区2] --> D2[数据]
    P2 --> I2[本地索引]

    P3[分区3] --> D3[数据]
    P3 --> I3[本地索引]

    style P1 fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style P2 fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style P3 fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style D1 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style D2 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style D3 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style I1 fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style I2 fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style I3 fill:#FFE082,stroke:#FF8F00,stroke-width:2px
```

| 优点 | 缺点 |
|------|------|
| 写入简单，只更新本地索引 | 查询需要分散/聚集到所有分区 |
| 分区独立，无跨分区协调 | 读取延迟高，尾延迟问题 |

### 全局索引（词条分区）

索引覆盖所有分区数据，但索引本身也需要分区：

```mermaid
graph LR
    D[所有数据分区] --> I1[索引分区1<br/>A-M]
    D --> I2[索引分区2<br/>N-Z]

    style D fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style I1 fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style I2 fill:#FFE082,stroke:#FF8F00,stroke-width:2px
```

| 优点 | 缺点 |
|------|------|
| 查询效率高，只访问相关分区 | 写入复杂，可能需要更新多个索引分区 |
| 避免分散/聚集 | 可能需要分布式事务 |

## 分区再平衡

### 再平衡策略

| 策略 | 描述 | 优点 | 缺点 |
|------|------|------|------|
| 固定分区数 | 预先创建大量分区 | 简单可预测 | 分区数难以调整 |
| 动态分区 | 分区过大时分裂 | 自适应数据量 | 实现复杂 |
| 按节点比例 | 每个节点固定分区数 | 自动扩展 | 新节点加入时数据迁移 |

### 自动 vs 手动再平衡

**自动再平衡**：
- 优点：方便，无需人工干预
- 缺点：不可预测，可能触发级联故障

**手动再平衡**：
- 优点：可控，可防止意外操作
- 缺点：较慢，需要运维介入

> 许多生产系统选择半自动方式：系统建议再平衡计划，由管理员确认执行。

## 请求路由

### 三种路由方式

```mermaid
graph LR
    C1[客户端] --> N1[任意节点]
    N1 --> N2[转发到正确节点]

    C2[客户端] --> R[路由层]
    R --> N3[正确节点]

    C3[客户端] --> N4[直接连接正确节点]

    style C1 fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style C2 fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style C3 fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style N1 fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style N2 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style R fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
    style N3 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style N4 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
```

### 分区发现

系统需要知道"哪个分区在哪个节点"：

| 方案 | 描述 | 示例 |
|------|------|------|
| 协调服务 | 使用 ZooKeeper/etcd 存储映射 | Kafka, HBase |
| Gossip 协议 | 节点间传播分区信息 | Cassandra, Riak |
| 配置服务 | 中心化配置管理 | MongoDB Config Server |

### ZooKeeper 在分区发现中的作用

```mermaid
graph LR
    N[节点] --> Z[ZooKeeper注册]
    Z --> M[维护分区到节点映射]
    M --> S[路由层/客户端订阅]
    S --> U[分区变化时通知]

    style N fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style Z fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style M fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
    style S fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style U fill:#FFAB91,stroke:#D84315,stroke-width:2px
```

## 热点处理

### 热点产生原因

- 某些键访问频率远高于其他键（如热门用户）
- 时间相关的键导致写入集中
- 数据分布不均匀

### 解决方案

**应用层分散**：

```mermaid
graph LR
    W[写入] --> K[key = original_key + random]
    R[读取] --> Q[查询所有N个变体]
    Q --> M[合并结果]

    style W fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style K fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style R fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style Q fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
    style M fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
```

**专用分区**：
- 将热键放在专用分区
- 为热分区分配更多资源

**系统自动处理**：
- 一些数据库支持自动检测和分散热点

## 多租户分区

分区常用于实现多租户系统：

```mermaid
graph LR
    TA[租户A] --> P1[分区1]
    TA --> P2[分区2]

    TB[租户B] --> P3[分区3]

    TC[租户C] --> P4[分区4]
    TC --> P5[分区5]
    TC --> P6[分区6]

    style TA fill:#90CAF9,stroke:#1565C0,stroke-width:2px
    style TB fill:#FFE082,stroke:#FF8F00,stroke-width:2px
    style TC fill:#CE93D8,stroke:#6A1B9A,stroke-width:2px
    style P1 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style P2 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style P3 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style P4 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style P5 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
    style P6 fill:#A5D6A7,stroke:#2E7D32,stroke-width:2px
```

**优势**：
- 资源隔离和权限隔离
- 基于单元的架构实现故障隔离
- 按租户备份恢复
- 渐进式模式推出

## 核心要点

- 分区是实现水平扩展的关键技术
- 选择分区策略需要权衡范围查询和负载均衡
- 二级索引分区需要在读写效率间权衡
- 再平衡策略影响系统可用性和运维复杂度
- 热点是分区系统的常见挑战，需要专门处理
