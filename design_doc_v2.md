# Ruoyi-vue + Python 后端笔记系统设计文档 (补充)

## 4. API 接口设计 (FastAPI)

| 模块 | 路径 | 方法 | 功能 |
| :--- | :--- | :--- | :--- |
| **笔记本** | `/api/notebook/list` | GET | 获取用户笔记本列表 |
| | `/api/notebook/add` | POST | 新增笔记本 |
| | `/api/notebook/update` | PUT | 更新笔记本 |
| **笔记** | `/api/note/list` | GET | 获取笔记列表（支持 type 筛选） |
| | `/api/note/add` | POST | 新增笔记 |
| | `/api/note/update` | PUT | 更新笔记 |
| | `/api/note/delete` | DELETE | 删除笔记 |
| **笔记块** | `/api/block/list` | GET | 获取笔记块（树结构返回） |
| | `/api/block/add` | POST | 新增块 |
| | `/api/block/update` | PUT | 更新块 |
| | `/api/block/delete` | DELETE | 删除块及所有关联子块 |
| **链接** | `/api/link/add` | POST | 创建笔记间引用（双向链接基础） |
| | `/api/link/list` | GET | 获取笔记引用关系图数据 |
| **标签** | `/api/tag/list` | GET | 查询所有可用标签 |
| | `/api/tag/add` | POST | 新增标签定义 |
| | `/api/tag/assign` | POST | 为笔记分配/取消标签 |

---

## 5. 前端设计 (Ruoyi-vue)

*   **首页布局**
    *   **左侧栏**：笔记本目录树 + 标签云（支持拖拽组织）。
    *   **中间区域**：笔记卡片列表，支持高级搜索（全文搜索 + 标签筛选）。
    *   **工具栏**：一键切换“康奈尔模式”或“块模式”，快速新建按钮。
*   **笔记详情/编辑器**
    *   **康奈尔模式**：经典的左侧“线索栏”、右上“笔记栏”、右下“总结栏”布局。
    *   **块模式**：类 Notion 的树形渲染，支持块的无限嵌套、拖拽重排。
    *   **双链支持**：输入 `[[` 自动触发笔记搜索并创建双向引用链接。
*   **核心编辑器 (TipTap)**
    *   基于块的扩展，支持图片上传、LaTeX 公式、Markdown 快捷输入、多维表格。
*   **知识图谱**
    *   集成 ECharts Graph，直观展示笔记块之间的引用拓扑关系。

---

## 6. 开发蓝图

1.  **阶段 1：核心骨架 (MVP)**
    *   后端：FastAPI + SQLAlchemy 实现笔记本/笔记/块的基本 CRUD。
    *   前端：在 Ruoyi-vue 中集成基础列表页，完成 TipTap 编辑器的最小化接入。
2.  **阶段 2：交互增强**
    *   实现块模式的树形结构渲染与操作逻辑。
    *   完成康奈尔三栏布局的 UI 适配。
3.  **阶段 3：智能连接**
    *   开发双向链接 (`[[`) 逻辑与 `NoteLink` 维护。
    *   实现 ECharts 知识图谱的可视化展示。
4.  **阶段 4：生态扩展**
    *   版本管理（历史记录回溯）。
    *   多用户权限精细化控制（基于 Ruoyi 原生权限）。
    *   全局搜索与 AI 辅助总结。
