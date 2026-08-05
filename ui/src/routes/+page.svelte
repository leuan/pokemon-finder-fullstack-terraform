<script>
  import PokemonForm from '$lib/components/PokemonForm.svelte';
  import { fetchPokemonById } from '$lib/api';

  const handleSubmit = async (formData) => {
    console.log('Submit!');

    try {
      const pokemon = await fetchPokemonById(formData.id);
      console.log('Fetched Pokemon:', pokemon);
    } catch (error) {
      console.error('Error fetching Pokemon:', error);
      return;
    }
  };

  function handleClear() {
    console.log('Clear!');
    // errorMessage = '';
  }
</script>

<PokemonForm onSubmit={handleSubmit} onClear={handleClear} />
