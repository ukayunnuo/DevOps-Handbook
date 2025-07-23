# Docker&Docker-Compose Redis 服务部署

## 示例版本：nginx:1.23

## 前期准备

1. 创建文件目录

```bash
mkdir -p /data/docker/nginx/

# 设置权限
chmod 777 -R /data/docker/nginx/
```

2. 先运行一次容器（为了拷贝配置文件）

```bash
docker run --name nginx-temp -d nginx:1.23
```

3. 拷贝容器文件

```bash
docker container cp nginx-temp:/etc/nginx /data/docker/nginx/conf
docker container cp nginx-temp:/usr/share/nginx/html /data/docker/nginx/
```

4. 删除临时容器

```bash
docker rm -f nginx-temp
```

## Docker 部署

```bash
docker run -d --name nginx --restart=always \
-p 80:80 \
-p 443:443 \
-v /data/docker/nginx/html:/usr/share/nginx/html \
-v /data/docker/nginx/logs:/var/log/nginx \
-v /data/docker/nginx/conf:/etc/nginx \
-e TZ=Asia/Shanghai \
-e NGINX_PORT=80 \
nginx:1.23
```

## Docker-Compose 部署

- 创建docker-compose文件

```bash
mkdir -p /data/docker-compose-files/docker/nginx

cd /data/docker-compose-files/docker/nginx

vim /data/docker-compose-files/docker/nginx/docker-compose.yml

```

- docker-compose.yml

```yaml
version: '3'
services:
  nginx:
    image: 'nginx:1.23' # 镜像
    restart: always # 重启策略（一直重启）
    container_name: nginx # 容器名称
    ports:
      - 80:80 # 映射端口
      - 443:443 # 映射端口
    volumes: # 挂载目录
      - /data/docker/nginx/html:/usr/share/nginx/html
      - /data/docker/nginx/logs:/var/log/nginx
      - /data/docker/nginx/conf:/etc/nginx
    environment:
      - TZ=Asia/Shanghai # 时区
      - NGINX_PORT=80 # 默认端口 
```

## 部署成功页面

![nginx1.png](images%2Fnginx1.png)