<template>
  <node-view-wrapper class="latex-block-wrapper">
    <div 
      :class="['latex-display', { 'is-editing': isEditing }]" 
      @click="startEditing"
    >
      <div v-if="!node.attrs.latex && !isEditing" class="latex-placeholder">
        点击输入 LaTeX 公式...
      </div>
      <div v-else-if="!isEditing" class="latex-rendered" v-html="renderedHtml"></div>
      
      <div v-if="isEditing" class="latex-editor-box animate__animated animate__fadeIn">
        <textarea
          ref="inputRef"
          v-model="latexInput"
          class="latex-input"
          placeholder="例如: E = mc^2"
          @blur="stopEditing"
          @keydown.enter.exact.prevent="stopEditing"
        ></textarea>
        <div class="latex-preview-label">预览:</div>
        <div class="latex-preview-content" v-html="previewHtml"></div>
      </div>
    </div>
  </node-view-wrapper>
</template>

<script setup>
import { ref, computed, nextTick, onMounted } from 'vue'
import { nodeViewProps, NodeViewWrapper } from '@tiptap/vue-3'
import katex from 'katex'
import 'katex/dist/katex.min.css'

const props = defineProps(nodeViewProps)
const isEditing = ref(false)
const latexInput = ref(props.node.attrs.latex || '')
const inputRef = ref(null)

const renderedHtml = computed(() => {
  try {
    return katex.renderToString(props.node.attrs.latex || '', {
      displayMode: true,
      throwOnError: false
    })
  } catch (e) {
    return `<span class="text-red-500">解析错误</span>`
  }
})

const previewHtml = computed(() => {
  try {
    return katex.renderToString(latexInput.value || '\\dots', {
      displayMode: true,
      throwOnError: false
    })
  } catch (e) {
    return ''
  }
})

const startEditing = () => {
  isEditing.value = true
  nextTick(() => {
    inputRef.value?.focus()
  })
}

const stopEditing = () => {
  isEditing.value = false
  props.updateAttributes({
    latex: latexInput.value
  })
}
</script>

<style scoped>
.latex-block-wrapper {
  margin: 1.5rem 0;
}
.latex-display {
  padding: 1rem;
  border-radius: 12px;
  background: #fdfdfd;
  border: 2px solid transparent;
  transition: all 0.2s;
  cursor: pointer;
  text-align: center;
}
.latex-display:hover {
  background: #f8f9fa;
  border-color: #e9ecef;
}
.latex-display.is-editing {
  background: white;
  border-color: #2563eb;
  cursor: default;
}
.latex-placeholder {
  color: #adb5bd;
  font-style: italic;
}
.latex-editor-box {
  text-align: left;
  padding: 0.5rem;
}
.latex-input {
  width: 100%;
  font-family: monospace;
  padding: 0.75rem;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  outline: none;
  font-size: 0.9rem;
}
.latex-preview-label {
  font-size: 10px;
  font-weight: bold;
  color: #999;
  margin-top: 1rem;
  text-transform: uppercase;
}
.latex-preview-content {
  padding: 1rem;
  border-bottom: 1px solid #f0f0f0;
}
</style>
