<script>
  import PokemonForm from '$lib/components/PokemonForm.svelte';
  import { fetchPokemonById } from '$lib/api';
  import PokemonCard from '$lib/components/PokemonCard.svelte';
  import { toaster } from '$lib/toaster';

  let loading = $state(false);
  let showCard = $state(false);
  let pokemon = $state({});
  let apiError = $state(null);

  const handleSubmit = async (formData) => {
    apiError = null;
    console.log('Submit clicked: looking up Pokemon...');
    loading = true;
    showCard = true;

    try {
      pokemon = await fetchPokemonById(formData.id);
      console.log('Fetched Pokemon:', pokemon);
      loading = false;
    } catch (error) {
      apiError = error;
      return;
    }
  };

  function handleClear() {
    console.log('Clear clicked');
    showCard = false;
    pokemon = {};
    loading = false;
    apiError = null;
    toaster.info({title: 'Form cleared', description: "You can start over now."});
  }
</script>

<div class="flex flex-wrap space-y-4 space-x-6">
  <PokemonForm onSubmit={handleSubmit} onClear={handleClear} />
  {#if showCard}
    <PokemonCard pokemonData={pokemon} {loading} isNotFound={apiError?.isNotFound} />
  {/if}
</div>
