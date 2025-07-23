# 🚀 DevOps-Handbook 开发运维知识库

> 综合 DevOps 技术参考手册 | Docker | Kubernetes | CI/CD | 中间件 | 监控系统 | Linux运维

---

## 📚 核心目录体系

### 🐳 Docker 化服务部署

| 文件名                                                                                                               | 服务名称                  | 版本（Version）         | 说明                        |
|-------------------------------------------------------------------------------------------------------------------|-----------------------|---------------------|---------------------------|
| [MySQL服务安装.md](Docker&Docker-Compose 服务部署/MySQL服务安装.md)                                                           | MySQL 5.7 / MySQL 8.0 | `5.7 / 8.0.28`      | 常用开源关系型数据库                |
| [Nginx服务部署.md](Docker&Docker-Compose 服务部署/Nginx服务部署.md)                                                           | Nginx                 | `1.23`              | 高性能 Web 服务器与反向代理服务器       |
| [Redis服务部署.md](Docker&Docker-Compose 服务部署/Redis服务部署.md)                                                           | Redis                 | `6.2.6`             | 内存型数据结构存储系统，常用于缓存、消息队列    |
| [Nacos服务部署.md](Docker&Docker-Compose 服务部署/Nacos服务部署.md)                                                           | Nacos                 | `v2.3.2`            | 动态服务发现、配置管理和服务管理平台        |
| [zookeeper服务部署.md](Docker&Docker-Compose 服务部署/zookeeper服务部署.md)                                                   | ZooKeeper             | `3.8.0`             | 分布式协调服务，用于服务发现、配置管理       |
| [kafka服务部署.md](Docker&Docker-Compose 服务部署/kafka服务部署.md)                                                           | Kafka                 | `3.2.0`             | 高吞吐量分布式流处理平台              |
| [ActiveMQ服务部署.md](Docker&Docker-Compose 服务部署/ActiveMQ服务部署.md)                                                     | ActiveMQ              | `5.14.3`            | 消息中间件，支持JMS、AMQP、STOMP等协议 |
| [RabbitMQ服务安装.md](Docker&Docker-Compose 服务部署/RabbitMQ服务安装.md)                                                     | RabbitMQ              | `3.9.13-management` | 开源消息队列系统，支持 AMQP 协议       |
| [RocketMQ服务部署.md](Docker&Docker-Compose 服务部署/RocketMQ服务部署.md)                                                     | RocketMQ              | `4.9.7`             | 分布式消息中间件，高吞吐、低延迟          |
| [ELK服务部署（elasticsearch、logstash、kibana）.md](Docker&Docker-Compose 服务部署/ELK服务部署（elasticsearch、logstash、kibana）.md) | ELK Stack             | `7.10.1`            | 日志收集、分析与可视化解决方案           |
| [GitLab服务部署.md](Docker&Docker-Compose 服务部署/GitLab服务部署.md)                                                         | GitLab CE             | `15.2.0-ce.0`       | Git 版本控制系统与 DevOps 平台     |
| [Mariadb服务部署.md](Docker&Docker-Compose 服务部署/Mariadb服务部署.md)                                                       | MariaDB               | `10.6.5`            | 开源关系型数据库，MySQL 分支         |
| [Memcached服务部署.md](Docker&Docker-Compose 服务部署/Memcached服务部署.md)                                                   | Memcached             | `1.6.12`            | 高性能分布式内存缓存系统              |
| [Portainer服务部署.md](Docker&Docker-Compose 服务部署/Portainer服务部署.md)                                                   | Portainer             | `2.21.3`            | Docker 容器可视化管理工具          |

---

### 🛢️ MySQL 深度指南

- [权限管理与用户控制](DB/MySQL/MySQL-用户权限相关命令.md)
- [高频运维指令集锦](DB/MySQL/MySQL常用指令.md)
- [备份迁移实战手册](DB/MySQL/MySQL数据备份和迁移mysqldump命令.md)

---

### 📊 ELK 日志生态系统

- [SpringBoot日志采集实战](elasticsearch/ELK实现日志采集（日志文件、springboot服务项目）进行实时日志采集上报.md)
- [中文分词器配置指南](elasticsearch/Elasticsearch安装ik分词器.md)

---

### ⚙️ 运维速查手册

- [Docker 命令大全](Docker命令)
- [Linux 系统指令宝典](Linux系统指令)

---

## 🌟 项目价值

> **一站式解决 DevOps 技术栈落地难题**

- 🚢 **容器化部署**：覆盖 15+ 主流中间件的 Docker & Docker-Compose 最佳实践
- 📦 **开箱即用**：每个服务提供即用型部署方案，复制粘贴即可快速搭建环境
- 🔍 **日志治理**：从采集到分析的全链路日志管理方案
- 💾 **数据管理**：MySQL 运维操作的全流程指南
- 📏 **标准化参考**：建立企业级基础设施部署规范
- 🔄 **持续演进**：跟随技术发展趋势定期更新知识体系

---

---

## 🛠️ 最佳实践指南

### 适用场景

- **开发环境搭建**：快速搭建本地开发所需中间件集群
- **生产环境部署**：获取经过验证的容器化部署方案
- **技术方案选型**：对比不同消息队列/注册中心的部署差异
- **排错手册**：MySQL权限管理、日志采集故障排查指南
- **教学参考**：DevOps 技术栈学习路径与实践案例

### 使用建议

1. 部署服务时优先查看对应组件的容器化部署文档
2. 运维操作参考速查手册获取命令语法
3. 日志系统搭建遵循 ELK 专题指南
4. 数据库管理使用 MySQL 专题文档规范操作

---

## 🤝 贡献指南

欢迎通过以下方式参与优化：

- 提交 PR 补充新组件部署方案
- 修订现有文档中的技术细节
- 新增实用案例场景（标注来源）
- 修复文档中的过时内容
- 优化代码片段的可移植性

**文档规范**：

1. 使用 Markdown 语法
2. 所有命令提供适用环境说明
3. 配置文件标注关键参数含义

---

## 🔖 版本历史

| 版本   | 更新日期    | 重要变更   |
|------|---------|--------|
| v1.0 | 2024-07 | 初始版本发布 |

> 🌟 **持续更新中，欢迎 Star & Watch 获取更新通知**

## 📮 联系方式

![wechat-contact-me1.jpg](images%2Fwechat-contact-me1.jpg)


