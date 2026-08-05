export const fetchPokemonById = async (id) => {
  if (!id || id <= 0) {
    throw new Error('Invalid Pokémon ID');
  }

  const response = await fetch(`/api/v1/pokemon/${id}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    throw new Error(`Error fetching Pokémon with ID ${id}: ${response.statusText}`);
  }

  return await response.json();
};
