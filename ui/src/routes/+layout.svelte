<script>
  import './layout.css';
  import favicon from '$lib/assets/favicon.svg';
  import Lightswitch from '$lib/components/Lightswitch.svelte';
  import { AppBar } from '@skeletonlabs/skeleton-svelte';
  import { resolve } from '$app/paths';

  let { children } = $props();
</script>

<svelte:head><link rel="icon" href={favicon} /></svelte:head>

<div class="min-h-screen bg-background-50 text-text-900 transition-colors">
  <AppBar class="shadow-s sticky top-0 z-40 bg-background-100 shadow-secondary-700 backdrop-blur">
    <AppBar.Toolbar class="flex justify-between">
      <AppBar.Lead class="p-4">
        <a href={resolve('/')} class=" text-xl font-bold text-primary-600">Pokemon finder</a>
      </AppBar.Lead>
      <AppBar.Trail class="p-4">
        <Lightswitch />
      </AppBar.Trail>
    </AppBar.Toolbar>
  </AppBar>

  <main class="px-4 py-6">
    {@render children()}
  </main>
</div>
