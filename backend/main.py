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

class NotebookCreate(BaseModel):
    name: str

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

@app.post("/api/notebook/create")
async def create_notebook(data: NotebookCreate, db: Session = Depends(get_db)):
    try:
        new_book = models.NoteBook(name=data.name, user_id=1)
        db.add(new_book)
        db.commit()
        db.refresh(new_book)
        return new_book
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/api/notebook/{book_id}")
async def update_notebook(book_id: int, data: NotebookCreate, db: Session = Depends(get_db)):
    try:
        book = db.query(models.NoteBook).filter(models.NoteBook.book_id == book_id).first()
        if not book:
            raise HTTPException(status_code=404, detail="Notebook not found")
        book.name = data.name
        db.commit()
        return book
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/notebook/{book_id}")
async def delete_notebook(book_id: int, db: Session = Depends(get_db)):
    try:
        book = db.query(models.NoteBook).filter(models.NoteBook.book_id == book_id).first()
        if not book:
            raise HTTPException(status_code=404, detail="Notebook not found")
        # 统计是否还有笔记，防止误删
        note_count = db.query(models.Note).filter(models.Note.book_id == book_id).count()
        if note_count > 0:
            raise HTTPException(status_code=400, detail=f"该笔记本下还有 {note_count} 篇笔记，请先删除笔记")
        db.delete(book)
        db.commit()
        return {"status": "success"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/note/list")
def list_notes(book_id: int = None, db: Session = Depends(get_db)):
    query = db.query(models.Note)
    if book_id:
        query = query.filter(models.Note.book_id == book_id)
    notes = query.all()
    result = []
    for n in notes:
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
async def save_note(note_id: int, data: NoteSaveRequest, db: Session = Depends(get_db), book_id: int = 1):
    # 此处 book_id 逻辑由前端通过 query 参数或 body 传入更佳，暂时默认为当前笔记本
    try:
        content_text = data.content_json.get("content", "")
        if note_id == 0:
            note = models.Note(book_id=book_id, title=data.title, type=data.type, summary=data.summary)
            db.add(note)
            db.commit()
            db.refresh(note)
            note_id = note.note_id
        else:
            note = db.query(models.Note).filter(models.Note.note_id == note_id).first()
            if note:
                note.title = data.title
                note.type = data.type
                note.summary = data.summary
        
        block = db.query(models.NoteBlock).filter(models.NoteBlock.note_id == note_id).first()
        if not block:
            block = models.NoteBlock(note_id=note_id, type='text', content=content_text, order_num=0)
            db.add(block)
        else:
            block.content = content_text
        db.commit()
        return {"status": "success", "note_id": note_id}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/note/{note_id}")
async def delete_note(note_id: int, db: Session = Depends(get_db)):
    try:
        note = db.query(models.Note).filter(models.Note.note_id == note_id).first()
        if note:
            db.delete(note)
            db.commit()
        return {"status": "success"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
