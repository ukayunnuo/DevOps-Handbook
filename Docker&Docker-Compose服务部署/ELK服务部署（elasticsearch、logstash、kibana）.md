# Docker&Docker-Compose ELK 服务部署

## 介绍

ELK 是 Elasticsearch、Logstash 和 Kibana 的首字母缩写，这三者共同构成了一个强大的开源日志分析和可视化平台。它们都是由
Elastic
公司开发并维护的工具，用于从各种来源收集、处理、存储和展示日志数据。

**ELK 是三个开源工具的合称：**

- Elasticsearch（ES）
  分布式搜索引擎，用于高效存储、搜索和分析大量日志数据。
- Logstash（LS）
  数据收集和处理工具，负责采集、过滤、格式化日志数据后发送到 Elasticsearch。
- Kibana
  数据可视化工具，提供图形界面，用于查询、分析和展示 Elasticsearch 中的数据。
  用途：常用于集中管理日志，实现日志的收集、分析与可视化，广泛应用于系统监控、故障排查、业务分析等场景。

**工作流程：**

Logstash 收集并处理日志 → 存入 Elasticsearch → Kibana 展示分析结果。

## 示例版本：7.10.1

## 前期准备工作

1. 创建kibana配置文件路径

```bash
mkdir -p /data/docker/logstash/config
```

2. 先启动临时 logstash服务，目的拷贝/usr/share/logstash/pipeline/logstash.conf文件

```bash
# 启动
docker run --name logstash -d docker.elastic.co/logstash/logstash:7.10.1

# 拷贝配置文件
docker container cp logstash:/usr/share/logstash/pipeline/logstash.conf /data/docker/logstash/config

# 编辑
vi /data/docker/logstash/config/logstash.conf

# 停止删除容器
docker rm -f logstash

# 设置权限
chmod -R 777 /data/docker/logstash 
```

- logstash.conf文件配置内容：

```
input {
  tcp {
    mode => "server"
    host => "0.0.0.0"
    port => 4560
    codec => json
  }
}
output {
  elasticsearch {
    hosts => "elasticsearch:9200"
    index => "logstash-%{+YYYY.MM.dd}"
  }
}
```

## Docker 部署
```bash
# 创建一个名为 elk 的桥接网络
docker network create elk
# 启动 Elasticsearch
docker run -d \
  --name elasticsearch \
  --restart always \
  --privileged=true \
  -e TZ=Asia/Shanghai \
  -e node.name=elasticsearch \
  -e cluster.name=es-docker-cluster \
  -e discovery.type=single-node \
  -e bootstrap.memory_lock=true \
  -e ES_JAVA_OPTS=-Xms512m -Xmx512m \
  --ulimit memlock=-1:-1 \
  -v esdata:/usr/share/elasticsearch/data \
  -p 9200:9200 \
  -p 9300:9300 \
  --network elk \
  docker.elastic.co/elasticsearch/elasticsearch:7.10.1

# 启动 Logstash
docker run -d \
  --name logstash \
  --restart always \
  --privileged=true \
  -v /data/docker/logstash/config/logstash.conf:/usr/share/logstash/pipeline/logstash.conf \
  -p 4560:4560 \
  -p 5044:5044 \
  -p 5000:5000/tcp \
  -p 5000:5000/udp \
  -e TZ=Asia/Shanghai \
  -e LS_JAVA_OPTS="-Xmx256m -Xms256m" \
  --network elk \
  docker.elastic.co/logstash/logstash:7.10.1

# 启动 Kibana
docker run -d \
  --name kibana \
  --restart always \
  --privileged=true \
  -e TZ=Asia/Shanghai \
  -e ELASTICSEARCH_URL=http://elasticsearch:9200 \
  -e ELASTICSEARCH_HOSTS=http://elasticsearch:9200 \
  -p 5601:5601 \
  --network elk \
  docker.elastic.co/kibana/kibana:7.10.1

```

## Docker-Compose 部署
```yaml
version: '3.1'  
services:  
  elasticsearch:  
    image: docker.elastic.co/elasticsearch/elasticsearch:7.10.1  
    container_name: elasticsearch
    restart: always  
    environment:  
      - TZ=Asia/Shanghai
      - node.name=elasticsearch  
      - cluster.name=es-docker-cluster  
      - discovery.type=single-node  
      - bootstrap.memory_lock=true  
      - ES_JAVA_OPTS=-Xms512m -Xmx512m  
    ulimits:  
      memlock:  
        soft: -1  
        hard: -1  
    volumes:  
      - esdata:/usr/share/elasticsearch/data  
    ports:  
      - "9200:9200"  
      - "9300:9300"  
    networks:  
      - elk  
  logstash:  
    image: docker.elastic.co/logstash/logstash:7.10.1  
    container_name: logstash
    restart: always  
    volumes:  
      - /data/docker/logstash/config/logstash.conf:/usr/share/logstash/pipeline/logstash.conf  
    ports:  
      - "4560:4560"
      - "5044:5044"  
      - "5000:5000/tcp"  
      - "5000:5000/udp"  
    environment:  
        TZ: Asia/Shanghai
        LS_JAVA_OPTS: "-Xmx256m -Xms256m"  
    depends_on:  
      - elasticsearch  
    networks:  
      - elk  
  kibana:  
    image: docker.elastic.co/kibana/kibana:7.10.1  
    container_name: kibana
    restart: always  
    environment:  
      TZ: Asia/Shanghai
      ELASTICSEARCH_URL: http://elasticsearch:9200  
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200  
    ports:  
      - "5601:5601"  
    depends_on:  
      - elasticsearch  
    networks:  
      - elk  
  
volumes:  
  esdata:  
    driver: local  
  
networks:  
  elk:  
    driver: bridge
```

## 安装ik分词器
[Elasticsearch安装ik分词器.md](..%2Felasticsearch%2FElasticsearch%E5%AE%89%E8%A3%85ik%E5%88%86%E8%AF%8D%E5%99%A8.md)


## 部署成功页面
![elk1.png](images%2Felk1.png)