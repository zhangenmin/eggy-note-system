# Ruoyi-vue 笔记系统前端组件选型建议

## 1. 核心编辑器：TipTap (Vue 3)
*   **理由**：无头 (Headless) 编辑器，高度可定制，完全符合“块模式”需求。
*   **关键扩展选型**：
    *   `StarterKit`: 基础编辑功能。
    *   `Collaboration`: (进阶) 支持多端同步。
    *   `Mention`: 用于实现 `[[` 双向链接功能。
    *   `Table`: 增强表格支持。
    *   `Placeholder`: 提供输入提示（如："输入 '/' 以唤起指令"）。
    *   `CharacterCount`: 统计字数。
*   **自定义扩展建议**：
    *   `BlockContainer`: 封装每一个块，实现拖拽把手和块菜单。

## 2. 块拖拽与排序：Vue.Draggable.next (vuedraggable)
*   **理由**：基于 Sortable.js，完美支持 Vue 3，用于实现块的拖拽重排和笔记本目录树的组织。

## 3. 布局与组件库：Ruoyi 原生 (Element Plus)
*   **理由**：保持与 Ruoyi 整体风格统一，减少样式冲突。
*   **应用场景**：
    *   `ElTree`: 笔记本目录树显示。
    *   `ElDrawer / ElDialog`: 笔记属性设置、历史记录查看。
    *   `ElTag`: 笔记标签展示。
    *   `ElInput` (带搜索): 全局笔记搜索。

## 4. 知识图谱可视化：ECharts 5
*   **理由**：Ruoyi 已内置，且 Graph 图谱功能强大，足以处理笔记引用关系。
*   **特性利用**：
    *   `Force-directed Layout`: 自动排列笔记节点，形成动态网状图。
    *   `Focus`: 点击节点高亮关联引用。

## 5. 公式与代码：KaTeX + Prism.js / Highlight.js
*   **理由**：
    *   `KaTeX`: 极速渲染数学公式（LaTeX）。
    *   `Prism.js`: 轻量级代码高亮，支持多种编程语言。

## 6. 工具函数库：Lodash + Lucide Vue (图标)
*   **理由**：
    *   `Lodash`: 处理块的递归处理（如 `cloneDeep`, `findTree`）。
    *   `Lucide Vue`: 提供现代、简约的图标集，比 Element Plus 自带图标更适合笔记工具。

---

## 7. 前端架构思路
*   **Store (Pinia)**: 建立 `useNoteStore`，统一管理当前编辑笔记的状态、块列表以及同步状态。
*   **Component 划分**:
    *   `EggyEditor`: 包装 TipTap 的主组件。
    *   `EggyBlock`: 递归渲染的块单元组件。
    *   `CornellLayout`: 专门处理三栏布局的容器组件。
    *   `KnowledgeGraph`: 处理 ECharts 渲染的图谱组件。
