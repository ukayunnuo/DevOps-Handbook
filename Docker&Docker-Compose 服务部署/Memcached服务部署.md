# Docker&Docker-Compose Memcached 服务部署

## 介绍

Memcached 是一个高性能的分布式内存对象缓存系统，主要用于加速动态Web应用程序的数据访问速度。它通过在内存中缓存数据库查询、API调用或页面渲染的结果来减少数据库的负载，从而提高响应速度和吞吐量。Memcached
的简单设计包括键值存储功能，支持设置数据过期时间，但不提供任何数据冗余方案，因此适用于那些能够容忍一定程度数据丢失的应用场景。

## 示例版本：1.6.12

## 前期准备工作

无需额外准备

## Docker 部署

```bash
docker run -d \
  --name memcached-server \
  --restart always \
  -p 11211:11211 \
  memcached:1.6.12 \
  memcached -m 256 -p 11211 -u root
```

## Docker-Compose 部署

```yaml
version: '3'
services:
  memcached:
    image: memcached:1.6.12
    restart: always
    container_name: memcached-server
    ports:
      - "11211:11211"
    environment:
      - MEMCACHED_MEM_LIMIT=256 # 限制256M
```

参数说明：

- MEMCACHED_MEM_LIMIT=256 说明限制内存大小为256M

## 部署成功页面

使用telnet命令进行测试

```bash
telnet 127.0.0.1 11211
```

输入以下内容测试

```bash
# 设置缓存
set demo_key 0 0 4
test

# 获取缓存
get demo_key
```

![memcached1.png](images%2Fmemcached1.png)