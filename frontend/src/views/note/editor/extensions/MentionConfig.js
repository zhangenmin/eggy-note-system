import { VueRenderer } from '@tiptap/vue-3'
import tippy from 'tippy.js'
import MentionList from './MentionList.vue'

/**
 * 笔记双向链接渲染逻辑
 * 当在编辑器输入 [[ 时触发
 */
export default {
  items: async ({ query }) => {
    // 实际生产环境这里会调用 API: /api/note/list?title={query}
    // 这里先模拟几条数据测试效果
    const mockNotes = [
      { id: 1, title: '关于 OpenClaw 的思考', summary: '探讨 AI 助手未来的发展方向...' },
      { id: 2, title: '蛋仔成长基地 v7.1 发布日志', summary: '修复了删除任务的 BUG，增加了 3D 卡片...' },
      { id: 3, title: 'Rust 学习笔记', summary: '所有权、借用检查器与生命周期...' },
    ]
    return mockNotes.filter(item => 
      item.title.toLowerCase().includes(query.toLowerCase())
    ).slice(0, 5)
  },

  render: () => {
    let component
    let popup

    return {
      onStart: props => {
        component = new VueRenderer(MentionList, {
          props,
          editor: props.editor,
        })

        if (!props.clientRect) {
          return
        }

        popup = tippy('body', {
          getReferenceClientRect: props.clientRect,
          appendTo: () => document.body,
          content: component.element,
          showOnCreate: true,
          interactive: true,
          trigger: 'manual',
          placement: 'bottom-start',
        })
      },

      onUpdate(props) {
        component.updateProps(props)

        if (!props.clientRect) {
          return
        }

        popup[0].setProps({
          getReferenceClientRect: props.clientRect,
        })
      },

      onKeyDown(props) {
        if (props.event.key === 'Escape') {
          popup[0].hide()
          return true
        }
        return component.ref?.onKeyDown(props)
      },

      onExit() {
        popup[0].destroy()
        component.destroy()
      },
    }
  },
}
