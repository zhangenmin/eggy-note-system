from pydantic import BaseModel
from typing import List, Optional

class BlockBase(BaseModel):
    type: str
    content: Optional[str] = None
    order_num: int = 0
    parent_block_id: Optional[int] = None
    attrs: Optional[dict] = None

class NoteSaveRequest(BaseModel):
    title: str
    type: str = "block"
    summary: Optional[str] = None
    blocks: List[dict] # 接收 TipTap 的 JSON 结构

@app.post("/api/note/save/{note_id}")
async def save_note_full(note_id: int, data: NoteSaveRequest, db: Session = Depends(get_db)):
    # 1. 更新笔记基本信息
    note = db.query(models.Note).filter(models.Note.note_id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="笔记不存在")
    
    note.title = data.title
    note.type = data.type
    note.summary = data.summary
    
    # 2. 块的持久化逻辑 (极简策略：先删后插，保证顺序和结构一致)
    db.query(models.NoteBlock).filter(models.NoteBlock.note_id == note_id).delete()
    
    def process_blocks(blocks_json, parent_id=None):
        for index, b in enumerate(blocks_json):
            # 提取 TipTap 的文本内容
            text_content = ""
            if "content" in b and isinstance(b["content"], list):
                for c in b["content"]:
                    if c.get("type") == "text":
                        text_content += c.get("text", "")
            
            new_block = models.NoteBlock(
                note_id=note_id,
                parent_block_id=parent_id,
                type=b.get("type", "text"),
                content=text_content or str(b.get("attrs", "")),
                order_num=index
            )
            db.add(new_block)
            db.flush() # 获取新插入的 ID
            
            # 如果有嵌套子块，递归处理
            if "content" in b and isinstance(b["content"], list):
                # 排除纯文本项，处理嵌套节点
                sub_nodes = [item for item in b["content"] if item.get("type") != "text"]
                if sub_nodes:
                    process_blocks(sub_nodes, parent_id=new_block.block_id)

    if data.blocks:
        process_blocks(data.blocks)
        
    db.commit()
    return {"status": "success", "message": "笔记已深度同步"}
