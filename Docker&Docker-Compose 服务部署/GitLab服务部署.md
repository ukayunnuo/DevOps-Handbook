# Docker&Docker-Compose GitLab 服务部署

## 示例版本：15.2.0-ce.0

## 前期准备工作

```bash
# 创建gitlab存放数据目录
mkdir -p /data/docker/gitlab/{config,logs,data}

# 设置权限
chmod 755 -R /data/docker/gitlab
chmod 775 -R /data/docker/gitlab/config

```

## Docker 部署

### ip版访问

```bash
docker run -d \
  --name gitlab-server \
  --hostname gitlab \
  --restart always \
  -p 3000:3000 \
  -p 2289:22 \
  -e TZ='Asia/Shanghai' \
  -e GITLAB_OMNIBUS_CONFIG="external_url 'http://192.168.0.10:3000'; gitlab_rails['gitlab_shell_ssh_port'] = 2289" \
  --log-driver json-file \
  --log-opt max-size=2g \
  -v /data/docker/gitlab/config:/etc/gitlab \
  -v /data/docker/gitlab/data:/var/opt/gitlab \
  -v /data/docker/gitlab/logs:/var/log/gitlab \
  --privileged \
  gitlab/gitlab-ce:15.2.0-ce.0
  
```

### 域名版访问

```bash
docker run -d \
  --name gitlab-server \
  --hostname gitlab \
  --restart always \
  -p 3000:3000 \
  -p 8880:80 \
  -p 4443:443 \
  -p 2289:22 \
  -e TZ='Asia/Shanghai' \
  -e GITLAB_OMNIBUS_CONFIG="external_url 'http://192.168.10.100:3000'; gitlab_rails['gitlab_shell_ssh_port'] = 2289; gitlab_rails['trusted_proxies'] = [\"192.168.0.10\"]; gitlab_rails['gitlab_ssh_host'] = \"gitlab.example.com\"; gitlab_workhorse['listen_network'] = \"tcp\"; gitlab_workhorse['listen_addr'] = \"0.0.0.0:3000\"; nginx['enable'] = false;" \
  --log-driver json-file \
  --log-opt max-size=2g \
  -v /data/docker/gitlab/config:/etc/gitlab \
  -v /data/docker/gitlab/data:/var/opt/gitlab \
  -v /data/docker/gitlab/logs:/var/log/gitlab \
  --privileged \
  gitlab/gitlab-ce:15.2.0-ce.0
```

- 参数说明
    + external_url：web站点访问地址（示例：http://192.168.0.10:3000 或 http://www.gitlab.demo）
    + gitlab_rails['gitlab_shell_ssh_port'] 暴露的ssh端口
    + gitlab_rails['trusted_proxies'] 配置域名访问的ip地址
    + gitlab_rails['gitlab_ssh_host'] 配置域名访问的域名
    + gitlab_workhorse['listen_network'] 配置域名访问为tcp
    + gitlab_workhorse['listen_addr'] 运行那些ip访问（0.0.0.0:3000 表示所有ip可以访问）

## Docker-Compose 部署

- 创建docker-compose文件

```bash
# 创建存放docker-compose文件路径
mkdir -p /data/docker-compose-files/gitlab

# 创建配置文件
vim /data/docker-compose-files/gitlab/docker-compose.yml
```

### ip版访问

```bash
version: '3'

services:
  gitlab:
    image: 'gitlab/gitlab-ce:15.2.0-ce.0'
    restart: always
    container_name: 'gitlab-server'
    hostname: 'gitlab'
    environment:
      TZ: 'Asia/Shanghai'
      GITLAB_OMNIBUS_CONFIG: |
        external_url '{web站点访问地址}' # 示例：http://192.168.0.10:3000 或 http://www.gitlab.demo
        gitlab_rails['gitlab_shell_ssh_port'] = 2289
        nginx['enable'] = false
    ports:
      - '3000:3000'
      - '2289:22'
    volumes:
      - /data/docker/gitlab/config:/etc/gitlab
      - /data/docker/gitlab/data:/var/opt/gitlab
      - /data/docker/gitlab/logs:/var/log/gitlab
    logging:
      driver: 'json-file'
      options:
        max-size: '2g'
```

### 域名版访问

```yaml
version: '3'

services:
  gitlab:
    image: 'gitlab/gitlab-ce:15.2.0-ce.0'
    restart: always
    container_name: 'gitlab-server'
    hostname: 'gitlab'
    environment:
      TZ: 'Asia/Shanghai'
      GITLAB_OMNIBUS_CONFIG: |
        external_url '{web站点访问地址}' # 示例：http://192.168.0.10:3000 或 http://www.gitlab.demo
        gitlab_rails['gitlab_shell_ssh_port'] = 2289
        gitlab_rails['trusted_proxies'] = ["192.168.0.10"]
        gitlab_rails['gitlab_ssh_host'] = "域名地址，示例：www.gitlab.demo"
        gitlab_workhorse['listen_network'] = "tcp"
        gitlab_workhorse['listen_addr'] = "0.0.0.0:3000"
        nginx['enable'] = false
    ports:
      - '3000:3000'
      - '8880:80'
      - '4443:443'
      - '2289:22'
    volumes:
      - /data/docker/gitlab/config:/etc/gitlab
      - /data/docker/gitlab/data:/var/opt/gitlab
      - /data/docker/gitlab/logs:/var/log/gitlab
    logging:
      driver: 'json-file'
      options:
        max-size: '2g'
```

## 查看root默认密码

```bash
# 进入容器
docker exec -it gitlab-server bash

# 查看密码文件
cat /data/docker/gitlab/config/initial_root_password
```

### 新建仓库地址使用自定义域名

文件地址：/etc/gitlab/gitlab.rb
对于挂载地址为：/data/docker/gitlab/config/gitlab.rb

```bash
vim /data/docker/gitlab/config/gitlab.rb
```
找到并修改 external_url 设置
external_url 'http://www.gitlab.com'

## 部署成功页面

- 访问：http://192.168.0.10:3000

![gitlab1.png](images%2Fgitlab1.png)