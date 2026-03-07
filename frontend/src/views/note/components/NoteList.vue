<template>
  <div class="note-list-container">
    <div class="list-header">
      <el-input v-model="queryParams.title" placeholder="搜索笔记..." prefix-icon="Search" clearable @input="handleQuery" />
      <el-button type="primary" icon="Plus" circle @click="handleAdd" />
    </div>
    
    <div v-loading="loading" class="note-items">
      <div v-for="item in noteList" :key="item.noteId" 
           :class="['note-item', { active: currentNoteId === item.noteId }]"
           @click="handleSelect(item)">
        <div class="note-title">{{ item.title || '未命名笔记' }}</div>
        <div class="note-meta">
          <el-tag size="small" :type="item.type === 'cornell' ? 'warning' : 'success'">
            {{ item.type === 'cornell' ? '康奈尔' : '块模式' }}
          </el-tag>
          <span class="time">{{ parseTime(item.updatedAt, '{m}-{d} {h}:{i}') }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const loading = ref(false);
const noteList = ref([]);
const currentNoteId = ref(null);
const queryParams = ref({ title: '' });

const fetchData = async () => {
  loading.value = true;
  // 这里调用 Ruoyi 的 listNote API
  // const res = await listNote(queryParams.value);
  // noteList.value = res.rows;
  loading.value = false;
};

const handleSelect = (note) => {
  currentNoteId.value = note.noteId;
  emit('select', note);
};

const emit = defineEmits(['select']);
</script>

<style scoped>
.note-item {
  padding: 15px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: background 0.2s;
}
.note-item:hover { background: #f9f9f9; }
.note-item.active { background: #fff7e6; border-right: 3px solid #ffa940; }
.note-title { font-weight: bold; margin-bottom: 8px; color: #333; }
.note-meta { display: flex; justify-content: space-between; align-items: center; }
.time { font-size: 12px; color: #999; }
</style>
