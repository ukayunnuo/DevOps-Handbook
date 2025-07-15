# Docker&Docker-Compose ActiveMQ 服务部署

## 介绍
> 官网：https://activemq.apache.org/

ActiveMQ 是Apache软件基金会下的一个开源消息服务器，它实现了消息队列（Message Queue）的功能，支持Java消息服务（JMS）2.0规范，同时也支持多种跨语言客户端和协议。ActiveMQ 主要用于应用之间的异步通信，能够帮助解决系统间的解耦、流量削峰、日志处理等需求。

### 主要特点
- **多协议支持**：除了支持标准的JMS之外，还支持AMQP、STOMP、MQTT等多种协议，这使得它可以与不同平台和技术栈进行集成。
- **灵活的部署方式**：可以以嵌入式、网络连接或主从复制等方式部署，适应不同的应用场景和需求。
- **高可用性和可扩展性**：通过使用Master-Slave架构和网络分区（Network of Brokers），实现高可用性和水平扩展能力。
- **安全性**：提供基于角色的访问控制（RBAC）、传输层安全（TLS/SSL）加密等功能，确保消息的安全传输。
- **易于使用**：提供了简单易用的API，以及与Spring等框架的良好集成能力，方便开发者快速上手。

### 适用场景
- **企业级应用集成**：作为不同系统之间数据交换和通信的桥梁，帮助企业实现系统的松散耦合。
- **实时处理**：适合需要实时处理的应用场景，如交易处理系统、在线支付平台等。
- **大规模分布式系统**：在大型分布式系统中，用于服务间的消息传递，提高系统的可靠性和伸缩性。
- **物联网（IoT）**：支持MQTT协议，非常适合用于物联网设备的数据收集和管理。


## 示例版本：5.14.3

## 前期准备工作

- 创建activemq文件路径

```bash
mkdir -p /data/docker/activemq/{data,log}
chmod 777 -R /data/docker/activemq
```

## Docker 部署
```bash
docker run -d \
  --name activemq-server \
  --restart always \
  -p 61613:61613 \
  -p 61616:61616 \
  -p 8161:8161 \
  -v /data/docker/activemq/data:/data/activemq \
  -v /data/docker/activemq/log:/var/log/activemq \
  -e TZ=Asia/Shanghai \
  -e ACTIVEMQ_ADMIN_LOGIN=admin \
  -e ACTIVEMQ_ADMIN_PASSWORD=activemq2024 \
  -e ACTIVEMQ_CONFIG_MINMEMORY=128 \
  -e ACTIVEMQ_CONFIG_MAXMEMORY=1024 \
  webcenter/activemq:5.14.3
```

## Docker-Compose 部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/activemq
# 创建配置文件
vim /data/docker-compose-files/activemq/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3.0'
services:
  activemq:
    image: webcenter/activemq:5.14.3
    container_name: activemq-server
    restart: always
    ports:
      - 61613:61613 # STOMP 协议端口
      - 61616:61616 # OpenWire 协议端口（默认消息协议）
      - 8161:8161 # Web 管理控制台端口
    volumes:
      - /data/docker/activemq/data:/data/activemq
      - /data/docker/activemq/log:/var/log/activemq
    environment:
      - TZ=Asia/Shanghai
      - ACTIVEMQ_ADMIN_LOGIN=admin
      - ACTIVEMQ_ADMIN_PASSWORD=activemq2024
      - ACTIVEMQ_CONFIG_MINMEMORY=128
      - ACTIVEMQ_CONFIG_MAXMEMORY=1024
```

- 参数说明
    + ACTIVEMQ_ADMIN_LOGIN：管理用户名
    + ACTIVEMQ_ADMIN_PASSWORD：管理密码
    + ACTIVEMQ_CONFIG_MINMEMORY：最小内存
    + ACTIVEMQ_CONFIG_MAXMEMORY：最大内存

- 启动

```bash
docker-compose -f /data/docker-compose-files/activemq/docker-compose.yml  up -d 
```

## 部署成功页面
**访问 Web 控制台：**
地址：http://<服务器IP>:8161
用户名：admin
密码：activemq2024