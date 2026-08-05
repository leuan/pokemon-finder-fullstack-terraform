<script>
  import { toaster } from '$lib/toaster';

  let { formData = $bindable({ id: null }), onSubmit = () => {}, onClear = () => {} } = $props();

  const handleSubmit = (e) => {
    e.preventDefault();

    // validate the form
    const check = validateFormData(formData);
    if (!check) {
      return;
    }

    onSubmit(formData);
  };

  const handleClear = () => {
    formData = { id: null };
    onClear();
  };

  const validateFormData = () => {
    const idNumber = Number(formData.id);

    if (!Number.isFinite(idNumber)) {
      toaster.error({
        title: 'Invalid ID',
        description: 'Please enter a valid number for the Pokemon ID.'
      });
      console.error('ID is not a valid number:', formData.id);
      return false;
    }
    if (idNumber <= 0) {
      toaster.error({
        title: 'Invalid ID',
        description: 'Please enter a number greater than 0 for the Pokemon ID.'
      });
      console.error('ID is not greater than 0:', formData.id);
      return false;
    }

    console.log('Form data is valid:', formData);
    return true;
  };
</script>

<div class="form-container min-w-1/4">
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
      <button type="button" onclick={handleClear} class="btn bg-error-400-600 text-error-900-100"
        >Clear</button
      >
      <button type="submit" class="btn bg-primary-300-700">Search</button>
    </footer>
  </form>
</div>
