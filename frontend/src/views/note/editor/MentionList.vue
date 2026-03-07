<template>
  <div class="mention-list-container bg-white shadow-2xl border rounded-xl overflow-hidden min-w-[200px] animate__animated animate__fadeInUp">
    <div class="p-2 bg-gray-50 border-b flex items-center justify-between">
      <span class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">引用笔记</span>
      <span class="text-[10px] bg-blue-100 text-blue-600 px-1.5 py-0.5 rounded">[[</span>
    </div>
    
    <div v-if="items.length" class="max-h-60 overflow-y-auto">
      <button
        v-for="(item, index) in items"
        :key="item.id"
        :class="['w-full text-left px-4 py-3 flex items-center space-x-3 transition-colors hover:bg-blue-50', { 'bg-blue-50': index === selectedIndex }]"
        @click="selectItem(index)"
      >
        <span class="text-xl">📄</span>
        <div class="flex-1 overflow-hidden">
          <div class="font-bold text-sm text-gray-800 truncate">{{ item.title || '无标题笔记' }}</div>
          <div class="text-[10px] text-gray-400 truncate">{{ item.summary || '暂无摘要' }}</div>
        </div>
      </button>
    </div>
    
    <div v-else class="p-6 text-center text-gray-400">
      <div class="text-2xl mb-2">🔍</div>
      <p class="text-xs">未找到匹配的笔记</p>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  items: { type: Array, required: true },
  command: { type: Function, required: true },
})

const selectedIndex = ref(0)

// 监听键盘上下选择逻辑 (由 TipTap 传递)
const onKeyDown = ({ event }) => {
  if (event.key === 'ArrowUp') {
    selectedIndex.value = ((selectedIndex.value + props.items.length) - 1) % props.items.length
    return true
  }
  if (event.key === 'ArrowDown') {
    selectedIndex.value = (selectedIndex.value + 1) % props.items.length
    return true
  }
  if (event.key === 'Enter') {
    selectItem(selectedIndex.value)
    return true
  }
  return false
}

const selectItem = (index) => {
  const item = props.items[index]
  if (item) {
    props.command({ id: item.id, label: item.title })
  }
}

// 暴露出方法供父级或扩展调用
defineExpose({ onKeyDown })
</script>

<style scoped>
.mention-list-container {
  z-index: 1000;
}
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
