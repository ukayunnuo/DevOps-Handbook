# Docker&Docker-Compose MangoDB 服务部署

## 介绍

## 示例版本：5.0.5

## 前期准备工作

### 单价版

- 创建存放mongodb数据路径

```bash
mkdir -p /data/docker/mongodb
chmod 777 -R /data/docker/mongodb/
```

### 集群版

- 创建存放mongodb数据路径

```bash
mkdir -p /data/docker/{mongodb1,mongodb2,mongodb3}/{config,log}
chmod 777 -R /data/docker/{mongodb1,mongodb2,mongodb3}/log
chmod 400 -R /data/docker/{mongodb1,mongodb2,mongodb3}/config
```

- 编辑配置文件内容
    - 配置文件`/data/docker/mongodb1/config/mongo.yaml`
    - 配置文件`/data/docker/mongodb2/config/mongo.yaml`
    - 配置文件`/data/docker/mongodb3/config/mongo.yaml`

mongo.yaml 文件内容如下：

```bash
systemLog:
  destination: file
  path: "/var/log/mongodb/mongo.log"
  logAppend: true

net:
  maxIncomingConnections: 10240
  port: 27017
  bindIp: 0.0.0.0

security:
  authorization: 'enabled' #是否开启认证 disabled不开启，enabled开启
  keyFile: "/data/configdb/mongodb-keyfile" # 密码文件

storage:
  engine: "wiredTiger"
  directoryPerDB: true
  dbPath: "/data/db"
  journal:
    enabled: true
    commitIntervalMs: 100
  wiredTiger:
    engineConfig:
      directoryForIndexes: true
      cacheSizeGB: 3
replication:
  oplogSizeMB: 4096
  replSetName: "rs" # 集群配置名称
```

## Docker 部署

### 单机版

```bash
docker run \
  --name mongodb-server \
  --restart always \
  -e TZ=Asia/Shanghai \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=mongodb2024 \
  -p 27017:27017 \
  -v /data/docker/mongodb/data:/data/db \
  -v /data/docker/mongodb/logs:/data/logs \
  -v /data/docker/mongodb/config:/data/configdb \
  --privileged \
  -d mongo:5.0.5
```

- 参数说明：
    - MONGO_INITDB_ROOT_USERNAME ：数据库用户名
    - MONGO_INITDB_ROOT_PASSWORD ：数据库密码

### 启动集群

```bash
# mongo-server1
docker rm -f mongo-server1
docker run --name mongo-server1 -it -d \
-p 27017:27017 --privileged=true \
-v /data/docker/mongodb1/conf:/data/configdb \
-v /data/docker/mongodb1/data:/data/db \
-v /data/docker/mongodb1/log:/var/log/mongodb mongo:5.0.5  -f /data/configdb/mongo.yaml  --bind_ip_all

# mongo-server2
docker rm -f mongo-server2
docker run --name mongo-server2 -it -d \
--restart always \
-p 27018:27017 --privileged=true \
-v /data/docker/mongodb2/conf:/data/configdb \
-v /data/docker/mongodb2/data:/data/db \
-v /data/docker/mongodb2/log:/var/log/mongodb mongo:5.0.5  -f /data/configdb/mongo.yaml  --bind_ip_all

# mongo-server3
docker rm -f mongo-server3
docker run --name mongo-server3 -it -d \
--restart always \
-p 27019:27017 --privileged=true \
-v /data/docker/mongodb3/conf:/data/configdb \
-v /data/docker/mongodb3/data:/data/db \
-v /data/docker/mongodb3/log:/var/log/mongodb mongo:5.0.5 -f /data/configdb/mongo.yaml  --bind_ip_all

```

## Docker-Compose 部署

### 单机版

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/mongodb
# 创建配置文件
vim /data/docker-compose-files/mongodb/docker-compose.yml
```

- docker-compose文件

```yaml
version: "3"
services:
  mongodb:
    image: mongo:5.0.5
    container_name: mongodb-server
    restart: always
    environment:
      - TZ=Asia/Shanghai
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=mongodb2024
    ports:
      - "27017:27017"
    volumes:
      - /data/docker/mongodb/data:/data/db
      - /data/docker/mongodb/logs:/data/logs
      - /data/docker/mongodb/config:/data/configdb
    privileged: true
```

- 启动

```bash
docker-compose -f /data/docker-compose-files/mongodb/docker-compose.yml  up -d 
```

### 集群版


- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/mongodb
# 创建配置文件
vim /data/docker-compose-files/mongodb/docker-compose.yml
```

```yaml
version: '3'

services:
  mongo-server1:
    image: mongo:5.0.5
    container_name: mongo-server1
    restart: always
    ports:
      - "27017:27017"
    volumes:
      - /data/docker/mongodb1/conf:/data/configdb
      - /data/docker/mongodb1/data:/data/db
      - /data/docker/mongodb1/log:/var/log/mongodb
    command: ["mongod", "-f", "/data/configdb/mongo.yaml", "--bind_ip_all"]
    privileged: true

  mongo-server2:
    image: mongo:5.0.5
    container_name: mongo-server2
    restart: always
    ports:
      - "27018:27017"
    volumes:
      - /data/docker/mongodb2/conf:/data/configdb
      - /data/docker/mongodb2/data:/data/db
      - /data/docker/mongodb2/log:/var/log/mongodb
    command: ["mongod", "-f", "/data/configdb/mongo.yaml", "--bind_ip_all"]
    privileged: true

  mongo-server3:
    image: mongo:5.0.5
    container_name: mongo-server3
    restart: always
    ports:
      - "27019:27017"
    volumes:
      - /data/docker/mongodb3/conf:/data/configdb
      - /data/docker/mongodb3/data:/data/db
      - /data/docker/mongodb3/log:/var/log/mongodb
    command: ["mongod", "-f", "/data/configdb/mongo.yaml", "--bind_ip_all"]
    privileged: true

```

```bash
docker-compose -f /data/docker-compose-files/mongodb/docker-compose.yml  up -d 
```

## 登录

### 单机版

连接类型选择：Standalone，输入账号密码即可。

![mongo1.png](images%2Fmongo1.png)

### 集群版

第一次登录需要创建数据库用户和配置集群信息

1. 关闭认证
   将三个节点的配置文件security进行修改。

```bash
# 修改配置文件内容
security:
  authorization: 'disabled'
  #keyFile: "/data/configdb/mongodb-keyfile"
```

2. 进入其中一个容器进行创建用户

```bash
# 进入容器
docker exec -it mongo-server1 bash

# 登录
mongo

# 切换admin数据库
use admin

# 创建admin 用户
db.createUser({
  user: "admin",
  pwd: "admin",
  roles: [ { role: "root", db: "admin" } ]
})

# 使用admin用户登录
mongo -u admin -p admin --authenticationDatabase admin


# 修改用户密码
db.changeUserPassword("admin", "admin")

# 获取用户信息
db.getUser("admin")

```

3. 集群配置

```javascript

// 切换admin数据库
use
admin

// 初始化新的副本集
rs.initiate({
    _id: "rs",
    members: [
        {_id: 0, host: "192.168.0.100:27017"},
        {_id: 1, host: "192.168.0.100:27018"},
        {_id: 2, host: "192.168.0.100:27019", arbiterOnly: true}
    ]
})

// 查看集群相关信息
rs.config()

// 验证集群状态
rs.status()

// 确定当前节点是否为主节点
rs.isMaster()

```

4. 开启认证

将三个节点的配置文件security进行修改。

```bash
# 修改配置文件内容
security:
  authorization: 'enabled' #是否开启认证 disabled不开启，enabled开启
  keyFile: "/data/configdb/mongodb-keyfile" # 密码文件
```

5. 登录

选择连接方式：Replica Set

![mongo2.png](images%2Fmongo2.png)