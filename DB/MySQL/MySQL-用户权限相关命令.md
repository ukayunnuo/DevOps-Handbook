# MySQL 用户权限相关命令

## 开启 root 远程登陆（如果在配置文件中配置了允许远程登录就可以进行远程登录了）

登陆mysql服务

```bash
mysql -u root -p
```

执行下面命令：

```sql
-- 使用mysql数据库
use mysql;

-- 查看用户，是否包含 root %
SELECT user, host FROM mysql.user;

-- 创建一个远程登录 root 用户
CREATE USER 'root'@'%' IDENTIFIED BY '[你的密码]';

-- 授予权限给root
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- 立即生效
FLUSH PRIVILEGES;
```
![mysql1.png](images%2Fmysql1.png)


## 自定义用户运行远程登录访问

- 用户示例：yunnuo

```sql

-- 创建localhost类型用户
CREATE USER 'yunnuo'@'localhost' IDENTIFIED BY 'yunnuo';
GRANT ALL PRIVILEGES ON *.* TO 'yunnuo'@'localhost';

-- 创建远程类型用户
CREATE USER 'yunnuo'@'%' IDENTIFIED BY 'yunnuo';
GRANT ALL PRIVILEGES ON *.* TO 'yunnuo'@'%';

-- 立即生效
FLUSH PRIVILEGES;
```


## 重置 root 密码（忘记密码）
```bash
sudo systemctl stop mysqld
sudo mysqld --skip-grant-tables --user=mysql &
mysql -uroot

# 然后运行
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '新密码';
FLUSH PRIVILEGES;
exit;
sudo systemctl restart mysqld
```