#!/bin/bash

# MySQL 5.7 部署脚本

# 创建数据存储目录
mkdir -p /data/docker/mysql5.7/{data,logs,conf}

# 创建配置文件
cat > /data/docker/mysql5.7/conf/my.cnf << 'EOF'
[mysqld]
character-set-server=utf8
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
log-error=/var/log/mysql/mysqld.error.log
log-bin=/var/log/mysql/binlog
log_bin_index=/var/log/mysql/binlog.index
max_binlog_size=500M
slow_query_log_file=/var/log/mysql/slow.log
slow_query_log=1
long_query_time=10
log_queries_not_using_indexes=ON
log_throttle_queries_not_using_indexes=10
log_slow_admin_statements=ON
log_output=FILE,TABLE
master_info_file=/var/log/mysql/master.info
[client]
default-character-set=utf8mb4  # 设置mysql客户端默认字符集
default-character-set=utf8

[mysql]
default-character-set=utf8

EOF

# 设置权限
chmod 777 -R /data/docker/mysql5.7
chmod -R 644 /data/docker/mysql5.7/conf

# 创建网络
docker network create mysql_network 2>/dev/null || true

docker pull mysql:5.7

# 运行容器
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
  --network mysql_network \
  mysql:5.7

echo "MySQL 5.7 部署完成!"