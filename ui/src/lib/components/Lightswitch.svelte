<script>
  import { onMount } from 'svelte';
  import SunIcon from '@lucide/svelte/icons/sun';
  import MoonIcon from '@lucide/svelte/icons/moon';

  let isDark = $state(false);

  onMount(() => {
    isDark = document.documentElement.classList.contains('dark');
  });

  function toggleTheme() {
    isDark = !isDark;
    document.documentElement.classList.toggle('dark', isDark);
    localStorage.setItem('theme', isDark ? 'dark' : 'light');
  }
</script>

<button
  type="button"
  class="btn-icon rounded-full text-primary-700-300 hover:preset-tonal-primary"
  aria-label={isDark ? 'Switch to light mode' : 'Switch to dark mode'}
  onclick={toggleTheme}
>
  {#if isDark}
    <SunIcon class="size-5" />
  {:else}
    <MoonIcon class="size-5" />
  {/if}
</button>
