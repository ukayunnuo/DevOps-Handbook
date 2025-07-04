# Elasticsearch安装ik分词器

## ik分词器介绍

IK 分词器是专为中文环境设计的一款分词插件，广泛应用于 Elasticsearch 中以增强对中文文本的索引和搜索能力。它解决了
Elasticsearch 默认对于非空格分隔的语言（如中文）支持不佳的问题。

## 相关链接

- ik分词器地址：https://github.com/infinilabs/analysis-ik

根据es的版本找到对应ik分词器的版本进行安装

```bash
# 1. 进入 Elasticsearch 根目录
cd path/to/elasticsearch/

# 2. 使用 plugin 命令安装 IK 分词器
bin/elasticsearch-plugin install https://get.infini.cloud/elasticsearch/analysis-ik/7.10.1
```

### Docker安装的ES进行安装ik分词器
```bash
# 进入容器
docker exec -it elasticsearch bash

# 使用 plugin 命令安装 IK 分词器
bin/elasticsearch-plugin install https://get.infini.cloud/elasticsearch/analysis-ik/7.10.1

# 重启es
docker restart elasticsearch 

```

## 进行验证
进入kibana devtool 页面：http://127.0.0.1:5601/app/dev_tools#/console

输入以下命令测试：
```
POST /_analyze
{
  "analyzer": "ik_smart",
  "text":["中国人最牛"]
}
```