# Ruoyi-vue Note Module Structure

src/views/note/
├── index.vue                # 笔记主页面 (三栏布局: 笔记本树 | 笔记列表 | 编辑器)
├── components/
│   ├── NotebookTree.vue     # 左侧笔记本/目录管理
│   ├── NoteList.vue         # 中间笔记搜索与列表
│   ├── CornellLayout.vue    # 康奈尔模式容器
│   └── KnowledgeGraph.vue   # ECharts 知识图谱组件
└── editor/
    ├── index.vue            # TipTap 主编辑器入口
    ├── extensions/          # 自定义 TipTap 扩展 (Mention, BlockContainer)
    └── BubbleMenu.vue       # 选中文字后的浮动菜单

src/store/modules/note.js    # Pinia 状态管理 (当前笔记、块列表、同步状态)
