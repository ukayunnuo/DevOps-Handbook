# Docker&Docker-Compose Mariadb 服务部署

## 介绍

MariaDB 是一个开源的关系型数据库管理系统（RDBMS），它最初是作为 MySQL 数据库的一个分支创建的。MariaDB 由 MySQL 原作者
Michael Widenius 领导开发，目的是为了保持数据库的开源特性，并在此基础上提供更多的功能和改进。

主要特点：

- 兼容性：与 MySQL 完全兼容，可以轻松替换 MySQL。
- 开源免费：使用 GPL 许可证发布，任何人都可以自由使用、修改和分享。
- 性能优化：包括更快的查询执行速度和更高的并发处理能力。
- 扩展性强：支持多种存储引擎，并提供了丰富的功能如窗口函数、JSON 支持等。
- 安全性：通过 SSL 加密连接、用户权限管理和审计日志等功能增强数据安全。

MariaDB 广泛应用于各种规模的企业中，无论是小型网站还是大型企业级应用，都可找到它的身影。由于其易用性和强大的功能，它是很多开发者和企业的首选数据库之一。

## 示例版本：10.6.5

## 前期准备工作

```bash
# 创建文件目录
mkdir -p /data/docker/mariadb/{data,log,conf}

# 设置权限
chmod -R 777 /data/docker/mariadb

# 启动临时容器，拷贝容器配置文件：/etc/mysql/my.cnf
docker run -d \
  --name mariadb-server-temp \
  -e TZ="Asia/Shanghai" \
  mariadb:10.6.5

# 拷贝文件
docker cp mariadb-server-temp:/etc/mysql/my.cnf /data/docker/mariadb/my.cnf

# 删除临时容器
docker rm -f mariadb-server-temp
```

### 修改配置文件（允许外网访问）

```bash
vim /data/docker/mariadb/my.cnf
```

```properties
# 配置文件/etc/mysql/my.cnf 添加允许外网访问
[mysqld]
bind-address=0.0.0.0
```

## Docker 部署

```bash
docker run -d \
  --name mariadb-server \
  --restart always \
  -e MYSQL_USER="root" \
  -e MYSQL_PASSWORD="root" \
  -e MYSQL_ROOT_PASSWORD="root" \
  -e TZ="Asia/Shanghai" \
  -p 3307:3306 \
  -v /data/mariadb/data:/var/lib/mysql \
  -v /data/mariadb/log:/var/log/mysql \
  -v /data/mariadb/conf/my.cnf:/etc/mysql/my.cnf \
  mariadb:10.6.5
```

- 参数说明
    + MYSQL_USER：数据库用户名
    + MYSQL_PASSWORD：数据库密码
    + MYSQL_ROOT_PASSWORD：数据库管理员密码
    + TZ：时区（上海）

## Docker-Compose 部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/mariadb

# 创建配置文件
vim /data/docker-compose-files/mariadb/docker-compose.yml
```

- docker-compose文件

```yaml
version: '3'
services:
  mariadb:
    image: mariadb:10.6.5
    container_name: "mariadb-server"
    restart: always
    environment:
      MYSQL_USER: "root"
      MYSQL_PASSWORD: "root"
      MYSQL_ROOT_PASSWORD: "root"
      TZ: "Asia/Shanghai"
    ports:
      - "3307:3306"
    volumes:
      - /data/mariadb/data:/var/lib/mysql
      - /data/mariadb/log:/var/log/mysql
      - /data/mariadb/conf/my.cnf:/etc/mysql/my.cnf
```

- 启动

```bash
# 启动容器
docker-compose up -d

# 查看日志
docker-compose logs -f

# 查看运行状态
docker-compose ps

# 进入容器命令
docker exec -it [容器名称] bash 
```

### 设置root用户运行外网访问

- 登陆

```bash

mariadb -u root -p
```

- 修改权限

```sql
# 允许 root 用户从任何主机访问
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'your_root_password' WITH GRANT OPTION;

# 刷新权限
FLUSH PRIVILEGES;

```