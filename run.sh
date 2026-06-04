#!/bin/bash
# ============================================================
#  楚淮笔记系统 — 一键启动脚本（使用已有数据库）
#  Usage:
#    bash run.sh
#    自定义连接参数：
#    MYSQL_HOST=192.168.1.100 MYSQL_USER=admin MYSQL_PASSWORD=xxx bash run.sh
# ============================================================
set -e

APP_NAME="chuhuai-note"

# ---- 数据库连接配置（改成你自己的） ----
MYSQL_HOST="${MYSQL_HOST:-host.docker.internal}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-Jschrj83130911!}"
MYSQL_DB="${MYSQL_DB:-eggy_note}"
APP_PORT="${APP_PORT:-8080}"

echo "🚀 楚淮笔记系统 — 一键部署"
echo "==========================="
echo "   数据库: ${MYSQL_USER}@${MYSQL_HOST}/${MYSQL_DB}"
echo "   端口:   ${APP_PORT}"
echo "==========================="

# 检查 Docker
if ! command -v docker &>/dev/null; then
    echo "❌ 未安装 Docker，请先安装: https://docs.docker.com/engine/install/"
    exit 1
fi

# 1️ 构建镜像
echo "🔧 [1/2] 构建应用镜像..."
docker build -t "${APP_NAME}" .

# 2️ 启动应用
echo "🔧 [2/2] 启动应用..."
docker rm -f "${APP_NAME}" 2>/dev/null || true
docker run -d --name "${APP_NAME}" \
    -p "${APP_PORT}:80" \
    -e MYSQL_HOST="${MYSQL_HOST}" \
    -e MYSQL_USER="${MYSQL_USER}" \
    -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
    -e MYSQL_DB="${MYSQL_DB}" \
    "${APP_NAME}"

echo ""
echo "✅ 部署完成！"
echo "==========================="
echo "   访问地址: http://localhost:${APP_PORT}"
echo "   登录账号: parent / ${MYSQL_PASSWORD}"
echo "==========================="
echo ""
echo "📋 常用命令:"
echo "   docker logs -f ${APP_NAME}     # 查看日志"
echo "   docker stop ${APP_NAME}        # 停止"
echo "   docker start ${APP_NAME}       # 启动"
echo "   bash run.sh                    # 重新部署"
