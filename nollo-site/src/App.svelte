<script>
	import Tailwindcss from "./Tailwindcss.svelte";

	let todos = getTodos();
	let newTodo = {};
	console.log(`Backend URL is: ${API_URL}`)

	async function getTodos() {
		const res = await fetch(`${API_URL}/api/v1/todos`, {
			method: "GET",
		});

		const json = await res.json();
		console.log(json.todos);
		if (res.ok) {
			return json.todos;
		} else {
			throw new Error(json);
		}
	}

	async function createTodo() {
		const res = await fetch(`${API_URL}/api/v1/todos`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify(newTodo),
		});

		const json = await res.json();
		console.log(json);

		todos = getTodos();
		newTodo = {};
	}

	async function deleteTodo(id) {
		const res = await fetch(`${API_URL}/api/v1/todos/` + id, {
			method: "DELETE",
		});

		todos = getTodos();
		newTodo = {};
	}
</script>

<style>
</style>

<Tailwindcss />
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
					on:click={createTodo}>
					Create
				</button>
			</div>
		</div>
	</div>

	{#await todos}
		<div class="mt-12 text-center text-gray-600">
			<h2>Loading todos...</h2>
		</div>
	{:then todos}
		{#each todos as todo}
			<div class="pl-6 pr-6 mt-3">
				<div
					class="bg-white sm:mx-auto sm:max-w-lg md:mx-auto md:max-w-xl rounded-lg border overflow-hidden shadow-lg">
					<div class="p-4">
						<div class="font-bold text-xl mb-2">{todo.title}</div>
						<p class="text-gray-700 text-base">
							{todo.description}
						</p>
					</div>

					<div class="mr-2 pb-2 flex justify-end">
						<button class="inline-block">
							<svg
								class="w-8 h-8"
								data-darkreader-inline-fill=""
								fill="currentColor"
								style="--darkreader-inline-fill:currentColor;"
								viewBox="0 0 20 20"
								xmlns="http://www.w3.org/2000/svg">
								<path
									d="M17.414 2.586a2 2 0 00-2.828 0L7 10.172V13h2.828l7.586-7.586a2 2 0 000-2.828z" />
								<path
									fill-rule="evenodd"
									d="M2 6a2 2 0 012-2h4a1 1 0 010 2H4v10h10v-4a1 1 0 112 0v4a2 2 0 01-2 2H4a2 2 0 01-2-2V6z"
									clip-rule="evenodd" />
							</svg>
						</button>

						<button
							class="inline-block"
							on:click={() => deleteTodo(todo.id)}>
							<svg
								class="w-8 h-8"
								data-darkreader-inline-fill=""
								data-darkreader-inline-stroke=""
								fill="none"
								stroke="currentColor"
								style="--darkreader-inline-fill:none; --darkreader-inline-stroke:currentColor;"
								viewBox="0 0 24 24"
								xmlns="http://www.w3.org/2000/svg">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
							</svg>
						</button>
					</div>
				</div>
			</div>
		{/each}
	{:catch error}
		<div class="mt-12 text-center text-gray-600">
			<h2>Could not fetch all todos...</h2>
		</div>
	{/await}
</main>
