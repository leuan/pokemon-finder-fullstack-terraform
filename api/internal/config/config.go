package config

type Config struct {
	PokeAPIHost string `mapstructure:"POKEAPI_BASE_URL"`
}

func Load() (*Config, error) {
	cfg := Config{
		PokeAPIHost: "https://pokeapi.co",
	}

	return &cfg, nil
}