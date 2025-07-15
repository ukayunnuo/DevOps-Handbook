# Docker&Docker-Compose zookeeper 服务部署

## 介绍
> 官网：https://zookeeper.apache.org/

ZooKeeper 是一个开源的分布式协调服务，最初由 Apache 开发，主要用于解决分布式系统中的一致性问题。它提供了一组简单的原语（接口），帮助开发者在分布式环境中实现诸如配置管理、服务发现、分布式锁、选举主节点等核心功能。

## 示例版本：3.8.0

## 前期准备工作

### 单机版部署

- 创建zookeeper文件路径

```bash
mkdir -p /data/docker/zookeeper/data

chmod -R 777 /data/docker/zookeeper
```

### 集群版部署

- 创建zookeeper文件路径

```bash
mkdir -p /data/docker/{zk1,zk2,zk3}/data

# 设置权限
chmod -R 777 /data/docker/zk1
chmod -R 777 /data/docker/zk2
chmod -R 777 /data/docker/zk3
```

## Docker 部署

### 单机版部署

```bash
docker run -d \
  --name zookeeper \
  -p 2181:2181 \
  -e TZ=Asia/Shanghai \
  -e ALLOW_ANONYMOUS_LOGIN=yes \
  -e ZOO_SERVER_ID=1 \
  -e ZOO_PORT_NUMBER=2181 \
  -v /data/docker/zookeeper/data:/bitnami/zookeeper/data \
  --restart always \
  bitnami/zookeeper:3.8.0
```

### 集群版部署

1. 创建共享网络

```bash
docker network create zk-net
```

2. 启动 zk1（节点1）

```bash
docker run -d \
  --name zk1 \
  --network zk-net \
  -p 2181:2181 \
  -p 2888:2888 \
  -p 3888:3888 \
  -e TZ=Asia/Shanghai \
  -e ALLOW_ANONYMOUS_LOGIN=no \
  -e ZOO_SERVER_ID=1 \
  -e ZOO_SERVERS="zk1:2888:3888,zk2:2889:3889,zk3:2890:3890" \
  -e ZOO_ENABLE_AUTH=yes \
  -e ZOO_CLIENT_USER=admin \
  -e ZOO_CLIENT_PASSWORD=zookeeper123 \
  -v /data/docker/zk1/data:/bitnami/zookeeper/data \
  --restart always \
  bitnami/zookeeper:3.8.0 
```

2. 启动 zk2（节点2）

```bash
docker run -d \
  --name zk2 \
  --network zk-net \
  -p 2182:2181 \
  -p 2889:2888 \
  -p 3889:3888 \
  -e TZ=Asia/Shanghai \
  -e ALLOW_ANONYMOUS_LOGIN=no \
  -e ZOO_SERVER_ID=2 \
  -e ZOO_SERVERS="zk1:2888:3888,zk2:2889:3889,zk3:2890:3890" \
  -e ZOO_ENABLE_AUTH=yes \
  -e ZOO_CLIENT_USER=admin \
  -e ZOO_CLIENT_PASSWORD=zookeeper123 \
  -v /data/docker/zk2/data:/bitnami/zookeeper/data \
  --restart always \
  bitnami/zookeeper:3.8.0 
```

3. 启动 zk3（节点3）

```bash
docker run -d \
  --name zk3 \
  --network zk-net \
  -p 2183:2181 \
  -p 2890:2888 \
  -p 3890:3888 \
  -e TZ=Asia/Shanghai \
  -e ALLOW_ANONYMOUS_LOGIN=no \
  -e ZOO_SERVER_ID=3 \
  -e ZOO_SERVERS="zk1:2888:3888,zk2:2889:3889,zk3:2890:3890" \
  -e ZOO_ENABLE_AUTH=yes \
  -e ZOO_CLIENT_USER=admin \
  -e ZOO_CLIENT_PASSWORD=zookeeper123 \
  -v /data/docker/zk3/data:/bitnami/zookeeper/data \
  --restart always \
  bitnami/zookeeper:3.8.0 
```

**端口映射：**

- 客户端端口：2181-2183（分别对应三个节点）
- 数据同步端口：2888-2890（必须映射且宿主机端口不冲突）
- 选举端口：3888-3890（必须映射且宿主机端口不冲突）

## Docker-Compose 部署

### 单机版部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/zookeeper
# 创建配置文件
vim /data/docker-compose-files/zookeeper/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3'

services:
  zookeeper:
    image: 'bitnami/zookeeper:3.8.0'
    container_name: zookeeper
    restart: always
    ports:
      - 2181:2181
    environment:
      TZ: Asia/Shanghai
      ALLOW_ANONYMOUS_LOGIN: "yes"
      ZOO_SERVER_ID: 1
      ZOO_PORT_NUMBER: 2181
    volumes:
      - '/data/docker/zookeeper/:/bitnami/zookeeper/data'
    networks:
      - zookeeper_network

```

- 启动

```bash
docker-compose -f /data/docker-compose-files/zookeeper/docker-compose.yml  up -d 
```

### 集群版部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/zookeeper
# 创建配置文件
vim /data/docker-compose-files/zookeeper/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3'
services:
  zk1:
    image: bitnami/zookeeper:3.8.0
    container_name: zk1
    ports:
      - "2181:2181"  # 客户端端口
      - "2888:2888"  # 新增：数据同步端口
      - "3888:3888"  # 新增：选举端口
    environment:
      TZ: Asia/Shanghai
      ALLOW_ANONYMOUS_LOGIN: "no"                  # 禁用匿名访问
      ZOO_SERVER_ID: 1
      ZOO_SERVERS: "zk1:2888:3888,zk2:2889:3889,zk3:2890:3890"
      ZOO_ENABLE_AUTH: "yes"                       # 启用认证
      ZOO_CLIENT_USER: "admin"                     # 客户端用户名
      ZOO_CLIENT_PASSWORD: "zookeeper123"          # 客户端密码
    volumes:
      - /data/docker/zk1/data:/bitnami/zookeeper/data
    networks:
      - zk-net
    restart: always

  zk2:
    image: bitnami/zookeeper:3.8.0
    container_name: zk2
    ports:
      - "2182:2181"  # 客户端端口
      - "2889:2888"  # 新增：数据同步端口（避免宿主机端口冲突）
      - "3889:3888"  # 新增：选举端口（避免宿主机端口冲突）
    environment:
      TZ: Asia/Shanghai
      ALLOW_ANONYMOUS_LOGIN: "no"
      ZOO_SERVER_ID: 2
      ZOO_SERVERS: "zk1:2888:3888,zk2:2889:3889,zk3:2890:3890"
      ZOO_ENABLE_AUTH: "yes"
    volumes:
      - /data/docker/zk2/data:/bitnami/zookeeper/data
    networks:
      - zk-net
    restart: always

  zk3:
    image: bitnami/zookeeper:3.8.0
    container_name: zk3
    ports:
      - "2183:2181"  # 客户端端口
      - "2890:2888"  # 新增：数据同步端口
      - "3890:3888"  # 新增：选举端口
    environment:
      TZ: Asia/Shanghai
      ALLOW_ANONYMOUS_LOGIN: "no"
      ZOO_SERVER_ID: 3
      ZOO_SERVERS: "zk1:2888:3888,zk2:2889:3889,zk3:2890:3890"
      ZOO_ENABLE_AUTH: "yes"
    volumes:
      - /data/docker/zk3/data:/bitnami/zookeeper/data
    networks:
      - zk-net
    restart: always

networks:
  zk-net:
    driver: bridge

```

- 启动

```bash
docker-compose -f /data/docker-compose-files/zookeeper/docker-compose.yml  up -d 
```

## 部署后测试

### 集群版本

#### 验证集群状态

```bash
docker exec zk1 zkServer.sh status  # 应显示Leader/Follower
docker exec zk2 zkServer.sh status
docker exec zk3 zkServer.sh status
```

连接脚本：

```bash
zkCli.sh -server zk1:2181 -Dzookeeper.authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider -Dzookeeper.sasl.client.username=admin -Dzookeeper.sasl.client.password=zookeeper123
```