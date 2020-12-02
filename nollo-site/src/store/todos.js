import { writable } from "svelte/store";

// List of todos.
export const todos = writable([]);

// =======================================================================================
// Fetch Todos
// =======================================================================================
export const isFetchingTodos = writable(false);
export const fetchTodosError = writable(null);

export async function fetchTodos() {
    isFetchingTodos.set(true);

    const res = await fetch(`${API_URL}/api/v1/todos`, {
        method: "GET",
    });

    const json = await res.json();
    if (res.ok) {
        fetchTodosSuccess(json.todos);
    } else {
        fetchTodosFail(json);
    }
}

export const fetchTodosSuccess = (data) => {
    todos.set(data);
    isFetchingTodos.set(false);
    fetchTodosError.set(null);
}

export const fetchTodosFail = (error) => {
    fetchTodosError.set(error);
    isFetchingTodos.set(false);
}

// =======================================================================================
// Create Todo
// =======================================================================================
export const isCreatingTodo = writable(false);
export const createTodoError = writable(null);

export async function createTodo(newTodo) {
    isCreatingTodo.set(true);

    const res = await fetch(`${API_URL}/api/v1/todos`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(newTodo),
    });

    const json = await res.json();
    if (res.ok) {
        createTodoSuccess(json);
    } else {
        createTodoFail(json);
    }
}

export const createTodoSuccess = (newTodo) => {
    todos.update(todos => ([...todos, newTodo]))
    isCreatingTodo.set(false);
    createTodoError.set(null);
}

export const createTodoFail = (error) => {
    createTodoError.set(error);
    isCreatingTodo.set(false);
}

// =======================================================================================
// Delete Todo
// =======================================================================================
export const isDeletingTodo = writable(false);
export const deleteTodoError = writable(null);

export async function deleteTodo(todoID) {
    isDeletingTodo.set(true);

    const res = await fetch(`${API_URL}/api/v1/todos/` + todoID, {
        method: "DELETE",
    });

    const json = await res.json();
    if (res.ok) {
        deleteTodoSuccess(todoID);
    } else {
        deleteTodoFail(json);
    }
}

export const deleteTodoSuccess = (todoID) => {
    todos.update(todos => todos.filter(todos => todos.id !== todoID));
    isCreatingTodo.set(false);
    createTodoError.set(null);
}

export const deleteTodoFail = (error) => {
    createTodoError.set(error);
    isCreatingTodo.set(false);
}
