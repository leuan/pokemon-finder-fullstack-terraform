package config

type Config struct {
	PokeAPIHost string `mapstructure:"POKEAPI_BASE_URL"`
	HTTPClientTimeoutSeconds int `mapstructure:"HTTP_CLIENT_TIMEOUT_SECONDS"`
}

func Load() (*Config, error) {
	cfg := Config{
		PokeAPIHost: "https://pokeapi.co",
		HTTPClientTimeoutSeconds: 30,
	}

	return &cfg, nil
}