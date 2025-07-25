# Docker&Docker-Compose mosquitto 服务部署

## 官网

[https://mosquitto.org/](https://mosquitto.org/)

## 介绍

Eclipse Mosquitto是一个开源（EPL/EDL 许可）消息代理，实现了 MQTT 协议 5.0、3.1.1 和 3.1 版本。Mosquitto
轻量级，适用于从低功耗单板计算机到完整服务器的所有设备。

MQTT 协议提供了一种使用发布/订阅模型进行消息传递的轻量级方法。这使得它非常适合物联网消息传递，例如与低功耗传感器或移动设备（如手机、嵌入式计算机或微控制器）之间的消息传递。

Mosquitto 项目还提供了用于实现 MQTT 客户端的C 库，以及非常流行的mosquitto_pub 和mosquitto_sub命令行 MQTT 客户端。

## 示例版本：2

## 前期准备工作

- 创建文件目录

```bash
mkdir -p /data/docker/mosquitto/{config,data,log}

vi /data/docker/mosquitto/config/mosquitto.conf

chmod -R 777 /data/docker/mosquitto
```

`mosquitto.conf` 配置文件内容

```bash
persistence true
persistence_location /mosquitto/data
log_dest file /mosquitto/log/mosquitto.log

port 1883
listener 9001
protocol websockets

# 先把下面的密码相关配置进行注释，后面创建密码文件后，再取消注释
# allow_anonymous false
# password_file /mosquitto/config/pwfile.conf
```

## Docker 部署

```bash
docker run -d \
  --name mosquitto-mqtt \
  --privileged \
  --restart always \
  -p 1883:1883 \
  -p 9001:9001 \
  -v /data/docker/mosquitto/config:/mosquitto/config \
  -v /data/docker/mosquitto/data:/mosquitto/data \
  -v /data/docker/mosquitto/log:/mosquitto/log \
  eclipse-mosquitto:2
```

## Docker-Compose 部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/mosquitto
# 创建配置文件
vim /data/docker-compose-files/mosquitto/docker-compose.yml
```

- docker-compose文件

```yaml
version: "3"
services:
  mqtt:
    image: eclipse-mosquitto:2
    container_name: mosquitto-mqtt
    privileged: true
    restart: always
    ports:
      - 1883:1883
      - 9001:9001
    volumes:
      - /data/docker/mosquitto/config:/mosquitto/config
      - /data/docker/mosquitto/data:/mosquitto/data
      - /data/docker/mosquitto/log:/mosquitto/log
```

- 启动

```bash
docker-compose -f /data/docker-compose-files/mosquitto/docker-compose.yml  up -d 
```

## 创建密码

1. 进入容器创建密码

```bash
# 进入容器
docker exec -it mosquitto-mqtt sh

# 创建密码文件
touch /mosquitto/config/pwfile.conf
# 修改权限
chmod 0700 /mosquitto/config/pwfile.conf
# 创建密码
mosquitto_passwd -b /mosquitto/config/pwfile.conf admin mqtt2024
```

2. 修改配置文件,放开注释，则需要密码才能正常连接

```bash
allow_anonymous false
password_file /mosquitto/config/pwfile.conf
```

3. 重启服务

```bash
docker restart mosquitto-mqtt
```