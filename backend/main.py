from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app import models
from pydantic import BaseModel
from typing import List, Optional
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:Jschrj83130911!@localhost/eggy_note"
engine = create_engine(SQLALCHEMY_DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 强制同步表结构
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class NoteSaveRequest(BaseModel):
    title: str
    type: str = "block"
    summary: Optional[str] = None
    content_json: dict

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/api/health")
def health():
    return {"status": "ok"}

@app.get("/api/notebook/list")
def list_notebooks(db: Session = Depends(get_db)):
    books = db.query(models.NoteBook).all()
    if not books:
        new_book = models.NoteBook(name="我的第一个笔记本", user_id=1)
        db.add(new_book)
        db.commit()
        db.refresh(new_book)
        return [new_book]
    return books

@app.get("/api/note/list")
def list_notes(book_id: int = None, db: Session = Depends(get_db)):
    # 联调 NoteBlock 获取内容
    notes = db.query(models.Note).filter(models.Note.book_id == book_id).all()
    result = []
    for n in notes:
        # 获取第一层内容作为预览/回显
        block = db.query(models.NoteBlock).filter(models.NoteBlock.note_id == n.note_id).first()
        result.append({
            "note_id": n.note_id,
            "title": n.title,
            "type": n.type,
            "summary": n.summary,
            "content": block.content if block else "",
            "updated_at": n.updated_at
        })
    return result

@app.post("/api/note/save/{note_id}")
async def save_note(note_id: int, data: NoteSaveRequest, db: Session = Depends(get_db)):
    logger.info(f"SAVE START - ID: {note_id}")
    try:
        content_text = data.content_json.get("content", "")
        
        if note_id == 0:
            note = models.Note(book_id=1, title=data.title, type=data.type, summary=data.summary)
            db.add(note)
            db.commit()
            db.refresh(note)
            note_id = note.note_id
        else:
            note = db.query(models.Note).filter(models.Note.note_id == note_id).first()
            if not note:
                note = models.Note(book_id=1, title=data.title, type=data.type, summary=data.summary)
                db.add(note)
                db.commit()
                db.refresh(note)
                note_id = note.note_id
            else:
                note.title = data.title
                note.type = data.type
                note.summary = data.summary
        
        # 写入或更新内容到 NoteBlock
        block = db.query(models.NoteBlock).filter(models.NoteBlock.note_id == note_id).first()
        if not block:
            block = models.NoteBlock(note_id=note_id, type='text', content=content_text, order_num=0)
            db.add(block)
        else:
            block.content = content_text
            
        db.commit()
        logger.info(f"SAVE SUCCESS - Final ID: {note_id}")
        return {"status": "success", "note_id": note_id}
    except Exception as e:
        logger.error(f"SAVE ERROR: {str(e)}")
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
