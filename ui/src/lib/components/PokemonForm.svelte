<script>
  let { formData = $bindable({ id: null }), onSubmit = () => {}, onClear = () => {} } = $props();

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const handleClear = () => {
    formData = { id: null };
    onClear();
  };
</script>

<div id="form-container">
  <form
    onsubmit={handleSubmit}
    class="shadow-text-700-300 max-w-md space-y-4 card bg-surface-100-900 p-4 shadow-md"
  >
    <header>
      <h3 class="h3">Look up a Pokemon</h3>
    </header>
    <fieldset class="fieldset space-y-2">
      <label class="label">
        <span class="label-text">Pokemon ID</span>
        <input
          class="input bg-surface-50-950"
          type="number"
          bind:value={formData.id}
          placeholder="e.g. 42"
        />
      </label>
    </fieldset>
    <footer class="flex justify-between">
      <button type="button" onclick={handleClear} class="btn bg-error-400-600 text-error-900-100">Clear</button>
      <button type="submit" class="btn bg-primary-300-700">Submit</button>
    </footer>
  </form>
</div>
