# ELK实现日志采集（日志文件、springboot服务项目）进行实时日志采集上报

本文章介绍，Logstash进行自动采集服务器日志文件，并手把手教你如何在springboot项目中配置logstash进行日志自动上报与日志自定义格式输出给logstash。kibana如何进行配置索引模式，可以在kibana中看到采集到的日志

日志流程

logfile-> logstash -> es -> kibana 进行展示

### ELK环境安装（docker）

#### [Docker 安装 elk(elasticsearch、logstash、kibana)、ES安装ik分词器](https://blog.csdn.net/ayunnuo/article/details/145255886)

## Logstash实现日志文件的采集

本示例进行采集nginx日志进行演示。

### 1. logstash配置文件内容：

位于：/data/docker/logstash/config/logstash.conf

```bash
input {

  # 监听nginx日志
  file {
    path => ["/data/docker/nginx/logs/access.log", "/data/docker/nginx/logs/error.log"]
    type => "nginx_log" # 自定义类型
    start_position => "beginning" # beginning-从头开始 end-从结束不配置默认读取最新的数据,默认end
  }
}

filter {

  # nginx日志格式配置
  if [type] == "nginx_log" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}"} # 标准日志格式
    }

    date {
      match => [ "timestamp", "ISO8601", "yyyy/MM/dd HH:mm:ss" ] # 增加ISO8601支持更多日期格式
      target => "@timestamp"
    }

    mutate {
      add_field => { "[@metadata][app]" => "%{type}" }
    }
  }

}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "%{[@metadata][app]}-%{+YYYY.MM.dd}"
  }
}

```

### 2. 修改完配置后，进行重启logstash

## kibana配置索引模式，用于在kibana中进行查看日志

### 1. 检查配置的日志是否被采集到

进入Index Management中查看是否含有nginx_log-yyyy-MM-dd 的index，如果有说明日志被正常采集到了。

菜单位于左侧菜单栏的Management->Stack Management->Index Management中
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0031bba92fc24be9829152af0e0ade71.png)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/77f09616cac34ff6b7f2b034d85a4ee6.png)

### 2. 设置索引模式

在 Index patterns页面中进行新增索引模式，输入nginx_log*
进行模糊匹配到我们的nginx日志索引，然后选择timestamp点击确定即可生成日志看板。然后在Discover页面中就能看到我们配置的日志面板了。

菜单位于左侧菜单栏的Management->Stack Management-> Index patterns

- 创建新的索引模式
  ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a5f6b2bb489943c79c88709d3538bf31.png)
- 输入索引名称进行模糊匹配
  ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f34ddcc8a4514f0fb6557d0bd4036cf8.png)
- 第二步骤选择timestamp
  ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/648103b5bf2347a6a528a5051ab28719.png)

### 3. 进入到Discover页面进行查看日志

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/30cfe7d38118425e808ef62bb377c4bc.png)

- 下拉找到nginx_log*,就能看到采集到的日志了
  ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fabbd8db28754b6f8f5e123bb38c6d2e.png)

## SpringBoot 服务上报给Logstash

该示例使用的springboot自带的logback日志框架进行上报给logstash。

如使用log4j日志框架的可以参考我写的另外一个文章：[ springboot 集成log4j日志，需要自定义json格式内容输出方便ES采集](https://blog.csdn.net/ayunnuo/article/details/131572900)

### springboot项目demo

GITEE项目：[springboot实现logstash日志上报](https://gitee.com/linyunnuo/springboot-demo/tree/master/springboot-log-logstash-logback-demo)

### pom依赖

```xml

<properties>
    <java.version>1.8</java.version>
    <lombok.version>1.18.28</lombok.version>
    <fastjson2.version>2.0.34</fastjson2.version>
    <junit.version>4.13.2</junit.version>
    <logstash.version>7.2</logstash.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>

<dependencies>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- lombok -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>${lombok.version}</version>
</dependency>

<!-- fastjson2 -->
<dependency>
    <groupId>com.alibaba.fastjson2</groupId>
    <artifactId>fastjson2</artifactId>
    <version>${fastjson2.version}</version>
</dependency>

<!-- logstash -->
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>${logstash.version}</version>
</dependency>

</dependencies>

```

### yaml配置

```yaml

server:
  port: 8080

spring:
  application:
    name: springboot-log-logstash-logback-demo
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: GMT+8
    default-property-inclusion: non_null

# 日志配置
logging:
  level:
    org.springframework: warn
  config: classpath:logback-spring.xml
  # logstash 配置
  logstash:
    url: 127.0.0.1:4560


```

**注意：需要文件名需要为logback-spring.xml ，不然在配置日志参数时，会报错无法获取到yaml的配置**

### logback-spring.xml配置

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration scan="true" scanPeriod="60 seconds" debug="false">
    <property name="log.path" value="/data/logs/springboot-log-logback-demo"/>
    <property name="console.log.pattern"
              value="%green(%d{yyyy-MM-dd HH:mm:ss}) %highlight([%level]) %boldMagenta(${PID}) --- %green([%thread])  %boldMagenta(%class) - [%method,%line]: %msg%n"/>
    <property name="log.pattern"
              value="%d{yyyy-MM-dd HH:mm:ss} [%level] ${PID} --- [%thread] %class - [%method,%line]: %msg%n"/>

    <springProperty name="LOG_STASH_URL" scope="context" source="logging.logstash.url" defaultValue="127.0.0.1:4560"/>
    <springProperty name="app" scope="context" source="spring.application.name" defaultValue="springboot-server"/>


    <appender name="console" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>${console.log.pattern}</pattern>
            <charset>utf-8</charset>
        </encoder>
    </appender>

    <appender name="file_out" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${log.path}/out.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${log.path}/out.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>10</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>${log.pattern}</pattern>
        </encoder>
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>INFO</level>
        </filter>
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>WARN</level>
        </filter>
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>ERROR</level>
        </filter>
    </appender>

    <appender name="async_out" class="ch.qos.logback.classic.AsyncAppender">
        <discardingThreshold>0</discardingThreshold>
        <queueSize>512</queueSize>
        <appender-ref ref="file_out"/>
    </appender>

    <!-- Logstash -->
    <appender name="logstash" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
        <destination>${LOG_STASH_URL}</destination>
        <!-- logstash默认输出格式  -->
        <!-- <encoder charset="UTF-8" class="net.logstash.logback.encoder.LogstashEncoder">
             <customFields>{"app":"${app}"}</customFields>
             <pattern>${log.json.pattern}</pattern>
         </encoder>-->

        <!-- 自定义logstash输出格式 - json-->
        <encoder charset="UTF-8" class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
            <providers>
                <pattern>
                    <pattern>
                        {
                        "app":"${app}",
                        "timestamp": "%d{MM-dd HH:mm:ss.SSS}",
                        "level": "%level",
                        "class": "%class",
                        "method": "%method",
                        "line": "%class#%method - %line",
                        "message": "%msg",
                        "header.client-ip": "%X{header.client-ip}",
                        "header.content-length": "%X{header.content-length}",
                        "thread": "%thread",
                        "stack_trace": "%exception{10}"
                        }
                    </pattern>
                </pattern>
            </providers>
        </encoder>
    </appender>


    <root level="info">
        <appender-ref ref="console"/>
        <appender-ref ref="async_out"/>
        <appender-ref ref="logstash"/>
    </root>

</configuration>


```

### logstash配置文件内容

```bash
# 采集配置

input {
  # 设置监听端口为4560，格式为json格式
  tcp {
    mode => "server"
    host => "0.0.0.0"
    port => 4560
    codec => json
    type => "json_log"  # 自定义类型标识
  }
}

filter {

  # json 格式 设置app名称，用于定义index索引名称
  if [type] == "json_log" {
    mutate {
      copy => { "app" => "[@metadata][app]" }
    }
  }

}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "%{[@metadata][app]}-%{+YYYY.MM.dd}"
  }
  
  # 输出到控制台以便调试
  # stdout { codec => rubydebug }
}
```

### kibana配置日志查看↑和nginx的配置一样

![elk2.png](images%2Felk2.png)![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ff6f82727298464bbc313001baa1bc67.png)

## logstash多文件配置

```bash
# 采集配置

input {

  # 设置监听端口，格式为json格式
  tcp {
    mode => "server"
    host => "0.0.0.0"
    port => 4560
    codec => json
    type => "json_log"  # 自定义类型标识
  }

  # 监听nginx日志
  file {
    path => ["/data/docker/nginx/logs/access.log", "/data/docker/nginx/logs/error.log"]
    type => "nginx_log" # 自定义类型
    start_position => "beginning" # beginning-从头开始 end-从结束不配置默认读取最新的数据,默认end
  }
}

filter {

  # json 格式 设置app名称，用于定义index索引名称
  if [type] == "json_log" {
    mutate {
      copy => { "app" => "[@metadata][app]" }
    }
  }

  # nginx日志格式配置
  if [type] == "nginx_log" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}"} # 标准日志格式
    }

    date {
      match => [ "timestamp", "ISO8601", "yyyy/MM/dd HH:mm:ss" ] # 增加ISO8601支持更多日期格式
      target => "@timestamp"
    }

    mutate {
      add_field => { "[@metadata][app]" => "%{type}" }
    }
  }

}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "%{[@metadata][app]}-%{+YYYY.MM.dd}"
  }
  
  # 输出到控制台以便调试
  # stdout { codec => rubydebug }
}

```