import { Node, mergeAttributes } from '@tiptap/core'
import { VueNodeViewRenderer } from '@tiptap/vue-3'
import MathematicsView from './MathematicsView.vue'

/**
 * 蛋仔笔记 LaTeX 公式扩展
 * 实现所见即所得的公式编辑
 */
const Mathematics = Node.create({
  name: 'mathematics',
  group: 'block',
  atom: true,

  addAttributes() {
    return {
      latex: {
        default: '',
      },
    }
  },

  parseHTML() {
    return [
      {
        tag: 'div[data-type="mathematics"]',
      },
    ]
  },

  renderHTML({ HTMLAttributes }) {
    return ['div', mergeAttributes(HTMLAttributes, { 'data-type': 'mathematics' })]
  },

  addNodeView() {
    return VueNodeViewRenderer(MathematicsView)
  },

  addCommands() {
    return {
      insertMathematics: () => ({ commands }) => {
        return commands.insertContent({ type: this.name })
      },
    }
  },
})

export default Mathematics
