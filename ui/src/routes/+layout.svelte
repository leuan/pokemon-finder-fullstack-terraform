<script>
  import './layout.css';
  import favicon from '$lib/assets/favicon.svg';
  import Lightswitch from '$lib/components/Lightswitch.svelte';
  import { AppBar } from '@skeletonlabs/skeleton-svelte';
  import { resolve } from '$app/paths';

  import { toaster } from '$lib/toaster.js';
  import { Toast } from '@skeletonlabs/skeleton-svelte';

  let { children } = $props();
</script>

<svelte:head><link rel="icon" href={favicon} /></svelte:head>

<div class="min-h-screen bg-surface-50-950 text-primary-800-200 transition-colors">
  <AppBar class="shadow-text-700-300 sticky top-0 z-40 bg-surface-100-900 shadow-md backdrop-blur border-b-2 border-primary-200-800">
    <AppBar.Toolbar class="flex justify-between">
      <AppBar.Lead class="px-4">
        <a href={resolve('/')} class=" text-xl font-bold text-primary-500">Pokemon Finder</a>
      </AppBar.Lead>
      <AppBar.Trail class="px-4">
        <Lightswitch />
      </AppBar.Trail>
    </AppBar.Toolbar>
  </AppBar>

  <main class="px-4 py-6">
    {@render children()}
  </main>
</div>
<Toast.Group {toaster}>
  {#snippet children(toast)}
    <Toast {toast}>
      <Toast.Message>
        <Toast.Title>{toast.title}</Toast.Title>
        <Toast.Description>{toast.description}</Toast.Description>
      </Toast.Message>
      <Toast.CloseTrigger />
    </Toast>
  {/snippet}
</Toast.Group>
