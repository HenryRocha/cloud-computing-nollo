<script>
    import {
        createTodo as dispatchFetchTodos,
        isCreatingTodo,
        createTodoError,
    } from "./../store/todos.js";
    import { alert } from "./../store/alert.js";

    let newTodo = {};

    async function createTodo() {
        await dispatchFetchTodos(newTodo);

        if ($createTodoError) {
            $alert = {
                success: false,
                title: `Could not create ToDo`,
                description: $createTodoError.error,
            };
        } else {
            $alert = {
                success: true,
                title: `ToDo '${newTodo.title}' created.`,
                description: "",
            };
        }
        newTodo = {};
    }
</script>

<style>
</style>

<main>
    <div class="pl-6 pr-6 mt-6">
        <div
            class="bg-white sm:mx-auto sm:max-w-lg md:mx-auto md:max-w-xl rounded-lg border overflow-hidden shadow-lg">
            <div class="p-4 text-center">
                <div class="font-bold text-4xl">Nollo</div>
            </div>
            <div class="p-4 mb-2">
                <label class="font-bold text-xl" for="title">Title</label>
                <input
                    class="mt-2 mb-3 shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
                    type="text"
                    id="title"
                    placeholder="Title"
                    bind:value={newTodo.title} />

                <label
                    class="font-bold text-xl"
                    for="description">Description</label>
                <input
                    class="mt-2 shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
                    type="text"
                    id="description"
                    placeholder="Description"
                    bind:value={newTodo.description} />

                <button
                    class="w-full p-2 mt-4 text-lg bg-gradient-to-r from-purple-500 to-indigo-600 rounded-xl text-white"
                    on:click={() => createTodo()}>
                    Create
                </button>

                {#if $isCreatingTodo}
                    <div class="mt-5 text-center text-gray-600">
                        <h2>Creating ToDo...</h2>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</main>
