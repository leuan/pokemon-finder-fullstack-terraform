<script>
  import PokemonForm from '$lib/components/PokemonForm.svelte';

  async function handleSubmit(formData) {
    console.log('Submit!');
    console.log(`Form data: ${JSON.stringify(formData)}`);
  }

  function handleClear() {
    console.log("Clear!");
    // errorMessage = '';
  }
</script>

<PokemonForm onSubmit={handleSubmit} onClear={handleClear}/>
