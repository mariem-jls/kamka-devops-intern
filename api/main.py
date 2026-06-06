from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import psycopg2
import os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "db"),
        database=os.getenv("POSTGRES_DB", "todos"),
        user=os.getenv("POSTGRES_USER", "postgres"),
        password=os.getenv("POSTGRES_PASSWORD", "password")
    )

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS todos (
            id SERIAL PRIMARY KEY,
            title TEXT NOT NULL,
            done BOOLEAN DEFAULT FALSE
        )
    """)
    conn.commit()
    cur.close()
    conn.close()

@app.on_event("startup")
def startup():
    init_db()

@app.get("/health")
def health():
    return {"status": "ok"}

class Todo(BaseModel):
    title: str
    done: bool = False

@app.get("/todos")
def get_todos():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, title, done FROM todos")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [{"id": r[0], "title": r[1], "done": r[2]} for r in rows]

@app.post("/todos")
def create_todo(todo: Todo):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("INSERT INTO todos (title, done) VALUES (%s, %s) RETURNING id", (todo.title, todo.done))
    id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return {"id": id, "title": todo.title, "done": todo.done}

@app.put("/todos/{id}")
def update_todo(id: int, todo: Todo):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("UPDATE todos SET title=%s, done=%s WHERE id=%s", (todo.title, todo.done, id))
    conn.commit()
    cur.close()
    conn.close()
    return {"id": id, "title": todo.title, "done": todo.done}

@app.delete("/todos/{id}")
def delete_todo(id: int):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM todos WHERE id=%s", (id,))
    conn.commit()
    cur.close()
    conn.close()
    return {"message": "deleted"}