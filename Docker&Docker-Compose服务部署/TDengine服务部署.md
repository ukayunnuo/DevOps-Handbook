# Docker&Docker-Compose XXX 服务部署

## 官网

[https://docs.taosdata.com](https://docs.taosdata.com)

## 介绍

TDengine 是一款 开源、高性能、云原生 的时序数据库（Time Series Database, TSDB）, 它专为物联网、车联网、工业互联网、金融、IT
运维等场景优化设计。同时它还带有内建的缓存、流式计算、数据订阅等系统功能，能大幅减少系统设计的复杂度，降低研发和运营成本，是一款极简的时序数据处理平台。

## 示例版本：3.1.1.0

## 前期准备工作

1. 创建文件目录

```bash
mkdir -p /data/docker/tdengine/{data,log,conf}
chmod -R 777 /data/docker/tdengine
```
2. 复制配置文件到宿主机上：
```bash
# 创建临时容器
docker run --name tdengine-temp -d tdengine/tdengine:3.1.1.0
# 复制配置文件
docker cp tdengine-temp:/etc/taos/taos.cfg /data/docker/tdengine/conf/
# 删除临时容器
docker rm -f tdengine-temp
```

3. 修改配置文件 `taos.cfg`

修改以下内容:
```bash

# The maximum number of vnodes supported by this dnode
supportVnodes             1000

# system time zone
timezone                  UTC-8

# system time zone (for windows 10)
timezone              Asia/Shanghai (CST, +0800)
```


## Docker 部署

```bash
docker run -d --restart always \
  --name tdengine \
  -p 6030:6030 \
  -p 6040:6040 \
  -p 6035:6035 \
  -p 6020:6020 \
  -p 10010:10010 \
  -p 6041:6041 \
  -e TZ=Asia/Shanghai \
  -e LD_LIBRARY_PATH=/usr/local/tdengine/lib \
  -e TDENGINE_MODE=single \
  -v /data/docker/tdengine/data:/var/lib/taos \
  -v /data/docker/tdengine/log:/var/log/taos \
  -v /data/docker/tdengine/conf/taos.cfg:/etc/taos/taos.cfg \
  --network tdengine_net \
  tdengine/tdengine:3.1.1.0
```

- 端口说明
  - "6030:6030" # HTTP服务端口
  - "6040:6040" # TaosAdapter服务端口
  - "6035:6035" # 客户端连接端口
  - "6020:6020" # 集群端口
  - "10010:10010" # 监控端口
  - "6041:6041" # TDengine 的 WebSocket 服务

## Docker-Compose 部署

### 单机版

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/tdengine
# 创建配置文件
vim /data/docker-compose-files/tdengine/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3.1'

services:
  tdengine:
    image: tdengine/tdengine:3.1.1.0
    container_name: tdengine
    restart: always
    ports:
      - "6030:6030" # HTTP服务端口
      - "6040:6040" # TaosAdapter服务端口
      - "6035:6035" # 客户端连接端口
      - "6020:6020" # 集群端口
      - "10010:10010" # 监控端口
      - "6041:6041" # TDengine 的 WebSocket 服务
    environment:
      - TZ=Asia/Shanghai # 设置时区，根据需要调整
      - LD_LIBRARY_PATH=/usr/local/tdengine/lib
      - TDENGINE_MODE=single
    volumes:
      - /data/docker/tdengine/data:/var/lib/taos
      - /data/docker/tdengine/log:/var/log/taos
      - /data/docker/tdengine/conf/taos.cfg:/etc/taos/taos.cfg
    networks:
      - tdengine_net

networks:
  tdengine_net:
    driver: bridge

```

- 启动

```bash
docker-compose -f /data/docker-compose-files/tdengine/docker-compose.yml  up -d 
```

### 集群版

```yaml
version: '3.1'

services:
  tdengine1:
    image: tdengine/tdengine:3.1.1.0
    container_name: tdengine1
    restart: always
    ports:
      - "6030:6030" # HTTP服务端口
      - "6040:6040" # TaosAdapter服务端口
      - "6035:6035" # 客户端连接端口
      - "6020:6020" # 集群端口
      - "10010:10010" # 监控端口
      - "6041:6041" # TDengine 的 WebSocket 服务
    environment:
      - TZ=Asia/Shanghai # 设置时区，根据需要调整
      - LD_LIBRARY_PATH=/usr/local/tdengine/lib
      - TAOS_FQDN=tdengine1 # 设置节点的FQDN
      - TAOS_FIRST_EP=tdengine1:6030 # 设置第一个节点的地址
    volumes:
      - /data/docker/tdengine/data1:/var/lib/taos
      - /data/docker/tdengine/log1:/var/log/taos
      - /data/docker/tdengine/conf/taos.cfg:/etc/taos/taos.cfg
    networks:
      - tdengine_net

  tdengine2:
    image: tdengine/tdengine:3.1.1.0
    container_name: tdengine2
    restart: always
    ports:
      - "6031:6030" # HTTP服务端口
      - "6042:6040" # TaosAdapter服务端口
      - "6036:6035" # 客户端连接端口
      - "6021:6020" # 集群端口
      - "10011:10010" # 监控端口
      - "6043:6041" # TDengine 的 WebSocket 服务
    environment:
      - TZ=Asia/Shanghai # 设置时区，根据需要调整
      - LD_LIBRARY_PATH=/usr/local/tdengine/lib
      - TAOS_FQDN=tdengine2 # 设置节点的FQDN
      - TAOS_FIRST_EP=tdengine1:6030 # 设置第一个节点的地址
    volumes:
      - /data/docker/tdengine/data2:/var/lib/taos
      - /data/docker/tdengine/log2:/var/log/taos
    networks:
      - tdengine_net

networks:
  tdengine_net:
    driver: bridge
```

## 常用命令

```bash

# 进入容器
docker exec -it tdengine bash

# 连接(无用户密码)
taos

# 连接（有用户密码）
taos -utdsa -ptdengine2024

# 修改root密码
alter user root pass 'tdengine2024';


# 创建用户
CREATE USER tdsa PASS 'tdengine2024' SYSINFO 1;


# 查看用户
SHOW USERS;

# 查看用户权限
SHOW GRANTS FOR tdsa;

# 查看数据库
SHOW DATABASES;

# 查看节点状态
SHOW DNODES;

# 查看所有超级表
show stables;
# 删除超级表
DROP STABLE [表名];

# 查看所有子表
show tables;

# 查看子表的标签信息
SHOW TABLE TAGS FROM [表名];

```

## 数据库导入导出

官方文档：[https://docs.taosdata.com/2.4/reference/taosdump/](https://docs.taosdata.com/2.4/reference/taosdump/)


### 导出

```bash
taosdump --host <TDengine服务器IP> --port 6030 -u<用户名> -p<密码> --database db1,db2  -o /path/to/export_dir

# 示例
taosdump -D zhgd_iot_geofencing -h 127.0.0.1 -P 6030 -utdsa -ptdengine2024  -o /var/log/taos/tempsql
```

### 导入

```bash
taosdump -h 127.0.0.1 -P 6030 -utdsa -ptdengine2024 -i /var/log/taos/tempsql
```


