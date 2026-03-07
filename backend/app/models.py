from sqlalchemy import Column, BigInteger, String, DateTime, ForeignKey, Enum, Text, func, Integer
from sqlalchemy.orm import relationship, declarative_base

Base = declarative_base()

class NoteBook(Base):
    __tablename__ = 'note_book'
    book_id = Column(BigInteger, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    user_id = Column(BigInteger, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    notes = relationship("Note", back_populates="book", cascade="all, delete-orphan")

class Note(Base):
    __tablename__ = 'note'
    note_id = Column(BigInteger, primary_key=True, autoincrement=True)
    book_id = Column(BigInteger, ForeignKey('note_book.book_id', ondelete='CASCADE'))
    title = Column(String(255), default='未命名笔记')
    type = Column(Enum('cornell', 'block'), default='block')
    summary = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    book = relationship("NoteBook", back_populates="notes")
    blocks = relationship("NoteBlock", back_populates="note", cascade="all, delete-orphan")

class NoteBlock(Base):
    __tablename__ = 'note_block'
    block_id = Column(BigInteger, primary_key=True, autoincrement=True)
    note_id = Column(BigInteger, ForeignKey('note.note_id', ondelete='CASCADE'))
    parent_block_id = Column(BigInteger, ForeignKey('note_block.block_id', ondelete='CASCADE'), nullable=True)
    type = Column(Enum('text', 'image', 'equation', 'heading-1', 'heading-2', 'todo'), default='text')
    content = Column(Text)
    order_num = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    note = relationship("Note", back_populates="blocks")
