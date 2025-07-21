# 🚀 Linux运维手册

---

## 🛠️ 常用命令

```bash

# 修改hostname
sudo hostnamectl set-hostname 【hostname】

# 查看操作系统版本
uname -a
cat /etc/redhat-release # 基于Red Hat的系统
cat /etc/os-release

################## 系统监控相关 ##################
lscpu  # 查看cpu信息

# 查看内存使用率
free -h
# 查看 CPU 内存等 使用率
top 
htop # top 的增强版（需安装）

lsblk # # 查看磁盘挂载命令-树形展示

# 统计模式显示虚拟内存、进程、CPU 活动的详细信息汇总
vmstat -s

################## 进程相关 ##################
# 通过文件名或者服务名查看使用情况
ps aux | grep 【进程名 文件名或服务名】 
# 查看指定 PID 的动态资源占用
top -p PID  
cat /proc/PID/status          # 查看进程详细状态
lsof -p PID                   # 查看进程打开的文件
strace -p PID                 # 跟踪系统调用（排查卡顿）

# 强制关闭进程
kill -9 PID

# 查看进程的工作目录
ls -l /proc/【PID】/cwd

# 查看进程 启动命令
ps -p 【PID】 -o args=

# 查看所有进程的 CPU 和内存使用情况
ps aux --sort=-%cpu,-%mem

# 使用 glances 查看综合系统状态 -- 需安装
glances

################## 查看端口占用情况 ##################
netstat -tulnp | grep :端口号
ss -tulnp | grep :端口号  # 推荐使用，效率更高
lsof -i:端口号            # 查看具体哪个程序占用端口
ps -ef | grep 端口号

################## 查看文件夹占用存储情况 ##################
df -h # 查看磁盘使用率
du -sh *   # 当前目录下每个文件夹占用空间
du -sh */ | sort -rh # 查看当前目录子目录从大到小排序
du -sh ./* | sort -rh | head -n 20 # 查看当前目录存储占用空间最大的前20位

```

---

## 🛠️ 用户相关命令

```bash
# 新增用户
adduser {用户名}

## 将用户添加到指定组
sudo usermod -aG {组名} {用户名}

# 将新用户添加到 sudo 组
sudo usermod -aG sudo {用户名}  # Ubuntu / Debian 系统
sudo usermod -aG wheel {用户名} # CentOS / RHEL / Fedora / SUSE 系统

# 将新用户添加到 docker 组
sudo usermod -aG docker {用户名}

# 验证用户创建和组成员身份
id {用户名}

# 切换到新用户
su {用户名}

# 修改密码
sudo su #1. 切换到 root 用户
passwd publisher # 2. 输入当前用户的密码
# 输入新密码
# 再次输入新密码
exit

# 删除用户
sudo userdel 用户名
# 删除该用户的家目录和邮件目录
sudo userdel -r 用户名

```

## 🛠️ vim命令

### 常用操作

```bash
:q! # 强制退出
:wq # 保存并退出

i # 插入模式

###### 删除 ######
dd # 删除当前行
:%d # 清空全部内容

 ##### 查询 #####
/搜索词 # 向下搜索
?搜索词 # 向上搜索
n / N   # 跳转到下一个/上一个匹配
# 重复上一次查找	
//
# 关闭查找高光显示
:nohl

##### 替换 #####
:%s/old/new/g # 全局替换（加 `c` 确认每次替换）
:10,20s/old/new/g # 替换10-20行内容

```

### 移动命令

| 命令     | 功能             |
|--------|----------------|
| 0 / $  | 	行首/行尾         |
| gg / G | 	文件开头/结尾       |
| :n     | 	跳转到第n行（如 :10） |
| w / b  | 跳到下一个/上一个单词开头  |

### 编辑操作

| 命令         | 功能            |
|------------|---------------|
| i / a      | 	在光标前/后插入     |
| o / O      | 		在当前行下/上插入新行 |
| x          | 		x           |
| dd         | 			删除整行       |
| yy / p     | 			复制行 / 粘贴   |
| u / Ctrl+r | 				撤销 / 重做   |
| >> / <<    | 				增加/减少缩进   |

### 查找替换

```bash
/pattern     # 向下搜索
?pattern     # 向上搜索
n / N        # 跳转到下一个/上一个匹配
:%s/old/new/g # 全局替换（加 `c` 确认每次替换）
:10,20s/old/new/g # 替换10-20行内容
```

## 🛠️ 服务相关

```bash
# 查看服务状态
systemctl list-unit-files --type=service
systemctl list-unit-files --type=service | grep 【服务名】

# 查看高内存/CPU消耗的进程
ps aux --sort=-%mem | head -n 15 # 查看top 15 
ps aux --sort=-%cpu | head -n 15

```

## 🛠️ 系统时区相关

```bash
# 设置系统时区
sudo timedatectl set-timezone 'Asia/Shanghai'

# 查看当前时区
timedatectl

# 查看当前时间
date
```

## 查找命令

```bash

######### 常用 ##############

# 按名称查找（当前目录递归） -type f 表示只搜索文件，-type d 表示按名称搜索
find . -type f -name 【文件名】 # -type f 表示只搜索文件
find . -type d -name 【文件夹名称】 # -type d 表示只搜索文件夹

# 根据文件内容查询文件位置
find . -type f -name "*.sh" | xargs grep "【文件内容】" 

############## 根据服务名称进行查询 ##############

# 查找可执行文件路径
which 【服务名】 # 示例：which python3

# 查找二进制/源码/手册路径
whereis java

########### 高级用法 ##############

# 按时间查找（7天内修改过的文件）
find /var/log -type f -mtime -7
# 查找空目录
find /path -type d -empty

# 查找/var/log下大于1GB的日志
find /var/log -type f -size +1G -exec ls -lh {} \;
# 清空文件内容（保留文件句柄）
: > /path/to/large.log

```

## 替换命令

```bash
########## 不带正则 ##########
find [路径] -type f -name "*.sh" -exec sed -i 's|【需要被替换的文本】|【替换为的文本】|g' {} +
# 示例 （当前目录递归）将 lingyunnuo -> yunnuo
find . -type f -name "*.sh" -exec sed -i 's|lingyunnuo|yunnuo|g' {} +

########## 带正则 ##########
find [路径] -type f -name "*.sh" -exec sed -i 's/原内容/新内容/g' {} \;
# 替换 IP 地址，将 192.168.1.x 替换为 10.0.0.x
find . -name "*.sh" -exec sed -i -E 's/192\.168\.1\.([0-9]+)/10.0.0.\1/g' {} \;
# 删除空行
find /scripts -name "*.sh" -exec sed -i '/^$/d' {} \; 

```

## 压缩工具

### tar 命令

#### 常用操作

```bash

# 基础语法
tar [选项] [输出压缩文件] [输入文件/目录]

################ 解压 #######################
# 解压到当前目录
tar -xf 【压缩包.tar】
tar -zxf 【压缩包.tar.gz】
# 解压到指定目录
tar -xf 【压缩包.tar】 -C /home/data


################ 压缩 #########################

tar -czvf archive.tar.gz /path/to/folder

#将file1.txt和file2.txt两个文件打包成一个名为archive.tar的归档文件。
tar -cvf archive.tar file1.txt file2.txt

#将file1.txt和file2.txt两个文件打包成一个名为archive.tar.gz的gzip压缩归档文件。
tar -czvf archive.tar.gz file1.txt file2.txt

```

tar压缩参数解释

- -c：创建一个新的归档文件。
- -z：通过 gzip 压缩归档文件。
- -v：显示详细信息（可选，用于显示压缩过程中的文件列表）。
- -f：指定归档文件的名称

### zip 命令

```bash
# 基础语法
zip [选项] 压缩包名.zip 文件/目录
unzip [选项] 压缩包名.zip

# 压缩
zip archive.zip file.txt
#将 filename 压缩为 filename.gz，并删除原文件。


# 解压
gzip -d filename.gz

# 解压并删除
gunzip filename.gz


# 解压到当前目录
unzip example.zip

# 不输出解压日志
unzip -q example.zip

# 解压到指定目录
unzip example.zip -d /data/example

```

## 软链接和硬链接连接

- 软链接：类似 Windows 快捷方式，指向文件路径。
- 硬链接：指向相同的 inode，不依赖文件名。

区别：

- 删除原文件：软链接失效，硬链接仍然可用。
- 跨分区：软链接可以，硬链接不行。
- 目录：通常不允许创建硬链接。

```bash

ln -s source.txt softlink.txt     # 创建软链接
ln source.txt hardlink.txt        # 创建硬链接


## 示例 将/data/.jenkins-> /root/.jenkins
ln -s /data/.jenkins /root/.jenkins

```

## 设置定时任务crontab

### 常用命令

```bash
# 编辑当前用户的 crontab
crontab -e

# 查看当前用户的 crontab 内容
crontab -l

# 查看系统 cron 日志
journalctl | grep CRON

# (慎用) 删除当前用户的所有 crontab
crontab -r

# 删除前确认
crontab -i

# 查看某用户的 crontab（需 root 权限）
crontab -u username -l

############ Crond 服务管理命令（根据系统不同） ############
# CentOS/RHEL
systemctl status crond
systemctl restart crond
systemctl enable crond

# Debian/Ubuntu
systemctl status cron
systemctl restart cron
systemctl enable cron

```

语法结构：

```bash
* * * * * command_to_run
分 时 日 月 星期 要执行的命令
```

示例：

```
0 3 * * * /home/user/backup.sh :每天凌晨 3 点执行备份脚本

*/1 * * * * /path/to/script.sh 每一分钟执行一次
```

### 高级用法

#### 使用 flock 防止并发执行（防重锁）

```bash
*/1 * * * * flock -n /tmp/mytask.lock -c "/path/to/script.sh"
```

参数说明：

- -n：非阻塞模式，如果锁存在则跳过本次执行。
- /tmp/mytask.lock：锁文件路径。

#### 使用脚本控制更复杂的逻辑（如判断时间、状态等）

##### 1. 创建一个 shell 脚本(宝塔标准模板)

```bash
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo $$ > /www/server/cron/6087f11b092398b8fcd8b4f71ab29889.pl
cd /www/wwwroot/gxdproxy.gzbgyl.cn && php artisan schedule:run
echo "----------------------------------------------------------------------------"
endDate=`date +"%Y-%m-%d %H:%M:%S"`
echo "★[$endDate] Successful"
echo "----------------------------------------------------------------------------"
if [[ "$1" != "start" ]]; then
    btpython /www/server/panel/script/log_task_analyzer.py /www/server/cron/6087f11b092398b8fcd8b4f71ab29889.log
fi
rm -f /www/server/cron/6087f11b092398b8fcd8b4f71ab29889.pl
```

##### 2. 设置执行权限

```bash
chmod +x /path/to/your_script.sh
```

##### 3. 然后在 crontab 中调用它：

```bash
# 编辑当前用户的 crontab
crontab -e

########## 添加执行任务 ############
*/1 * * * * /path/to/your_script.sh
```

## scp文件拷贝到另一台服务器

```bash
# 示例 scp -r /alidata/scripts root@192.168.0.77:/data/
scp -r /path/to/source user@【ip或域名】:/path/to/destination

```

## 查看 I/O 压力

```bash
iostat -x 1
iotop      # 实时查看 I/O 重的进程
```

## 日志检查

```bash
dmesg | tail       # 内核错误信息
journalctl -xe     # 查看最近系统错误

############### 日志文件 #############
/var/log/messages      # 系统日志（传统 Linux）
/var/log/syslog        # Debian 系
/var/log/dmesg         # 启动硬件日志
```

## 常用工具安装

### lrzsz文件上传下载工具
```bash
# centos系统
yum install -y lrzsz
# ubuntu
apt install lrzsz


# 二进制上传，不强制覆盖（遇到同名文件会提示）
rz -b

# 二进制上传，遇到同名文件自动退出避免覆盖
rz -E   

# 二进制上传 强制覆盖
rz -bye

# 下载文件
sz /path/to/file
```

