# Docker & Docker-Compose 服务部署手册

本目录包含使用 Docker 和 Docker-Compose 部署常见服务的完整指南和配置示例。每个服务都有详细的部署步骤、环境变量说明、目录结构建议以及常见问题处理。

---

## 📄 服务部署文档说明

| 文件名                                                                                    | 服务名称                  | 版本（Version）                         | 说明                        |
|----------------------------------------------------------------------------------------|-----------------------|-------------------------------------|---------------------------|
| [MySQL服务安装.md](MySQL服务安装.md)                                                           | MySQL 5.7 / MySQL 8.0 | `5.7 / 8.0.28`                      | 常用开源关系型数据库                |
| [Nginx服务部署.md](Nginx服务部署.md)                                                           | Nginx                 | `1.23`                              | 高性能 Web 服务器与反向代理服务器       |
| [Redis服务部署.md](Redis服务部署.md)                                                           | Redis                 | `6.2.6`                             | 内存型数据结构存储系统，常用于缓存、消息队列    |
| [Nacos服务部署.md](Nacos服务部署.md)                                                           | Nacos                 | `v2.3.2`                            | 动态服务发现、配置管理和服务管理平台        |
| [zookeeper服务部署.md](zookeeper服务部署.md)                                                   | ZooKeeper             | `3.8.0`                             | 分布式协调服务，用于服务发现、配置管理       |
| [kafka服务部署.md](kafka服务部署.md)                                                           | Kafka                 | `3.2.0`                             | 高吞吐量分布式流处理平台              |
| [ActiveMQ服务部署.md](ActiveMQ服务部署.md)                                                     | ActiveMQ              | `5.14.3`                            | 消息中间件，支持JMS、AMQP、STOMP等协议 |
| [RabbitMQ服务安装.md](RabbitMQ服务安装.md)                                                     | RabbitMQ              | `3.9.13-management`                 | 开源消息队列系统，支持 AMQP 协议       |
| [RocketMQ服务部署.md](RocketMQ服务部署.md)                                                     | RocketMQ              | `4.9.7`                             | 分布式消息中间件，高吞吐、低延迟          |
| [ELK服务部署（elasticsearch、logstash、kibana）.md](ELK服务部署（elasticsearch、logstash、kibana）.md) | ELK Stack             | `7.10.1`                            | 日志收集、分析与可视化解决方案           |
| [GitLab服务部署.md](GitLab服务部署.md)                                                         | GitLab CE             | `15.2.0-ce.0`                       | Git 版本控制系统与 DevOps 平台     |
| [Mariadb服务部署.md](Mariadb服务部署.md)                                                       | MariaDB               | `10.6.5`                            | 开源关系型数据库，MySQL 分支         |
| [Memcached服务部署.md](Memcached服务部署.md)                                                   | Memcached             | `1.6.12`                            | 高性能分布式内存缓存系统              |
| [Portainer服务部署.md](Portainer服务部署.md)                                                   | Portainer             | `2.21.3`                            | Docker 容器可视化管理工具          |
| [MangoDB服务部署.md](MangoDB服务部署.md)                                                       | MangoDB               | `5.0.5`                             | NoSQL数据库，适用于数据存储和查询       |`   
| [Minio服务部署.md](Minio服务部署.md)                                                           | Minio                 | `RELEASE.2024-09-09T16-59-28Z.fips` | MinIO是分布式文件存储服务，用于存储对象数据。 |`   

---

这个版本列有助于快速了解每个服务的部署版本，便于维护和升级时参考。
---

## 📌 使用说明

1. **部署建议：** 每个服务文档中都包含 Docker 和 Docker-Compose 两种部署方式。
2. **目录结构：** 建议统一使用 `/data/docker/<服务名>` 作为数据挂载目录。
3. **权限管理：** 注意目录权限设置，避免因权限问题导致服务启动失败。
4. **日志查看：** 所有服务日志建议统一挂载到宿主机目录，便于排查问题。
5. **环境变量：** 根据实际需求修改 `docker-compose.yml` 或 `docker run` 命令中的环境变量。

---

## 🛠️ Docker 国内镜像加速地址

[Docker 运维手册](..%2FDocker%E5%91%BD%E4%BB%A4%2FREADME.md)

## 🧰 常见命令汇总

### docker 常用命令

```bash

# 查看实时200行日志
docker logs -f --tail 200 <容器ID>

# 进入容器
docker exec -it <容器ID> bash

```

### docker-compose 常用命令

```bash
# 启动服务
docker-compose -f /data/docker-compose-files/<服务名>/docker-compose.yml up -d

# 查看服务状态
docker-compose -f /data/docker-compose-files/<服务名>/docker-compose.yml ps

# 查看日志
docker-compose -f /data/docker-compose-files/<服务名>/docker-compose.yml logs -f

# 停止服务
docker-compose -f /data/docker-compose-files/<服务名>/docker-compose.yml down
```

---

## 📚 参考资料

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 官方文档](https://docs.docker.com/compose/)
- [Docker Hub 官网地址](https://hub.docker.com/)
- 各服务官网链接详见对应文档

---

如有新增服务部署需求，可参考 [模板.md](模板.md) 创建新文档。