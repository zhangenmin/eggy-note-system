FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv nginx curl mysql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制项目文件
COPY backend/ ./backend/
COPY frontend/dist/ ./frontend/dist/
COPY init_db.sql /app/init_db.sql
COPY nginx.conf /etc/nginx/conf.d/chuhuai-note.conf
COPY start.sh /app/start.sh

# 移除默认 nginx 站点
RUN rm -f /etc/nginx/sites-enabled/default 2>/dev/null; \
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache-dir fastapi uvicorn sqlalchemy pymysql pydantic && \
    chmod +x /app/start.sh && \
    rm -rf /root/.cache/pip

EXPOSE 80

CMD ["/app/start.sh"]
