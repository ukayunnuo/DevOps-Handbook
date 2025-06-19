# Docker&Docker-Compose MySQL 服务部署

## 示例版本：mysql5.7 和MySQL8

## MySQL 5.7 服务单机版部署

### 前期准备

```bash

################### 5.7 版本 ######################################
# 1. 创建数据存储目录
mkdir -p /data/docker/mysql5.7/{data,logs,conf}

# 创建配置文件my.cnf
vim /data/docker/mysql5.7/conf/my.cnf

# 3. 设置权限
chmod 777 -R /data/docker/mysql5.7

# 单独设置my.cnf文件权限（644）否则mysql为了安全起见会忽略该配置文件
chmod -R 644 /data/docker/mysql5.7/conf

```

#### my.cnf内容(5.7 版本)

```properties
[mysqld]
lower_case_table_names=1
user=mysql
server_id=1
port=3306
#default-time-zone = '+08:00'
enforce_gtid_consistency=ON
gtid_mode=ON
binlog_checksum=none
#authentication_policy           = mysql_native_password
skip-name-resolve=ON
open_files_limit=65535
table_open_cache=2000
sql_mode='' 
log_bin_trust_function_creators=TRUE
#################innodb########################
innodb_data_file_path=ibdata1:512M;ibdata2:512M:autoextend
innodb_buffer_pool_size=4G
innodb_flush_log_at_trx_commit=2
innodb_io_capacity=600
innodb_lock_wait_timeout=120
innodb_log_buffer_size=8M
innodb_log_file_size=200M
innodb_log_files_in_group=3
innodb_max_dirty_pages_pct=85
innodb_read_io_threads=8
innodb_write_io_threads=8
innodb_thread_concurrency=32
innodb_file_per_table
innodb_rollback_on_timeout
###################session###########################
join_buffer_size=8M
key_buffer_size=256M
bulk_insert_buffer_size=8M
max_heap_table_size=96M
tmp_table_size=96M
read_buffer_size=8M
sort_buffer_size=2M
max_allowed_packet=64M
max_connections=1000
read_rnd_buffer_size=32M
############log set###################
log-error=/usr/local/mysql/logs/mysqld.err
log-bin=/usr/local/mysql/logs/binlog
log_bin_index=/usr/local/mysql/logs/binlog.index
max_binlog_size=500M
slow_query_log_file=/usr/local/mysql/logs/slow.log
slow_query_log=1
long_query_time=10
log_queries_not_using_indexes=ON
log_throttle_queries_not_using_indexes=10
log_slow_admin_statements=ON
log_output=FILE,TABLE
master_info_file=/usr/local/mysql/logs/master.info
[client]
default-character-set=utf8mb4  # 设置mysql客户端默认字符集
```

### Docker 部署

- 创建一个名为 `mysql_network` 的桥接网络

```bash
docker network create mysql_network
```

#### 运行 mysql5.7

```bash
docker run -d \
  --name mysql-server-5.7 \
  --restart on-failure:5 \
  -e TZ=Asia/Shanghai \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_LOWER_CASE_TABLE_NAMES=1 \
  -p 3306:3306 \
  -v /data/docker/mysql5.7/data:/var/lib/mysql \
  -v /data/docker/mysql5.7/conf/my.cnf:/etc/my.cnf \
  -v /data/docker/mysql5.7/logs:/usr/local/mysql/logs \
  --logging-driver json-file \
  --log-opt max-size=5g \
  --network mysql_network \
  mysql:5.7
```

- env参数解释
    + TZ=Asia/Shanghai 设置时区为上海时区
    + MYSQL_USER=root root账户名
    + MYSQL_LOWER_CASE_TABLE_NAMES=1 创建表时，表名不区分大小写

### Docker-Compose安装

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/mysql-5.7

# 创建配置文件
vim /data/docker-compose-files/mysql-5.7/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3'

services:
  mysql:
    image: 'mysql:5.7'
    restart: on-failure:5 # 重启策略：最大次数5次
    container_name: 'mysql-server-5.7'
    environment:
      TZ: 'Asia/Shanghai' # 设置时区
      MYSQL_ROOT_PASSWORD: 'root' # root 密码
      MYSQL_LOWER_CASE_TABLE_NAMES: 1 # 不区分大小写
    ports: # 映射端口
      - '3306:3306'
    networks: # 加入网络
      - mysql_network
    volumes: # 数据存储->挂载对应目录到宿主机
      - /data/docker/mysql5.7/data:/var/lib/mysql
      - /data/docker/mysql5.7/conf/my.cnf:/etc/my.cnf
      - /data/docker/mysql5.7/logs:/usr/local/mysql/logs
networks:
  mysql_network:
    driver: bridge
    # name: mysql_network # 看docker-compose版本，有的版本不允许设置name
```

- 启动

```bash
docker-compose -f /data/docker-compose-files/mysql-5.7/docker-compose.yml  up -d 
```

## MySQL8 服务单机版部署

### 前期准备

```bash
################### 8.0 版本 ######################################
# 1. 创建数据存储目录
mkdir -p /data/docker/mysql8/{data,logs,conf}

# 创建配置文件my.cnf
vim /data/docker/mysql8/conf/my.cnf

# 3. 设置权限
chmod 777 -R /data/docker/mysql8

# 单独设置my.cnf文件权限（644）否则mysql为了安全起见会忽略该配置文件
chmod -R 644 /data/docker/mysql8/conf
```

### my.cnf内容（8.0 版本）

```properties
[mysqld]
lower_case_table_names=1
user=mysql
server_id=1
port=3306
enforce_gtid_consistency=ON
gtid_mode=ON
binlog_checksum=none
authentication_policy=mysql_native_password
skip-name-resolve=ON
open_files_limit=65535
table_open_cache=2000
sql_mode='' 
log_bin_trust_function_creators=TRUE
#################innodb########################
#innodb_data_file_path           = ibdata1:512M;ibdata2:512M:autoextend
innodb_buffer_pool_size=4G
innodb_flush_log_at_trx_commit=2
innodb_io_capacity=600
innodb_lock_wait_timeout=120
innodb_log_buffer_size=8M
innodb_log_file_size=200M
innodb_log_files_in_group=3
innodb_max_dirty_pages_pct=85
innodb_read_io_threads=8
innodb_write_io_threads=8
innodb_thread_concurrency=32
innodb_file_per_table
innodb_rollback_on_timeout
###################session###########################
join_buffer_size=8M
key_buffer_size=256M
bulk_insert_buffer_size=8M
max_heap_table_size=96M
tmp_table_size=96M
read_buffer_size=8M
sort_buffer_size=2M
max_allowed_packet=64M
max_connections=1000
read_rnd_buffer_size=32M
############log set###################
#log-error                       = /usr/local/mysql/logs/mysqld.err
#log-bin                         = /usr/local/mysql/logs/binlog
#log_bin_index                   = /usr/local/mysql/logs/binlog.index
max_binlog_size=500M
slow_query_log=1
#slow_query_log_file             = /usr/local/mysql/logs/slow.log
long_query_time=10
log_queries_not_using_indexes=ON
log_throttle_queries_not_using_indexes=10
log_slow_admin_statements=ON
log_output=FILE,TABLE
master_info_file=/usr/local/mysql/logs/master.info
[client]
default-character-set=utf8mb4  # 设置mysql客户端默认字符集

```

### Docker 部署

```bash
docker run -d \
  --name mysql-server-8 \
  --restart on-failure:5 \
  -e TZ=Asia/Shanghai \
  -e MYSQL_USER=root \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_LOWER_CASE_TABLE_NAMES=1 \
  -p 3306:3306 \
  -v /data/docker/mysql8/data:/var/lib/mysql \
  -v /data/docker/mysql8/conf/my.cnf:/etc/my.cnf \
  -v /data/docker/mysql8/logs:/logs \
  --restart always \
  --log-driver json-file \
  --log-opt max-size=5g \
  --network mysql_network \
  mysql/mysql-server:8.0.28
```

- env参数解释
    + TZ=Asia/Shanghai 设置时区为上海时区
    + MYSQL_USER=root root账户名
    + MYSQL_ROOT_PASSWORD=root root账户密码
    + MYSQL_LOWER_CASE_TABLE_NAMES=1 创建表时，表名不区分大小写

### Docker-Compose 部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/mysql-8

# 创建配置文件
vim /data/docker-compose-files/mysql-8/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3'

services:
  mysql:
    image: 'mysql/mysql-server:8.0.28'
    restart: always
    container_name: 'mysql-server-8'
    environment:
      TZ: 'Asia/Shanghai' # 设置时区
      MYSQL_USER: 'root' # root 账户名
      MYSQL_ROOT_PASSWORD: 'root' # root 密码
      MYSQL_LOWER_CASE_TABLE_NAMES: 1 # 不区分大小写
    ports:
      - '3306:3306' # 映射端口
    networks:
      - mysql_network # 加入网络
    volumes: # 数据存储->挂载对应目录到宿主机
      - /data/docker/mysql8/data:/var/lib/mysql
      - /data/docker/mysql8/conf/my.cnf:etc/my.cnf
      - /data/docker/mysql8/logs:/logs
    logging: # 日志设置
      driver: 'json-file'
      options:
        max-size: '5g'

networks:
  mysql_network:
    driver: bridge
    # name: mysql_network # 看docker-compose版本，有的版本不允许设置name
```

- 启动

```bash
docker-compose -f /data/docker-compose-files/mysql-8/docker-compose.yml  up -d 
```

## 开启远程登录访问
请阅读：[MySQL-用户权限相关命令.md](..%2FDB%2FMySQL%2FMySQL-%E7%94%A8%E6%88%B7%E6%9D%83%E9%99%90%E7%9B%B8%E5%85%B3%E5%91%BD%E4%BB%A4.md)

## 常见问题

### 如果启动日志报错文件权限问题，那么重新设置文件权限

```bash

################### 5.7 版本 ######################################
# 设置权限
chmod 777 -R /data/docker/mysql5.7

# 单独设置my.cnf文件权限（644）否则mysql为了安全起见会忽略该配置文件
chmod -R 644 /data/docker/mysql5.7/conf


################### 8.0 版本 ######################################
# 设置权限
chmod 777 -R /data/docker/mysql8

# 单独设置my.cnf文件权限（644）否则mysql为了安全起见会忽略该配置文件
chmod -R 644 /data/docker/mysql8/conf

```


