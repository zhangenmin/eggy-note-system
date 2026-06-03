#!/bin/bash
# ==============================================
#  楚淮笔记系统 — Docker Run 一键部署
#  无需 docker-compose，一行命令启动
# ==============================================
set -e

APP_NAME="chuhuai-note"
DB_NAME="chuhuai-mysql"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-Jschrj83130911!}"
APP_PORT="${APP_PORT:-8080}"
IMAGE="${IMAGE:-ghcr.io/zhangenmin/eggy-note-system:latest}"

echo "🚀 楚淮笔记系统 — Docker Run 一键部署"
echo "======================================"

# 检查 Docker
if ! command -v docker &>/dev/null; then
    echo "❌ Docker 未安装，请先安装: https://docs.docker.com/engine/install/"
    exit 1
fi

# 拉取镜像（若未构建则本地构建）
if docker pull "$IMAGE" 2>/dev/null; then
    echo "✅ 镜像拉取成功: $IMAGE"
    BUILD_CMD=""
else
    echo "⚠️  无法拉取远程镜像，本地构建中..."
    BUILD_CMD="$(docker build -q .)"
    IMAGE="$BUILD_CMD"
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
    [ "$i" -eq 30 ] && echo "❌ MySQL 启动超时" && exit 1
    sleep 2
done

# 初始化数据库
echo "🔄 初始化数据库..."
docker exec -i "$DB_NAME" mysql -uroot -p"$MYSQL_PASSWORD" eggy_note <<SQL
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

# 2️⃣ 启动应用
echo "🔄 [2/3] 启动应用..."
docker rm -f "$APP_NAME" 2>/dev/null || true
docker run -d --name "$APP_NAME" \
    -p "${APP_PORT}:80" \
    -e MYSQL_HOST="$DB_NAME" \
    -e MYSQL_USER=root \
    -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
    -e MYSQL_DB="eggy_note" \
    --link "$DB_NAME" \
    "$IMAGE"

echo ""
echo "✅ 部署完成！"
echo "============================"
echo "   地址: http://localhost:${APP_PORT}"
echo "   账号: parent / ${MYSQL_PASSWORD}"
echo "============================"
echo ""
echo "📋 常用命令:"
echo "   docker logs -f $APP_NAME"
echo "   docker stop $APP_NAME $DB_NAME"
echo "   docker start $APP_NAME $DB_NAME"
echo "   curl -fsSL https://tinyurl.com/xxx | bash  # 在线部署"
