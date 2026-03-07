<template>
  <div class="eggy-editor-wrapper" :class="{ 'cornell-mode': isCornell }">
    <div class="editor-toolbar flex items-center justify-between p-2 bg-white border-b sticky top-0 z-10">
      <div class="flex space-x-2">
        <el-button-group>
          <el-button :type="!isCornell ? 'primary' : ''" @click="isCornell = false">块模式</el-button>
          <el-button :type="isCornell ? 'primary' : ''" @click="isCornell = true">康奈尔</el-button>
        </el-button-group>
        <el-divider direction="vertical" />
        <!-- 新增公式插入按钮 -->
        <el-button size="small" @click="editor.chain().focus().insertMathematics().run()">
          Σ 公式
        </el-button>
      </div>
      <div v-if="editor" class="flex space-x-2 items-center">
        <span class="text-xs text-gray-400">{{ editor.storage.characterCount.characters() }} 字</span>
        <el-button type="success" size="small" @click="saveNote">保存</el-button>
      </div>
    </div>

    <div class="editor-content-container p-4 overflow-y-auto">
      <div v-if="isCornell" class="cornell-layout grid grid-cols-4 gap-4">
        <div class="cue-column col-span-1 border-r pr-4 min-h-[500px]">
          <h3 class="text-xs font-bold text-gray-400 mb-2 uppercase">线索 / 关键词</h3>
          <div class="cue-content text-sm text-gray-600 space-y-4">
            <div class="tip-card p-2 bg-blue-50 rounded-lg text-[10px]">
              🚀 <strong>快捷键提示：</strong><br>
              输入 [[ 链接笔记<br>
              点击 Σ 插入公式
            </div>
          </div>
        </div>
        <div class="note-column col-span-3 min-h-[500px]">
          <h3 class="text-xs font-bold text-gray-400 mb-2 uppercase">笔记正文</h3>
          <editor-content :editor="editor" />
        </div>
        <div class="summary-column col-span-4 mt-4 p-4 bg-yellow-50 rounded-xl border-2 border-dashed border-yellow-200">
          <h3 class="text-xs font-bold text-yellow-700 mb-2 uppercase">总结</h3>
          <textarea v-model="summary" class="w-full bg-transparent outline-none text-sm" placeholder="用一句话总结今天的收获..."></textarea>
        </div>
      </div>

      <div v-else class="block-layout max-w-3xl mx-auto">
        <editor-content :editor="editor" />
      </div>
    </div>

    <bubble-menu v-if="editor" :editor="editor" :tippy-options="{ duration: 100 }">
      <div class="bubble-menu bg-white shadow-xl border rounded-lg p-1 flex space-x-1">
        <button @click="editor.chain().focus().toggleBold().run()" :class="{ 'is-active': editor.isActive('bold') }">B</button>
        <button @click="editor.chain().focus().toggleCodeBlock().run()">Code</button>
      </div>
    </bubble-menu>
  </div>
</template>

<script setup>
import { ref, onBeforeUnmount } from 'vue'
import { Editor, EditorContent, BubbleMenu } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Mention from '@tiptap/extension-mention'
import Placeholder from '@tiptap/extension-placeholder'
import CharacterCount from '@tiptap/extension-character-count'
import MentionConfig from './extensions/MentionConfig'
import Mathematics from './extensions/Mathematics'

const isCornell = ref(false)
const summary = ref('')

const editor = new Editor({
  extensions: [
    StarterKit,
    CharacterCount,
    Placeholder.configure({
      placeholder: "输入 '/' 唤起指令，输入 '[[' 链接笔记...",
    }),
    Mention.configure({
      HTMLAttributes: { class: 'mention-link' },
      suggestion: MentionConfig,
    }),
    Mathematics, // 注册 LaTeX 公式扩展
  ],
  content: `
    <h2>欢迎使用蛋仔笔记  v1.1 🚀</h2>
    <p>这是一个<strong>深度定制</strong>的学术级编辑器。</p>
    <div data-type="mathematics" latex="f(x) = \\int_{-\\infty}^{\\infty} \\hat{f}(\\xi) e^{2\\pi i x \\xi} d\\xi"></div>
    <p>点击上方公式试试看！</p>
  `,
})

const saveNote = async () => {
  const json = editor.getJSON()
  try {
    const res = await fetch(`/api/note/save/${props.noteId || 1}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        title: '我的新笔记',
        type: isCornell.value ? 'cornell' : 'block',
        summary: summary.value,
        content_json: json
      })
    })
    if (res.ok) {
       console.log('笔记已同步至 MySQL')
    }
  } catch (e) {
    console.error('同步失败')
  }
}

onBeforeUnmount(() => {
  editor.destroy()
})
</script>

<style scoped>
.eggy-editor-wrapper { height: 100%; display: flex; flex-direction: column; background: white; }
:deep(.mention-link) { 
  color: #2563eb; 
  background: #eff6ff; 
  padding: 2px 6px; 
  border-radius: 4px; 
  font-weight: bold; 
  text-decoration: none;
  cursor: pointer;
  border: 1px solid #dbeafe;
}
:deep(.mention-link):hover { background: #dbeafe; }

.bubble-menu button { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
.bubble-menu button:hover { background: #f3f4f6; }
.bubble-menu button.is-active { color: #2563eb; background: #eff6ff; }

:deep(.ProseMirror) { outline: none; min-height: 400px; }
:deep(.ProseMirror p.is-editor-empty:first-child::before) {
  content: attr(data-placeholder);
  float: left;
  color: #adb5bd;
  pointer-events: none;
  height: 0;
}
</style>
