# MySQL数据备份、迁移 mysqldump命令

```bash
# 导出所有数据库数据
mysqldump -u root -p --all-databases > /path/to/backup/all_databases.sql

# 导出指定数据库（单个库）
mysqldump -u root -p database_name > /path/to/backup/database_name.sql

# 导出指定数据库（多个库）
mysqldump -u root -p --databases db1 db2 db3 > multiple_databases.sql

# 导出（8.0兼容MySQL5.7版本）
mysqldump --compatible=mysql57 --all-databases > all_databases.sql

# 导入数据库
mysql -u root -p < /path/to/backup/all_databases.sql

# 导入针对特定数据库
mysql -u root -p database_name < /path/to/backup/database_name.sql
```