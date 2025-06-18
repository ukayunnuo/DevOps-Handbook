# Docker&Docker-Compose Redis 服务部署

## 示例版本：redis-6.2.6

## 前期准备工作

```bash
#  1. 找到对应版本的配置文件
http://download.redis.io/releases/

# 2. 创建文件目录 
mkdir -p /data/docker/redis/data

# 3. 将配置文件复制到/data/docker/redis目录下

# 4. 设置权限
chmod -R 777 /data/docker/redis

```

![redis1.png](images%2Fredis1.png)

- redis.conf配置

```
# 注释 bind 127.0.0.1  说明允许任何主机连接、访问
# bind 127.0.0.1

# 关闭保护模式
protected-mode no

port 6379

tcp-backlog 511

timeout 0

tcp-keepalive 300

# 由于docker启动，所以不允许启动后在后台运行
daemonize no

supervised no

pidfile /var/run/redis_6379.pid

loglevel notice

# 日志级别
logfile "/data/redis.log"

databases 16

always-show-logo yes

# RDB 持久化配置
save 900 1      # 900秒内至少有1个键被改动，触发RDB持久化
save 300 10     # 300秒内至少有10个键被改动，触发RDB持久化
save 60 10000   # 60秒内至少有10000个键被改动，触发RDB持久化

stop-writes-on-bgsave-error yes

rdbcompression yes

rdbchecksum yes

dbfilename dump.rdb

dir ./

replica-serve-stale-data yes

replica-read-only yes

repl-diskless-sync no

repl-diskless-sync-delay 5

repl-disable-tcp-nodelay no

replica-priority 100

lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no

# aof 备份 no=不开启，yes=开启
appendonly yes

# AOF文件名
appendfilename "appendonly.aof"
# 每秒同步一次，平衡性能和持久性
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes

lua-time-limit 5000

slowlog-log-slower-than 10000

slowlog-max-len 128

latency-monitor-threshold 0

notify-keyspace-events ""

hash-max-ziplist-entries 512
hash-max-ziplist-value 64

list-max-ziplist-size -2


list-compress-depth 0

set-max-intset-entries 512

zset-max-ziplist-entries 128
zset-max-ziplist-value 64

hll-sparse-max-bytes 3000


stream-node-max-bytes 4096
stream-node-max-entries 100


activerehashing yes

client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10

dynamic-hz yes

aof-rewrite-incremental-fsync yes

rdb-save-incremental-fsync yes

# 密码
requirepass root
```

- redis.cnf 需要修改配置项
    + 注释 bind 127.0.0.1 说明允许任何主机连接、访问
    + requirepass root ：密码配置为root
    + daemonize no ：由于docker启动，所以不允许启动后在后台运行

## Docker 部署

```bash
docker run  -p 6379:6379 --name redis-server --restart=always \
-v /data/redis/redis.conf:/etc/redis/redis.conf \  
-v /data/docker/redis/data:/data \
-d redis:6.2.6 \
redis-server /etc/redis/redis.conf --appendonly yes # 开启appendonly 备份模式
```

## Docker-Compose 部署

1. 创建docker-compose 文件

```bash
mkdir -p /data/docker-compose-files/redis

vim /data/docker-compose-files/redis/docker-compose.yml
```

2. Docker-Compose 文件

```yaml
version: '3'
services:
  redis:
    image: redis:6.2.6 # 镜像名称
    container_name: redis-server # 容器名称
    restart: always # 重启策略（一直重启）
    ports:
      - 6379:6379 # 映射端口
    volumes: # 挂载目录
      - /data/docker/redis/redis.conf:/etc/redis/redis.conf  # 配置文件挂载
      - /data/docker/redis/data:/data # 数据挂载
    command: redis-server /etc/redis/redis.conf --appendonly yes  # 开启appendonly 备份模式
```

3. 启动

```bash
cd /data/docker-compose-files/redis
docker-compose up -d
```

## 部署成功页面

![redis1.png](images%2Fredis2.png)