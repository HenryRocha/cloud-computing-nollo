<script>
	import { onMount } from "svelte";
	import Tailwindcss from "./Tailwindcss.svelte";
	import NewTodo from "./components/NewTodo.svelte";
	import Todo from "./components/Todo.svelte";
	import Alert from "./components/Alert.svelte";
	import {
		todos,
		fetchTodos,
		isFetchingTodos,
		fetchTodosError,
	} from "./store/todos.js";

	onMount(() => {
		console.log(`Backend URL is: ${API_URL}`);
		fetchTodos();
	});
</script>

<style>
</style>

<main>
	<Tailwindcss />

	<Alert />

	<NewTodo />

	{#if $isFetchingTodos}
		<div class="mt-12 text-center text-gray-600">
			<h2>Loading todos...</h2>
		</div>
	{:else if $fetchTodosError}
		<div class="mt-12 text-center text-gray-600">
			<h2>Error Loading todos...</h2>
		</div>
	{:else}
		<div>
			{#each $todos as todo}
				<Todo
					title={todo.title}
					description={todo.description}
					id={todo.id} />
			{/each}
		</div>
	{/if}
</main>
