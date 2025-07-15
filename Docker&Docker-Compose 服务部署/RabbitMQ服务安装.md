# Docker&Docker-Compose RabbitMQ 服务部署

## 介绍

> 官方网站：https://www.rabbitmq.com/

RabbitMQ 是开源消息队列，用于异步通信和解耦系统。支持多种协议（AMQP/MQTT等），提供消息持久化、ACK确认等可靠性机制。常用于异步任务、微服务通信和流量削峰。

**特点：**

- 生产者/消费者模式
- 消息路由（Exchange+Queue）
- 集群高可用

**RabbitMQ 核心优势**
- 协议通用：原生支持AMQP，兼容多语言（Python/Java/Go等）。
- 灵活路由：通过Exchange实现扇形/主题/直连/头路由。
- 轻量易用：Erlang开发，低资源占用，快速部署。
- 企业级特性：消息TTL、死信队列、优先级队列等。

## 示例版本：3.9.13-management

## 前期准备工作

1. 创建rabbitmq配置文件路径

```bash
mkdir -p /data/docker/rabbitmq/{data,log,config}

chmod -R 777 /data/docker/rabbitmq
```

2. 拷贝rabbitmq配置文件

```bash
# 启动临时容器
docker run -d --name rabbitmq-server-temp rabbitmq:3.9.13-management
# 拷贝rabbitmq.conf文件
docker cp rabbitmq-server-temp:/etc/rabbitmq/rabbitmq.conf /data/docker/rabbitmq/config/
# 删除临时容器
docker rm -f rabbitmq-server-temp 
```

3. cookie 初始化

```bash
# 1. 生成32位随机数
openssl rand -hex 32
# 2. 对结果进行base64编码设置参数：RABBITMQ_ERLANG_COOKIE
echo -n "【生成的32位随机数】" | base64
```

## Docker 部署

```bash
docker run -d \
  --name rabbitmq-server \
  --hostname rabbitmq \
  --restart always \
  --privileged \
  -p 5672:5672 \
  -p 15672:15672 \
  -v /data/docker/rabbitmq/data:/var/lib/rabbitmq \
  -v /data/docker/rabbitmq/log:/var/log/rabbitmq \
  -v /data/docker/rabbitmq/config/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=admin123 \
  -e RABBITMQ_ERLANG_COOKIE=【进行base64编码的32位随机数】 \
  rabbitmq:3.9.13-management
```

- 参数说明
    + RABBITMQ_DEFAULT_USER：默认用户名
    + RABBITMQ_DEFAULT_PASS：默认密码
    + RABBITMQ_ERLANG_COOKIE：cookie

## Docker-Compose 部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/rabbitmq-server
# 创建配置文件
vim /data/docker-compose-files/rabbitmq-server/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3'
services:
  rabbitmq:
    image: rabbitmq:3.9.13-management
    container_name: rabbitmq-server
    restart: always
    hostname: rabbitmq
    privileged: true
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - /data/docker/rabbitmq/data:/var/lib/rabbitmq
      - /data/docker/rabbitmq/log:/var/log/rabbitmq
      - /data/docker/rabbitmq/config/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin123
      - RABBITMQ_ERLANG_COOKIE=【进行base64编码的32位随机数】
```

- 启动

```bash
docker-compose -f /data/docker-compose-files/rabbitmq-server/docker-compose.yml  up -d 
```

## 常见操作及问题

### 开启rabbitmq_management

```bash
# 进入容器
docker exec -it rabbitmq-server bash

# 由于本次示例 拉取的是 rabbitmq:3.9.13-management ，默认是开启的，则不需要开启
rabbitmq-plugins enable rabbitmq_management
```

### 解决报错: `failed to open log file at '/var/log/rabbitmq/rabbit@rabbitmq_upgrade.log', reason: permission denied`

该报错是由于权限不够导致，解决方法如下：

```bash
# 权限设置
chmod -R 777 /data/docker/rabbitmq/log

# 重启
docker restart rabbitmq-server
```

## 部署成功页面

![rabbitmq1.png](images%2Frabbitmq1.png)