# Docker&Docker-Compose Minio 服务部署

## 官网
[https://www.minio.org.cn/docs/minio/linux/index.html](https://www.minio.org.cn/docs/minio/linux/index.html)

## 介绍

MinIO是一个对象存储解决方案，它提供了与Amazon Web Services S3兼容的API，并支持所有核心S3功能。 MinIO有能力在任何地方部署 - 公有云或私有云，裸金属基础设施，编排环境，以及边缘基础设施。

## 示例版本：RELEASE.2024-09-09T16-59-28Z.fips

## 前期准备工作

- 创建文件目录
```bash
mkdir -p /data/docker/minio/{data,config}
chomod -R 777 /data/docker/minio 
```

## Docker 部署
```bash
docker run -d --restart always  \
  --name minio \
  --hostname minio \
  --privileged \
  -p 9000:9000 \
  -p 19001:9001 \
  -e MINIO_ROOT_USER=admin \
  -e MINIO_ROOT_PASSWORD=minio2024 \
  -v /data/docker/minio/data:/data \
  -v /data/docker/minio/config:/root/.minio/ \
  minio/minio:RELEASE.2024-09-09T16-59-28Z.fips \
  server --console-address :9001 /data
```

## Docker-Compose 部署
- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/minio
# 创建配置文件
vim /data/docker-compose-files/minio/docker-compose.yml
```
- docker-compose文件
```yaml
  version: '3'
  services:
    minio:
      image: minio/minio:RELEASE.2024-09-09T16-59-28Z.fips
      hostname: "minio"
      container_name: minio
      restart: always
      privileged: true
      ports:
        - 9000:9000
        - 19001:9001
      environment:
        # MINIO_ACCESS_KEY: admin
        # MINIO_SECRET_KEY: minio2024
        MINIO_ROOT_USER: admin
        MINIO_ROOT_PASSWORD: minio2024
      volumes:
        - /data/docker/minio/data:/data
        - /data/docker/minio/config:/root/.minio/
      command: server --console-address ':9001' /data

```

- 参数说明：
    - MINIO_ROOT_USER：用户名
    - MINIO_ROOT_PASSWORD：密码

- 启动

```bash
docker-compose -f /data/docker-compose-files/minio/docker-compose.yml  up -d 
```

## 部署成功页面

![minio1.png](images%2Fminio1.png)