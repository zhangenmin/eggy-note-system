#!/bin/bash
set -e

# 等待 MySQL 就绪
echo "🔄 等待 MySQL..."
while ! mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent 2>/dev/null; do
    sleep 2
done
echo "✅ MySQL 就绪"

# 初始化数据库（幂等）
echo "🔄 初始化数据库..."
MYSQL_CMD="mysql -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD"
# 如果不需要初始化已有的 eggs_note 库就跳过
$MYSQL_CMD -e "CREATE DATABASE IF NOT EXISTS eggy_note DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null || true
# 建表（幂等）
if [ -f /app/init_db.sql ]; then
    $MYSQL_CMD eggy_note < /app/init_db.sql 2>/dev/null || true
fi
# 确保枚举值包含 word/excel
$MYSQL_CMD -e "ALTER TABLE eggy_note.note MODIFY COLUMN type ENUM('cornell','block','markdown','excel','word') DEFAULT 'block';" 2>/dev/null || true
echo "✅ 数据库就绪"

# 启动后端 (FastAPI)
echo "🚀 启动后端 (FastAPI :8080)"
cd /app/backend
/app/venv/bin/python3 main.py &

# 启动 Nginx (前台)
echo "🚀 启动 Nginx (80 端口)"
nginx -g "daemon off;"
