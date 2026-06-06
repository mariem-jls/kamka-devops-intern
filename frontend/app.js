const API = "http://localhost:8000";

async function loadTodos() {
    const res = await fetch(`${API}/todos`);
    const todos = await res.json();
    const list = document.getElementById("todoList");
    list.innerHTML = "";
    todos.forEach(todo => {
        const li = document.createElement("li");
        li.className = todo.done ? "done" : "";
        li.innerHTML = `
            <span onclick="toggleTodo(${todo.id}, ${!todo.done}, '${todo.title}')" style="cursor:pointer">
                ${todo.done ? "✅" : "⬜"} ${todo.title}
            </span>
            <button class="delete-btn" onclick="deleteTodo(${todo.id})">Delete</button>
        `;
        list.appendChild(li);
    });
}

async function addTodo() {
    const input = document.getElementById("todoInput");
    if (!input.value.trim()) return;
    await fetch(`${API}/todos`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: input.value, done: false })
    });
    input.value = "";
    loadTodos();
}

async function toggleTodo(id, done, title) {
    await fetch(`${API}/todos/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title, done })
    });
    loadTodos();
}

async function deleteTodo(id) {
    await fetch(`${API}/todos/${id}`, { method: "DELETE" });
    loadTodos();
}

loadTodos();