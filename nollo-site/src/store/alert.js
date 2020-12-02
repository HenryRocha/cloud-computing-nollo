import { writable } from "svelte/store";

export const alert = writable({ success: true, title: "Welcomo to Nollo!", description: "Awesome!" });
