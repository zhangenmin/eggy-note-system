from fastapi import FastAPI, Depends, HTTPException, status
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

# --- 登录相关模型 ---
class LoginRequest(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    user_id: int
    username: str
    role: str

class NotebookCreate(BaseModel):
    name: str

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

# --- 登录接口 ---
@app.post("/api/login")
async def login(data: LoginRequest, db: Session = Depends(get_db)):
    # 兼容 study-tracker 的用户表逻辑
    # 检查是否存在用户表，不存在则尝试从 study_tracker 库或本地创建
    try:
        # 简单校验：直接从 study_tracker 库的 users 表校验 (假设在同一个 MySQL 实例)
        # 或者在 eggy_note 创建一个简单的映射
        user = db.execute(text("SELECT id, username, password, role FROM study_tracker.users WHERE username = :u AND password = :p"), 
                          {"u": data.username, "p": data.password}).first()
        
        if not user:
            # 备选：内置一个 admin 账号用于首次登录
            if data.username == "parent" and data.password == "Jschrj83130911!":
                return {"user_id": 1, "username": "parent", "role": "admin", "status": "success"}
            raise HTTPException(status_code=401, detail="用户名或密码错误")
            
        return {
            "user_id": user[0],
            "username": user[1],
            "role": user[3],
            "status": "success"
        }
    except Exception as e:
        logger.error(f"Login Error: {str(e)}")
        # 兜底逻辑：如果跨库查询失败，仅支持内置账号
        if data.username == "parent" and data.password == "Jschrj83130911!":
            return {"user_id": 1, "username": "parent", "role": "admin", "status": "success"}
        raise HTTPException(status_code=401, detail="认证服务暂时不可用")

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
        if not book: raise HTTPException(status_code=404)
        book.name = data.name
        db.commit()
        return book
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500)

@app.delete("/api/notebook/{book_id}")
async def delete_notebook(book_id: int, db: Session = Depends(get_db)):
    try:
        book = db.query(models.NoteBook).filter(models.NoteBook.book_id == book_id).first()
        if not book: raise HTTPException(status_code=404)
        db.delete(book)
        db.commit()
        return {"status": "success"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500)

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
