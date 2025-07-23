# Docker&Docker-Compose Portainer 服务部署

## 介绍

Portainer是一个可视化的Docker操作界面，提供状态显示面板、应用模板快速部署、容器镜像网络数据卷的基本操作（包括上传下载镜像，创建容器等操作）、事件日志显示、容器控制台操作、Swarm集群和服务等集中管理和操作、登录用户管理和控制等功能。功能十分全面，基本能满足中小型单位对容器管理的全部需求。

## 示例版本：2.21.3

## 前期准备工作

- 创建数据存储目录 portainer-server(服务端)

```bash
mkdir -p /data/docker/portainer/data
chmod 777 -R /data/docker/portainer/data
```

## Docker 部署

### portainer-ce（服务端）

```bash
docker run -d --restart always --privileged\
  --name portainer-server \
  -p 18000:8000 \
  -p 19000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /data/docker/portainer/data:/data \
  portainer/portainer-ce:2.21.3
```

### portainer-agent（代理）

```bash
docker run -d --restart always --privileged\
  --name portainer-agent \
  -p 39002:9001 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /data/docker-lib/volumes:/var/lib/docker/volumes \
  -v /:/host \
  portainer/agent:2.21.3

```

## Docker-Compose 部署

### portainer-ce(服务端)

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/portainer-server
# 创建配置文件
vim /data/docker-compose-files/portainer-server/docker-compose.yml
```

```yaml

version: '3'

services:
  portainer-server:
    image: portainer/portainer-ce:2.21.3
    container_name: portainer-server
    restart: always
    privileged: true
    ports:
      - 18000:8000
      - 19000:9000
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /data/docker/portainer/data:/data

```

### portainer-agent（代理）

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/portainer-agent
# 创建配置文件
vim /data/docker-compose-files/portainer-agent/docker-compose.yml
```

```yaml
version: '3'

services:
  portainer-agent:
    image: portainer/agent:2.21.3
    container_name: portainer-agent
    restart: always
    privileged: true
    ports:
      - "39002:9001"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /data/docker-lib/volumes:/var/lib/docker/volumes
      - /:/host
```

## 部署成功页面

- 首次进入填写密码
  ![portainer1.png](images%2Fportainer1.png)

- 添加环境
  ![portainer2.png](images%2Fportainer2.png)

- 选择Docker Standalone
  ![portainer3.png](images%2Fportainer3.png)
