# 楚淮笔记系统 📝

> 灵感与代码的避风港 —— 一款轻量级、全功能的在线笔记应用

![Version](https://img.shields.io/badge/version-2.1-blue)
![Vue 3](https://img.shields.io/badge/Vue-3-4FC08D)
![FastAPI](https://img.shields.io/badge/FastAPI-0.136-009688)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ 功能特性

### 📝 多种笔记模式
| 模式 | 说明 |
|------|------|
| **纯文本** | 简洁的文字编辑，轻量快速 |
| **康奈尔** | Cornell 笔记法，正文 + 总结栏分离 |
| **Markdown** | 双栏实时预览，支持代码高亮 (Prism.js) |
| **Word** 🆕 | 基于 Quill.js 的富文本编辑器（标题、加粗、颜色、列表、引用等） |
| **Excel** 🆕 | 纯前端电子表格，支持粘贴拆列、导入/导出 .xlsx |

### 📊 Excel 模式亮点
- 粘贴 Tab/换行分隔数据 → **自动拆分行列**
- 增删行/列（任意位置插入或删除）
- **Tab** 切换单元格，**Enter** 下移
- 导出 `.xlsx` / 导入 `.xlsx`
- 数据以 JSON 存储，读写零失真

### 📄 Word 模式亮点
- 所见即所得的富文本编辑
- 支持：标题 H1~H3、加粗/斜体/下划线/删除线
- 字体颜色/背景色、有序/无序列表、对齐方式
- 引用块、代码块、链接、图片
- 内容存为 HTML，兼容性强

### 🗂 笔记本管理
- 多笔记本分组管理
- 笔记本重命名 / 删除
- 笔记卡片概览，类型徽标颜色区分

### 🔐 登录认证
- 支持现有账号体系（兼容 study-tracker）
- 内置管理员账号兜底

## 🏗 技术架构

```
                  Cloudflare (CDN + Proxy)
                         │
                     Nginx (反向代理)
                    ┌────┴────┐
                    │         │
             前端静态文件      API 转发
           (Vue 3 SPA)      (FastAPI)
              │                  │
         Tailwind CSS        MySQL 8.0
         Quill.js + SheetJS   eggy_note
```

| 层 | 技术 |
|----|------|
| **前端** | Vue 3 (CDN) + Tailwind CSS + Quill.js + SheetJS |
| **后端** | Python FastAPI + SQLAlchemy + PyMySQL |
| **数据库** | MySQL 8.0 (`eggy_note`) |
| **服务器** | Ubuntu 24.04 + Nginx |
| **代理** | Cloudflare (SSL + CDN) |

## 🚀 快速开始

### 1. 环境要求
- Python 3.10+
- MySQL 8.0+
- Node.js (可选，用于前端开发)

### 2. 数据库初始化
```bash
mysql -u root -p < init_db.sql
```

### 3. 后端启动
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn sqlalchemy pymysql pydantic
python3 main.py
# 运行在 http://0.0.0.0:8080
```

### 4. 前端部署
```bash
# 前端是单文件 SPA，直接部署 dist/index.html 到任意 HTTP 服务器即可
# Nginx 配置示例:
#   root /path/to/frontend/dist;
#   location /api/ { proxy_pass http://127.0.0.1:8080/api/; }
```

### 5. 登录
默认管理员账号：
- 用户名: `parent`
- 密码: `Jschrj83130911!`

## 🐳 Docker 部署（推荐）

### 方法一：一条命令（无需克隆项目）

```bash
# 只需要有 Docker，一行启动
bash <(curl -fsSL https://raw.githubusercontent.com/zhangenmin/eggy-note-system/main/docker-run.sh)
```

### 方法二：docker-compose（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/zhangenmin/eggy-note-system.git
cd eggy-note-system

# 2. 构建并启动（首次约1-2分钟）
docker compose up -d

# 3. 打开浏览器访问
# http://localhost:8080
```

### 方法三：纯 docker run

```bash
# 克隆+构建+启动一步到位
bash run.sh
```

> 默认登录账号：`parent` / `Jschrj83130911!`
> 默认端口：`8080`，可通过 `APP_PORT=8888 bash run.sh` 自定义

### 架构说明

```
┌─────────────────────────────────────┐
│  docker-compose.yml / docker run    │
│  ┌──────────────┐  ┌──────────────┐ │
│  │ chuhuai-     │  │ chuhuai-     │ │
│  │ mysql        │◄─┤ note (app)   │ │
│  │ (:3306)      │  │ (:80 → 8080) │ │
│  └──────────────┘  └──────┬───────┘ │
│                           │         │
│                    Nginx(前端静态)   │
│                    + FastAPI(后端)   │
└─────────────────────────────────────┘
```

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MYSQL_HOST` | `mysql` | 数据库地址 |
| `MYSQL_USER` | `root` | 数据库用户 |
| `MYSQL_PASSWORD` | `Jschrj83130911!` | 数据库密码 |
| `MYSQL_DB` | `eggy_note` | 数据库名 |
| `APP_PORT` | `8080` | 宿主机端口 |

### Docker 文件

| 文件 | 作用 |
|------|------|
| `Dockerfile` | Ubuntu 24.04 + Nginx + Python 虚拟环境 |
| `docker-compose.yml` | MySQL 8.0 + App 服务编排 |
| `docker-run.sh` | curl \| bash 一键部署脚本 |
| `run.sh` | 本地克隆后一键启动 |
| `nginx.conf` | 反向代理 / 静态文件服务 |
| `start.sh` | 容器启动脚本 |
| `.dockerignore` | 构建排除 |
| `.github/workflows/docker-publish.yml` | GitHub Actions 自动构建镜像到 ghcr.io |

## 📂 项目结构
```
├── backend/
│   ├── main.py              # FastAPI 入口，路由 & 逻辑
│   ├── app/
│   │   ├── models.py        # SQLAlchemy ORM 模型
│   │   └── __init__.py
│   ├── venv/                # Python 虚拟环境
│   └── start.sh             # 启动脚本
├── frontend/
│   ├── dist/
│   │   └── index.html       # 生产部署文件（单页应用）
│   └── src/                 # Vue 组件源码
├── deploy/                  # 旧版部署参考
├── init_db.sql              # 数据库建表脚本
├── Dockerfile               # 镜像构建
├── docker-compose.yml       # docker-compose 编排
├── docker-run.sh            # curl | bash 一键脚本
├── run.sh                   # git clone 后一键启动
├── nginx.conf               # Nginx 配置
├── start.sh                 # 容器启动脚本
├── .dockerignore            # Docker 构建排除
├── .github/
│   └── workflows/
│       └── docker-publish.yml  # GitHub Actions 自动构建
└── README.md
```

## 🔄 API 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/login` | 用户登录 |
| GET | `/api/health` | 健康检查 |
| GET | `/api/notebook/list` | 获取笔记本列表 |
| POST | `/api/notebook/create` | 创建笔记本 |
| PUT | `/api/notebook/{id}` | 重命名笔记本 |
| DELETE | `/api/notebook/{id}` | 删除笔记本 |
| GET | `/api/note/list?book_id=1` | 获取笔记列表 |
| POST | `/api/note/save/{id}` | 保存笔记 |
| DELETE | `/api/note/{id}` | 删除笔记 |

## 📜 更新日志

### v2.1 (2026-06-02)
- ✨ 新增 **Word 模式**（Quill 富文本编辑器）
- ✨ 新增 **Excel 模式**（表格编辑，导入导出 .xlsx）
- 🎯 智能粘贴：Tab/换行数据自动拆行列
- 🏷 笔记卡片类型徽标
- 🏗 后端：SQLAlchemy 枚举扩展，systemd 守护
- 📖 README 文档

### v2.0
- 安全加固，登录认证
- Markdown 编辑器 + 代码高亮
- 康奈尔笔记模式

### v1.0
- 基础笔记 CRUD
- 笔记本管理
- 块编辑模式

## 📦 依赖

### 前端 (CDN)
- [Vue 3](https://vuejs.org/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Quill.js](https://quilljs.com/) (Word 编辑)
- [SheetJS](https://sheetjs.com/) (Excel 导入导出)
- [Marked](https://marked.js.org/) (Markdown 解析)
- [Prism.js](https://prismjs.com/) (代码高亮)

### 后端 (Python)
- FastAPI
- SQLAlchemy
- PyMySQL
- Uvicorn
- Pydantic

## 📄 License

MIT License © 2026 楚淮笔记系统
