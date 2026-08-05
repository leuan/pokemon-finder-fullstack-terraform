<script>
  let { pokemonData = {}, isNotFound = false, loading = false } = $props();
</script>

<div class="shadow-text-700-300 min-w-1/4 space-y-4 card bg-surface-100-900 p-4 shadow-md">
  {#if isNotFound}
    <p>Sorry, your Pokemon could not be found. :(</p>
  {:else}
    {#if loading}
      <div class="w-full space-y-4">
        <div class="animate-pulse space-y-4 [animation-duration:2s]">
          <div class="h-18 placeholder w-full"></div>
          <div class="size-90 placeholder"></div>
          <div class="placeholder"></div>
          <div class="grid grid-cols-4 gap-4">
            <div class="placeholder"></div>
            <div class="placeholder"></div>
            <div class="placeholder"></div>
            <div class="placeholder"></div>
          </div>
          <div class="placeholder"></div>
        </div>
      </div>
    {:else}
      <div class="w-full space-y-4">
        <div>
          <p class="text-5xl font-bold capitalize">{pokemonData.name}</p>
          <p class="font-bold text-secondary-300-700 italic">ID: {pokemonData.id}</p>
        </div>
        <div class="card bg-surface-50-950 p-2">
          <img
            src={pokemonData.sprites.front_default}
            alt={pokemonData.name}
            class="h-auto w-full"
          />
        </div>
        <fieldset class="fieldset flex flex-wrap space-x-4">
          <legend class="legend font-bold text-secondary-300-700">Basic Information</legend>
          <p><span class="pr-1 font-bold">Height:</span>{pokemonData.height}</p>
          <p><span class="pr-1 font-bold">Weight:</span>{pokemonData.weight}</p>
          <p><span class="pr-1 font-bold">Base Experience:</span>{pokemonData.base_experience}</p>
        </fieldset>
        <fieldset class="fieldset grid grid-cols-2 space-x-4">
          <legend class="legend font-bold text-secondary-300-700">Stats</legend>
          {#each pokemonData.stats as stat (stat.stat.name)}
            <p>
              <span class="pr-1 font-bold capitalize"
                >{stat.stat.name === 'hp' ? 'HP' : stat.stat.name}:</span
              >{stat.base_stat}
            </p>
          {/each}
        </fieldset>
      </div>
    {/if}
  {/if}
</div>
