# MySQL常用命令

## 系统相关命令
```sql
-- 获取当前日期
SELECT CURDATE();

-- 当前日期时间
SELECT CURRENT_TIMESTAMP();

-- 1=不区分大小写，0=区分大小写
SHOW VARIABLES LIKE 'lower_case_table_names';

-- 查看sql_mode
SELECT @@global.sql_mode;

```

## 日期时间相关指令
```sql

-- 时间戳（秒级）转日期
SELECT FROM_UNIXTIME(1640995200);

-- 日期转时间戳（秒级）
SELECT UNIX_TIMESTAMP('2022-01-01');

-- 提取日期部分 yyyy-MM-dd
SELECT DATE('2025-01-01 12:30:45');

-- 提取时间部分 hh:mm:ss
SELECT TIME('2025-01-01 12:30:45');

-- 日期加减运算 INTERVAL单位（SECOND=秒、MINUTE=分钟、HOUR=小时、DAY=天、MONTH=月、QUARTER=季度、YEAR=年）
SELECT DATE_ADD('2025-01-01', INTERVAL 1 DAY); -- 加1天
SELECT DATE_SUB('2025-01-01', INTERVAL 1 HOUR); -- 减1小时

-- 日期差运算 2025-01-02 - 2025-01-01 = 1
SELECT DATEDIFF('2025-01-02', '2025-01-01');

-- 字符串转日期格式
SELECT STR_TO_DATE('2022-01-01', '%Y-%m-%d');

-- 格式化日期输出
SELECT DATE_FORMAT('2023-01-01 12:30:45', '%Y-%m-%d');

-- 格式化日期时间输出
SELECT DATE_FORMAT('2023-01-01 12:30:45', '%Y-%m-%d %H:%i:%s');

```