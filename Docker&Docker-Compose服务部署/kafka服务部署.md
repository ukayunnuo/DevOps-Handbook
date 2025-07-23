# Docker&Docker-Compose kafka 服务部署

## 介绍

> 官网：https://kafka.apache.org/

Apache Kafka 是一个**开源的分布式流处理平台（Distributed Streaming Platform）**，由 LinkedIn 公司开发并于 2011 年首次发布，后来成为
Apache 基金会的顶级项目。Kafka 被设计用于构建实时数据管道和流应用，具有高吞吐、持久化、水平扩展和容错能力。

---

## 📌 简单介绍

- **来源**：最初由 LinkedIn 开发，后于 2014 年捐赠给 Apache 基金会。
- **语言实现**：使用 Scala 和 Java 编写。
- **定位**：Kafka 不仅仅是一个消息队列系统，它更像一个“实时数据湖”或“事件流平台”。

---

## 🧩 核心功能

Kafka 提供了以下四个核心能力：

1. **发布/订阅消息流（Pub/Sub）**

- 支持多生产者、多消费者的消息广播模型。

2. **存储消息（持久化）**

- 消息会被持久化到磁盘，并支持按时间或偏移量回溯历史数据。

3. **处理流数据（Stream Processing）**

- 可以对消息流进行转换、聚合、过滤等操作（借助 Kafka Streams 或 KSQL）。

4. **高可用与可伸缩**

- 支持分区（Partition）、副本（Replication），具备良好的故障恢复机制。

---

## 🏗️ 架构组成

| 组件                | 描述                                                                            |
|-------------------|-------------------------------------------------------------------------------|
| **Producer（生产者）** | 向 Kafka 发送消息的应用程序。                                                            |
| **Consumer（消费者）** | 从 Kafka 读取消息的应用程序。                                                            |
| **Broker（代理节点）**  | Kafka 的服务节点，负责接收、存储和转发消息。                                                     |
| **Topic（主题）**     | 消息分类的逻辑名称，每条消息必须属于某个 Topic。                                                   |
| **Partition（分区）** | Topic 被分成多个 Partition，用于实现并行处理和水平扩展。                                          |
| **ZooKeeper**     | Kafka 使用 ZooKeeper 进行集群管理、元数据存储、选举协调等工作（注意：Kafka 从 2.8+ 版本开始逐步去 ZooKeeper 化）。 |

---

## 🔍 Kafka 的特点

| 特性         | 说明                                                 |
|------------|----------------------------------------------------|
| **高吞吐量**   | 支持每秒百万级的消息处理。                                      |
| **持久化能力强** | 数据持久化在磁盘上，可靠性高。                                    |
| **横向扩展性强** | 可轻松扩展至数百个节点。                                       |
| **消息重放能力** | 可根据偏移量重新消费历史消息。                                    |
| **容错性好**   | 分区副本机制保证高可用。                                       |
| **生态丰富**   | 提供 Kafka Streams、KSQL、Connect、Schema Registry 等组件。 |

---

## 🎯 典型应用场景

| 场景                       | 描述                                   |
|--------------------------|--------------------------------------|
| **日志收集系统**               | 收集服务器日志、应用程序日志，集中分析处理。               |
| **实时数据分析**               | 与 Flink、Spark Streaming 配合进行实时流式计算。  |
| **运营指标监控**               | 实时采集系统性能指标，用于监控和告警。                  |
| **事件溯源（Event Sourcing）** | 将状态变化记录为事件流，用于重建状态或审计。               |
| **消息队列系统**               | 替代传统消息中间件（如 RabbitMQ、ActiveMQ）做异步通信。 |
| **流式 ETL**               | 在不同系统之间传输和转换数据流。                     |

---

## ✅ 优点

- 吞吐量极高，适合大数据场景
- 持久化机制完善，数据不丢失
- 生态强大，社区活跃
- 支持消息重放，灵活性强
- 天然支持实时流处理

---

## ❌ 局限性

- 相比 RocketMQ 等系统，延迟略高（更适合批量流式处理）
- 部署和运维相对复杂
- 对消息顺序的支持不如 RocketMQ 强
- 默认不支持事务消息（虽然部分版本已支持）

---

## 🔁 与其他MQ的对比表

| 功能 / 系统 | Kafka               | RocketMQ | ActiveMQ | RabbitMQ |
|---------|---------------------|----------|----------|----------|
| 吞吐量     | 极高                  | 高        | 中        | 低        |
| 延迟      | 中高                  | 低        | 中        | 极低       |
| 持久化     | 磁盘为主                | 磁盘为主     | 文件/数据库   | 内存/磁盘    |
| 顺序消息    | 支持（有限）              | 强支持      | 支持       | 支持       |
| 事务消息    | 部分支持                | 强支持      | 支持       | 不支持      |
| 流处理     | 强（内置 Kafka Streams） | 一般       | 一般       | 一般       |
| 社区生态    | 极其丰富                | 成熟       | 成熟       | 成熟       |

---

## 📚 总结：

> **Kafka 是一个面向大规模数据流的高性能、持久化、分布式的事件流平台，适用于日志收集、实时处理、消息队列和事件溯源等场景。**

## 示例版本：3.2.0

## 前期准备工作

### 部署zookeeper服务

由于kafka服务依赖zookeeper服务，所以需要先部署zookeeper服务。[zookeeper服务部署残参考.md](zookeeper%E6%9C%8D%E5%8A%A1%E9%83%A8%E7%BD%B2.md)

### 单机版

- 创建kafka文件夹

```bash
mkdir -p /data/docker/kafka/data
chmod -R 777 /data/docker/kafka
```

### 集群版

```bash
mkdir -p /data/docker/{kafka1,kafka2,kafka3}

chmod -R 777 /data/docker/kafka1
chmod -R 777 /data/docker/kafka2
chmod -R 777 /data/docker/kafka3
```

## Docker 部署

### 单机版部署

```bash
docker run -d \
  --name kafka \
  -p 9092:9092 \
  -e TZ=Asia/Shanghai \
  -e ALLOW_PLAINTEXT_LISTENER=yes \
  -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092 \
  -e KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://192.168.0.126:9092 \
  -e KAFKA_CFG_ZOOKEEPER_CONNECT=192.168.0.126:2181 \
  -v /data/docker/kafka/data:/bitnami/kafka/data \
  bitnami/kafka:3.2.0
```

- 参数说明
    + ALLOW_PLAINTEXT_LISTENER=yes 允许使用明文传输（正式环境不建议开启）
    + KAFKA_CFG_LISTENERS=PLAINTEXT://:9092 指定 kafka 内网地址
    + KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 指定 kafka 外网地址
    + KAFKA_CFG_ZOOKEEPER_CONNECT=192.168.0.126:2181 指定 zookeeper 地址(多个地址用英文逗号隔开)

### 集群版部署

1. 创建共享网络

```bash
docker network create kafka-net
```

2. 启动 Kafka 节点1

```bash
docker run -d \
  --name kafka1 \
  --network kafka-net \
  -p 9092:9092 \
  -e TZ=Asia/Shanghai \
  -e ALLOW_PLAINTEXT_LISTENER=yes \
  -e KAFKA_CFG_BROKER_ID=1 \
  -e KAFKA_CFG_ZOOKEEPER_CONNECT="zk1:2181,zk2:2181,zk3:2181" \
  -e KAFKA_CFG_ADVERTISED_LISTENERS="PLAINTEXT://kafka1:9092,EXTERNAL://<宿主IP>:9092" \
  -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP="PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT" \
  -e KAFKA_CFG_INTER_BROKER_LISTENER_NAME="PLAINTEXT" \
  -e ALLOW_PLAINTEXT_LISTENER="no" \
  -e KAFKA_CFG_SASL_ENABLED_MECHANISMS="PLAIN" \
  -e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL="PLAIN" \
  -e KAFKA_CLIENT_USERS="admin" \
  -e KAFKA_CLIENT_PASSWORDS="kafkapass123" \
  -v /data/docker/kafka1:/bitnami/kafka \
  bitnami/kafka:3.2.0
```

3. 启动 Kafka 节点2

```bash
docker run -d \
  --name kafka2 \
  --network kafka-net \
  -p 9093:9092 \
  -e TZ=Asia/Shanghai \
  -e KAFKA_CFG_BROKER_ID=2 \
  -e KAFKA_CFG_ZOOKEEPER_CONNECT="zk1:2181,zk2:2181,zk3:2181" \
  -e KAFKA_CFG_ADVERTISED_LISTENERS="PLAINTEXT://kafka2:9092,EXTERNAL://<宿主IP>:9093" \
  -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP="PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT" \
  -e KAFKA_CFG_INTER_BROKER_LISTENER_NAME="PLAINTEXT" \
  -e ALLOW_PLAINTEXT_LISTENER="no" \
  -e KAFKA_CFG_SASL_ENABLED_MECHANISMS="PLAIN" \
  -e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL="PLAIN" \
  -e KAFKA_CLIENT_USERS="admin" \
  -e KAFKA_CLIENT_PASSWORDS="kafkapass123" \
  -v /data/docker/kafka2:/bitnami/kafka \
  bitnami/kafka:3.2.0
```

4. 启动 Kafka 节点3

```bash
docker run -d \
  --name kafka3 \
  --network kafka-net \
  -p 9094:9092 \
  -e TZ=Asia/Shanghai \
  -e KAFKA_CFG_BROKER_ID=3 \
  -e KAFKA_CFG_ZOOKEEPER_CONNECT="zk1:2181,zk2:2181,zk3:2181" \
  -e KAFKA_CFG_ADVERTISED_LISTENERS="PLAINTEXT://kafka3:9092,EXTERNAL://<宿主IP>:9094" \
  -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP="PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT" \
  -e KAFKA_CFG_INTER_BROKER_LISTENER_NAME="PLAINTEXT" \
  -e ALLOW_PLAINTEXT_LISTENER="no" \
  -e KAFKA_CFG_SASL_ENABLED_MECHANISMS="PLAIN" \
  -e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL="PLAIN" \
  -e KAFKA_CLIENT_USERS="admin" \
  -e KAFKA_CLIENT_PASSWORDS="kafkapass123" \
  -v /data/docker/kafka3:/bitnami/kafka \
  bitnami/kafka:3.2.0

```

- 参数说明
    + KAFKA_CFG_BROKER_ID：指定 kafka 节点编号
    + KAFKA_CFG_ZOOKEEPER_CONNECT：指定 zookeeper 地址
    + KAFKA_CFG_ADVERTISED_LISTENERS: 指定 kafka 外网地址
    + KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP：指定 kafka 监听协议
    + KAFKA_CFG_INTER_BROKER_LISTENER_NAME：指定 kafka 集群内部监听协议
    + KAFKA_CLIENT_USERS：指定 kafka 用户名
    + KAFKA_CLIENT_PASSWORDS：指定 kafka 用户密码

## Docker-Compose 部署

### 单机版部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/kafka
# 创建配置文件
vim /data/docker-compose-files/kafka/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3'

services:
  kafka:
    image: 'bitnami/kafka:3.2.0'
    container_name: kafka
    restart: always
    ports:
      - "9092:9092"
    environment:
      TZ: Asia/Shanghai
      KAFKA_BROKER_ID: 1
      KAFKA_CFG_LISTENERS: PLAINTEXT://:9092
      KAFKA_CFG_ADVERTISED_LISTENERS: PLAINTEXT://192.168.0.126:9092
      KAFKA_CFG_ZOOKEEPER_CONNECT: 192.168.0.126:2181 # zookeeper 地址
      ALLOW_PLAINTEXT_LISTENER: "yes"
    volumes:
      - /data/docker/kafka/data:/bitnami/kafka/data
```

- 启动

```bash
docker-compose -f /data/docker-compose-files/kafka/docker-compose.yml  up -d 
```

### 集群版部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/kafka
# 创建配置文件
vim /data/docker-compose-files/kafka/docker-compose.yml
```

- kafka docker-compose文件内容

```yaml
version: '3'

services:
  # Kafka 集群
  kafka1:
    image: bitnami/kafka:3.2.0
    container_name: kafka1
    ports:
      - "9092:9092"
    environment:
      TZ: Asia/Shanghai
      KAFKA_CFG_BROKER_ID: 1 # 指定 kafka 节点编号
      KAFKA_CFG_ZOOKEEPER_CONNECT: "zk1:2181,zk2:2181,zk3:2181" # 指定 zookeeper 地址
      KAFKA_CFG_ADVERTISED_LISTENERS: "PLAINTEXT://kafka1:9092,EXTERNAL://宿主IP:9092"  # 替换实际IP
      KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP: "PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT" # 指定 kafka 监听协议
      KAFKA_CFG_INTER_BROKER_LISTENER_NAME: "PLAINTEXT" # 指定 kafka 集群内部监听协议
      ALLOW_PLAINTEXT_LISTENER: "no"  # 禁用明文(生产环境推荐)
      KAFKA_CFG_SASL_ENABLED_MECHANISMS: "PLAIN" # 指定 kafka 用户认证协议
      KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL: "PLAIN" # 指定 kafka 集群内部认证协议
      KAFKA_CLIENT_USERS: "admin" # 用户名
      KAFKA_CLIENT_PASSWORDS: "kafkapass123" # 密码
    volumes:
      - /data/docker/kafka1:/bitnami/kafka
    networks:
      - kafka-net

  kafka2:
    image: bitnami/kafka:3.2.0
    container_name: kafka2
    ports:
      - "9093:9092"
    environment:
      TZ: Asia/Shanghai
      KAFKA_CFG_BROKER_ID: 2
      KAFKA_CFG_ZOOKEEPER_CONNECT: "zk1:2181,zk2:2181,zk3:2181"
      KAFKA_CFG_ADVERTISED_LISTENERS: "PLAINTEXT://kafka2:9092,EXTERNAL://宿主IP:9093"
      KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP: "PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT"
      KAFKA_CFG_INTER_BROKER_LISTENER_NAME: "PLAINTEXT"
      ALLOW_PLAINTEXT_LISTENER: "no"
      KAFKA_CFG_SASL_ENABLED_MECHANISMS: "PLAIN"
      KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL: "PLAIN"
      KAFKA_CLIENT_USERS: "admin"
      KAFKA_CLIENT_PASSWORDS: "kafkapass123"
    volumes:
      - /data/docker/kafka2:/bitnami/kafka
    networks:
      - kafka-net

  kafka3:
    image: bitnami/kafka:3.2.0
    container_name: kafka3
    ports:
      - "9094:9092"
    environment:
      TZ: Asia/Shanghai
      KAFKA_CFG_BROKER_ID: 3
      KAFKA_CFG_ZOOKEEPER_CONNECT: "zk1:2181,zk2:2181,zk3:2181"
      KAFKA_CFG_ADVERTISED_LISTENERS: "PLAINTEXT://kafka3:9092,EXTERNAL://宿主IP:9094"
      KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP: "PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT"
      KAFKA_CFG_INTER_BROKER_LISTENER_NAME: "PLAINTEXT"
      ALLOW_PLAINTEXT_LISTENER: "no"
      KAFKA_CFG_SASL_ENABLED_MECHANISMS: "PLAIN"
      KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL: "PLAIN"
      KAFKA_CLIENT_USERS: "admin"
      KAFKA_CLIENT_PASSWORDS: "kafkapass123"
    volumes:
      - /data/docker/kafka3:/bitnami/kafka
    networks:
      - kafka-net

networks:
  kafka-net:
    driver: bridge

```

- 启动

```bash
docker-compose -f /data/docker-compose-files/kafka/docker-compose.yml  up -d 
```

### kafka-manager 服务部署

- kafka-manager docker-compose文件

```yaml
version: '3'

services:
  kafka-manager:
    image: sheepkiller/kafka-manager:latest
    container_name: kafka-manager
    restart: always
    ports:
      - "19092:19092"
    environment:
      TZ: Asia/Shanghai
      ZK_HOSTS: 192.168.0.126:2181 # zookeeper 地址
      APPLICATION_SECRET: d9b205fc272fb93e
      KAFKA_MANAGER_USERNAME: kafka
      KAFKA_MANAGER_PASSWORD: admin147!
      KM_ARGS: -Dhttp.port=19092

```

## 部署成功页面

访问kafka-manager地址：http://{ip}:19092