#!/bin/bash
# ==============================================
#  楚淮笔记系统 — 一键启动脚本
#  Usage:  curl -fsSL https://git.io/xxx | bash
#          bash run.sh
# ==============================================
set -e
APP_NAME="chuhuai-note"
DB_NAME="chuhuai-mysql"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-Jschrj83130911!}"
APP_PORT="${APP_PORT:-8080}"

echo "🚀 楚淮笔记系统 — 一键部署"
echo "==========================="

# 检查 Docker
if ! command -v docker &>/dev/null; then
    echo "❌ 未安装 Docker，请先安装: https://docs.docker.com/engine/install/"
    exit 1
fi

# 1️⃣ 启动 MySQL
echo "🔄 [1/3] 启动 MySQL..."
docker rm -f "$DB_NAME" 2>/dev/null || true
docker run -d --name "$DB_NAME" \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_PASSWORD" \
    -e MYSQL_DATABASE="eggy_note" \
    -v "${DB_NAME}-data:/var/lib/mysql" \
    mysql:8.0 \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_general_ci

echo "⏳ 等待 MySQL 就绪..."
for i in $(seq 1 30); do
    if docker exec "$DB_NAME" mysqladmin ping -uroot -p"$MYSQL_PASSWORD" --silent 2>/dev/null; then
        echo "   ✅ MySQL 就绪"
        break
    fi
    sleep 2
done

# 初始化数据库 (幂等)
echo "🔄 初始化数据库表..."
docker exec -i "$DB_NAME" mysql -uroot -p"$MYSQL_PASSWORD" eggy_note 2>/dev/null <<SQL
CREATE TABLE IF NOT EXISTS \`note_book\` (
    \`book_id\` BIGINT NOT NULL AUTO_INCREMENT,
    \`name\` VARCHAR(255) NOT NULL,
    \`user_id\` BIGINT NOT NULL,
    \`created_at\` DATETIME DEFAULT CURRENT_TIMESTAMP,
    \`updated_at\` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (\`book_id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS \`note\` (
    \`note_id\` BIGINT NOT NULL AUTO_INCREMENT,
    \`book_id\` BIGINT DEFAULT NULL,
    \`title\` VARCHAR(255) DEFAULT '未命名笔记',
    \`type\` ENUM('cornell','block','markdown','excel','word') DEFAULT 'block',
    \`summary\` TEXT,
    \`created_at\` DATETIME DEFAULT CURRENT_TIMESTAMP,
    \`updated_at\` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (\`note_id\`),
    KEY \`book_id\` (\`book_id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS \`note_block\` (
    \`block_id\` BIGINT NOT NULL AUTO_INCREMENT,
    \`note_id\` BIGINT DEFAULT NULL,
    \`parent_block_id\` BIGINT DEFAULT NULL,
    \`type\` ENUM('text','image','equation','heading-1','heading-2','todo') DEFAULT 'text',
    \`content\` TEXT,
    \`order_num\` INT DEFAULT 0,
    \`created_at\` DATETIME DEFAULT CURRENT_TIMESTAMP,
    \`updated_at\` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (\`block_id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT IGNORE INTO \`note_book\` (\`book_id\`, \`name\`, \`user_id\`) VALUES (1, '我的笔记本', 1);
SQL
echo "   ✅ 数据库初始化完成"

# 2️⃣ 构建镜像
echo "🔄 [2/3] 构建应用镜像..."
docker build -t "$APP_NAME" .

# 3️⃣ 启动应用
echo "🔄 [3/3] 启动应用..."
docker rm -f "$APP_NAME" 2>/dev/null || true
docker run -d --name "$APP_NAME" \
    -p "${APP_PORT}:80" \
    -e MYSQL_HOST="$DB_NAME" \
    -e MYSQL_USER=root \
    -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
    -e MYSQL_DB=eggy_note \
    --link "$DB_NAME" \
    "$APP_NAME"

echo ""
echo "✅ 部署完成！"
echo "==========================="
echo "   访问地址: http://localhost:${APP_PORT}"
echo "   登录账号: parent / ${MYSQL_PASSWORD}"
echo "==========================="
echo ""
echo "📋 常用命令:"
echo "   docker logs -f $APP_NAME     # 查看日志"
echo "   docker stop $APP_NAME $DB_NAME  # 停止"
echo "   docker start $APP_NAME $DB_NAME # 启动"
echo "   bash run.sh                  # 重新部署"
