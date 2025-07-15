# Docker&Docker-Compose RocketMQ 服务部署

## 介绍
> 官方网站：https://rocketmq.apache.ac.cn/

RocketMQ 是一个分布式消息中间件，最初由阿里巴巴集团开发，并在2016年捐赠给了Apache软件基金会，目前是Apache的顶级项目。它设计用于高吞吐量、高可用性和低延迟的消息传递系统，能够支持大规模主题（Topic）和队列（Queue）的高效管理。

## 示例版本：4.9.7

## 前期准备工作

1. 创建文件夹

```bash

# 创建文件夹
mkdir -p /data/docker/rocketmq/nameserver/{logs,store}

mkdir -p /data/docker/rocketmq/broker/{logs,conf,store}

# 创建配置文件
vim /data/docker/rocketmq/broker/conf/broker.conf

# 设置权限
chmod -R 777 /data/docker/rocketmq/

```

- broker 配置文件内容

```bash
brokerClusterName = DefaultCluster
brokerName = broker-a
brokerId = 0 # 0表示 Master Broker,1表示 Slave Broker
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
autoCreateTopicEnable=true
autoCreateSubscriptionGroup=true
brokerIP1 = 192.168.0.12  # 指定 Broker 对外的 IP
```

## Docker 部署

### 创建docker网络
```bash
docker network create rocketmq
```

### 1. 启动 NameServer
```bash
docker run -d \
  --name rocket-server \
  --restart always \
  -e JAVA_OPT_EXT="-Xms512m -Xmx512m -Xmn256m" \
  -v /data/docker/rocketmq/logs:/home/rocketmq/logs \
  -p 9876:9876 \
  --network rocketmq \
  apache/rocketmq:4.9.7 \
  sh mqnamesrv
```

### 2. 启动 Broker
```bash
docker run -d \
  --name rocket-broker \
  --restart always \
  -v /data/docker/rocketmq/broker/logs:/home/rocketmq/logs \
  -v /data/docker/rocketmq/broker/store:/home/rocketmq/store \
  -v /data/docker/rocketmq/broker/conf/broker.conf:/opt/rocketmq-4.9.4/conf/broker.conf \
  -e NAMESRV_ADDR="rocket-server:9876" \
  -e JAVA_OPT_EXT="-Xms1g -Xmx1g -Xmn512m" \
  -p 10909:10909 \
  -p 10911:10911 \
  -p 10912:10912 \
  --network rocketmq \
  --depends_on rocket-server \
  apache/rocketmq:4.9.7 \
  sh mqbroker -c /opt/rocketmq-4.9.4/conf/broker.conf
```
### 3. 启动 Dashboard
```bash
docker run -d \
  --name rocketmq-dashboard \
  --restart always \
  -e NAMESRV_ADDR="rocket-server:9876" \
  -p 8080:8080 \
  --network rocketmq \
  --depends_on rocket-server \
  apacherocketmq/rocketmq-dashboard:latest
```

- **NameServer**：运行在 9876 端口，负责服务发现。
- **Broker**：运行在 10909、10911、10912 端口，负责消息存储和转发。
- **Dashboard**：运行在 8080 端口，提供 Web 管理界面。

## Docker-Compose 部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/rocketmq
# 创建配置文件
vim /data/docker-compose-files/rocketmq/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3'
services:
  nameserver:
    image: apache/rocketmq:4.9.7
    restart: always
    container_name: rocket-server
    environment:
      - JAVA_OPT_EXT=-Xms512m -Xmx512m -Xmn256m
    volumes:
      - /data/docker/rocketmq/logs:/home/rocketmq/logs
    networks:
      - rocketmq
    ports:
      - 9876:9876
    command: sh mqnamesrv
  # rocket mq broker
  broker:
    image: apache/rocketmq:4.9.7
    restart: always
    container_name: rocket-broker
    volumes:
      - /data/docker/rocketmq/broker/logs:/home/rocketmq/logs
      - /data/docker/rocketmq/broker/store:/home/rocketmq/store
      - /data/docker/rocketmq/broker/conf/broker.conf:/opt/rocketmq-4.9.4/conf/broker.conf
    environment:
      - NAMESRV_ADDR=rmqnamesrv:9876
      - JAVA_OPT_EXT=-Xms1g -Xmx1g -Xmn512m
    depends_on:
      - rmqnamesrv
    networks:
      - rocketmq
    ports:
      - "10909:10909"  # Broker 端口
      - "10911:10911"  # Broker HA 端口
      - "10912:10912"  # Broker TLS 端口
    command: sh mqbroker -c /opt/rocketmq-4.9.4/conf/broker.conf

  # RocketMQ Console (Dashboard)
  dashboard:
    image: apacherocketmq/rocketmq-dashboard:latest
    container_name: rocketmq-dashboard
    networks:
      - rocketmq
    ports:
      - "8080:8080"
    environment:
      - NAMESRV_ADDR=nameserver:9876
    depends_on:
      - nameserver
    restart: always

```

- 启动

```bash
docker-compose -f /data/docker-compose-files/xxx/docker-compose.yml  up -d 
```

## 部署成功页面

**访问 RocketMQ Dashboard**

- Dashboard URL: http://ip:8080
- NameServer 地址: ip:9876
