package config

import (
	"fmt"
	"log/slog"

	"github.com/go-playground/validator/v10"
	"github.com/spf13/viper"
)

type Config struct {
	PokeAPIHost              string `mapstructure:"POKEAPI_BASE_URL" validate:"required,url"`
	HTTPClientTimeoutSeconds int    `mapstructure:"HTTP_CLIENT_TIMEOUT_SECONDS" validate:"required,gt=0"`
	// use uint16 since port validator only works with this type
	ListenPort uint16 `mapstructure:"LISTEN_PORT" validate:"required,port"`
}

func Load() (*Config, error) {
	v := viper.New()

	// set defaults and bind to env
	// setDefault does the bind so there's no need to do it for these
	v.SetDefault("POKEAPI_BASE_URL", DEFAULT_POKEAPI_BASE_URL)
	v.SetDefault("HTTP_CLIENT_TIMEOUT_SECONDS", DEFAULT_HTTP_CLIENT_TIMEOUT_SECONDS)
	v.SetDefault("LISTEN_PORT", DEFAULT_LISTEN_PORT)
	v.BindEnv("LISTEN_PORT")

	v.AutomaticEnv()

	slog.Info("Loading configuration...")

	// read config
	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, fmt.Errorf("failed to unmarshal environment variables: %w", err)
	}

	// validate config
	validate := validator.New(validator.WithRequiredStructEnabled())
	if err := validate.Struct(&cfg); err != nil {
		return nil, fmt.Errorf("config validation failed: %w", err)
	}

	return &cfg, nil
}
