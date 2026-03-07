# Ruoyi-vue + Python 后端笔记系统设计文档

## 1. 技术栈
*   **前端**：Ruoyi-vue（Vue3 + ElementPlus + Vite）
    *   保留 Ruoyi 的布局、权限管理、组件库
    *   自定义模块：笔记本、笔记页、编辑器、知识网络视图
*   **后端**：Python (FastAPI)
    *   提供 RESTful API
    *   支持 JWT 授权（兼容 Ruoyi 前端 Token 验证）
    *   ORM：SQLAlchemy + Alembic
*   **数据库**：MySQL
    *   支持 Ruoyi 默认数据库结构
*   **富文本编辑器**：TipTap（块模式 + 康奈尔三栏模式）
*   **图谱/可视化**：ECharts / D3.js

---

## 2. 数据库设计

### 2.1 核心表
**NoteBook 表**
```sql
CREATE TABLE note_book (
    book_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    user_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Note 表**
```sql
CREATE TABLE note (
    note_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    book_id BIGINT NOT NULL,
    title VARCHAR(255),
    type ENUM('cornell','block') DEFAULT 'block',
    summary TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES note_book(book_id)
);
```

**NoteBlock 表**
```sql
CREATE TABLE note_block (
    block_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    note_id BIGINT NOT NULL,
    parent_block_id BIGINT DEFAULT NULL,
    type ENUM('text','image','equation') DEFAULT 'text',
    content TEXT,
    order_num INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (note_id) REFERENCES note(note_id)
);
```

**NoteLink 表**
```sql
CREATE TABLE note_link (
    link_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    from_block_id BIGINT NOT NULL,
    to_note_id BIGINT NOT NULL,
    FOREIGN KEY (from_block_id) REFERENCES note_block(block_id),
    FOREIGN KEY (to_note_id) REFERENCES note(note_id)
);
```

**NoteTag 表**
```sql
CREATE TABLE note_tag (
    tag_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE
);
```

**NoteTagRel 表**
```sql
CREATE TABLE note_tag_rel (
    note_id BIGINT,
    tag_id BIGINT,
    PRIMARY KEY (note_id, tag_id),
    FOREIGN KEY (note_id) REFERENCES note(note_id),
    FOREIGN KEY (tag_id) REFERENCES note_tag(tag_id)
);
```

---

## 3. Python ORM 例子（SQLAlchemy）

```python
from sqlalchemy import Column, String, Integer, Text, ForeignKey, Enum, DateTime, func
from sqlalchemy.orm import relationship
# from database import Base

class NoteBook(Base):
    __tablename__ = 'note_book'
    book_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    user_id = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    notes = relationship("Note", back_populates="book")

class Note(Base):
    __tablename__ = 'note'
    note_id = Column(Integer, primary_key=True, autoincrement=True)
    book_id = Column(Integer, ForeignKey('note_book.book_id'))
    title = Column(String(255))
    type = Column(Enum('cornell','block'), default='block')
    summary = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    book = relationship("NoteBook", back_populates="notes")
    blocks = relationship("NoteBlock", back_populates="note")

class NoteBlock(Base):
    __tablename__ = 'note_block'
    block_id = Column(Integer, primary_key=True, autoincrement=True)
    note_id = Column(Integer, ForeignKey('note.note_id'))
    parent_block_id = Column(Integer, ForeignKey('note_block.block_id'), nullable=True)
    type = Column(Enum('text','image','equation'), default='text')
    content = Column(Text)
    order_num = Column(Integer, default=0)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    note = relationship("Note", back_populates="blocks")
    # children = relationship("NoteBlock", backref="parent", remote_side=[block_id])
```
