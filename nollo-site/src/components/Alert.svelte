<!-- components/Alert.svelte -->
<script>
    import { onDestroy } from "svelte";
    import { alert } from "./../store/alert.js";
    import { elasticOut } from "svelte/easing";

    export let ms = 3000;
    let visible;
    let timeout;

    const onMessageChange = (message, ms) => {
        clearTimeout(timeout);
        if (!message) {
            // hide Alert if message is empty
            visible = false;
        } else {
            visible = true; // show alert
            if (ms > 0) timeout = setTimeout(() => (visible = false), ms); // and hide it after ms milliseconds
        }
    };
    $: onMessageChange($alert, ms); // whenever the alert store or the ms props changes run onMessageChange

    function spin(node, { duration }) {
        return {
            duration,
            css: (t) => {
                const eased = elasticOut(t);

                return `
					transform: scale(${eased}) rotate(${eased * 1080}deg);
					color: hsl(
						${~~(t * 360)},
						${Math.min(100, 1000 - 1000 * t)}%,
						${Math.min(50, 500 - 500 * t)}%
					);`;
            },
        };
    }

    onDestroy(() => clearTimeout(timeout)); // make sure we clean-up the timeout
</script>

<style>
</style>

{#if visible}
    <div
        class="absolute mr-3 right-0 w-3/12"
        role="alert"
        on:click={() => (visible = false)}
        out:spin={{ duration: 1000 }}>
        <div class="bg-white rounded-lg border-gray-300 border p-3 shadow-lg">
            <div class="flex flex-row align-middle">
                <div class="px-2">
                    {#if $alert.success}
                        <svg
                            width="32"
                            height="32"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    {:else}
                        <svg
                            width="32"
                            height="32"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    {/if}
                </div>
                <div class="ml-2 mr-6">
                    <span class="font-semibold">{$alert.title}</span>
                    <span
                        class="block text-gray-500">{$alert.description}</span>
                </div>
            </div>
        </div>
    </div>
{/if}
