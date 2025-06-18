# Docker&Docker-Compose Nacos 服务部署

## 示例版本：v2.3.2

## 前期准备工作

1. 创建文件目录

```bash
# 创建目录
mkdir -p /data/docker/nacos
```

2. 启动临时容器，进行拷贝配置文件

```bash
# 启动临时容器
docker run --name nacos-server-temp -d nacos/nacos-server:v2.3.2

# 拷贝配置文件
docker cp nacos-server-temp:/home/nacos/conf /data/docker/nacos/ 
docker cp nacos-server-temp:/home/nacos/logs /data/docker/nacos/ 
docker cp nacos-server-temp:/home/nacos/bin /data/docker/nacos/ 
docker cp nacos-server-temp:/home/nacos/data /data/docker/nacos/

# 删除临时容器
docker rm -f nacos-server-temp
```

3. 数据库准备（MySQL数据库脚本）

执行拷贝出来的数据库脚本位置：`/data/docker/nacos/conf/mysql-schema.sql`

4. 生成 secret-key

```bash
# 生成一个32位随机数
openssl rand -hex 32
# 生成结果：ZWVmYjEyNDE5YzYwMGUyNTZjNmJiZDg0ZmI0YWE1ODFhYmJhMTYyODEyNjMxN2FiMTUxYWQ3OWQ3M2ViNzNlMg==

# 设置 Docker 容器环境变量参数：NACOS_AUTH_TOKEN

# 或者直接修改配置文件：nacos.core.auth.plugin.nacos.token.secret.key
vim /data/docker/nacos/conf/application.properties
```

5. 修改jvm参数（可选）

配置文件位于：`/data/nacos/bin/docker-startup.sh`

## 单机版部署

### Docker 部署

```bash
docker run -d --name nacos-sever F--restart=always \
-e MODE=standalone \ # 集群模式(单机)
-e SPRING_DATASOURCE_PLATFORM=mysql \
-e MYSQL_SERVICE_HOST=10.61.19.128 \ # 数据库地址
-e MYSQL_SERVICE_DB_NAME=nacos_config \ # 数据库名
-e MYSQL_SERVICE_PORT=3306 \ # 数据库端口
-e MYSQL_SERVICE_USER=root \ # 数据库用户名
-e MYSQL_SERVICE_PASSWORD=root \ # 数据库密码
-e NACOS_AUTH_ENABLE=true \ # 权限控制（true=不允许匿名访问，false=允许匿名访问）
-e NACOS_AUTH_CACHE_ENABLE=true \ # 权限控制 （true=不允许匿名访问，false=允许匿名访问）
-e NACOS_AUTH_TOKEN=ZWVmYjEyNDE5YzYwMGUyNTZjNmJiZDg0ZmI0YWE1ODFhYmJhMTYyODEyNjMxN2FiMTUxYWQ3OWQ3M2ViNzNlMg== \  # 设置 NACOS_AUTH_TOKEN
-e NACOS_AUTH_IDENTITY_KEY=nacos \
-e NACOS_AUTH_IDENTITY_VALUE=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjpbeyJ4eHh4IjoieXl5In1dLCJpYXQiOjE2Nzk1NzU0NzIsImV4cCI6MTY3OTUwMDc5OSwiYXVkIjoiIiwiaXNzIjoiIiwic3ViIjoiIn0.nhN_hKcnjlX0QW-kQj2beLehBzrQnB1IhhJZe2WO-c0 \
-v /data/docker/nacos/conf:/home/nacos/conf \
-v /data/docker/nacos/logs:/home/nacos/logs \
-v /data/docker/nacos/bin:/home/nacos/bin \
-v /data/docker/nacos/data:/home/nacos/data \
-p 8488:8848  \
nacos/nacos-server:v2.3.2
```

### Docker-Compose 部署
```yaml

version: '3'
services:
  nacos:
    image: nacos/nacos-server:v2.3.2 # 镜像名称
    container_name: nacos-server # 容器名称
    restart: always # 重启策略（一直重启）
    environment:
      - PREFER_HOST_MODE=hostname # 运行主机模式
      - MODE=standalone # 集群模式(单机)
      - SPRING_DATASOURCE_PLATFORM=mysql # 数据库类型
      - MYSQL_SERVICE_HOST=172.17.0.1 # 数据库地址
      - MYSQL_SERVICE_DB_NAME=nacos_config # 数据库名
      - MYSQL_SERVICE_PORT=3306 # 端口
      - MYSQL_SERVICE_USER=root # 数据库用户名
      - MYSQL_SERVICE_PASSWORD=root # 密码
      - NACOS_AUTH_ENABLE=false  # 权限控制（true=不允许匿名访问，false=允许匿名访问）
      - NACOS_AUTH_CACHE_ENABLE=false # 权限控制 （true=不允许匿名访问，false=允许匿名访问）
      - NACOS_AUTH_TOKEN=ZWVmYjEyNDE5YzYwMGUyNTZjNmJiZDg0ZmI0YWE1ODFhYmJhMTYyODEyNjMxN2FiMTUxYWQ3OWQ3M2ViNzNlMg==
      - NACOS_AUTH_IDENTITY_KEY=nacos # 表示 Nacos 认证身份的键
      - NACOS_AUTH_IDENTITY_VALUE=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjpbeyJ4eHh4IjoieXl5In1dLCJpYXQiOjE2Nzk1NzU0NzIsImV4cCI6MTY3OTUwMDc5OSwiYXVkIjoiIiwiaXNzIjoiIiwic3ViIjoiIn0.nhN_hKcnjlX0QW-kQj2beLehBzrQnB1IhhJZe2WO-c0 # 表示 Nacos 认证身份的值
    ports:
      - 8848:8848 # 默认端口
    volumes:
      - /data/docker/nacos/conf:/home/nacos/conf
      - /data/docker/nacos/logs:/home/nacos/logs
      - /data/docker/nacos/bin:/home/nacos/bin
      - /data/docker/nacos/data:/home/nacos/data
```

## 部署成功页面