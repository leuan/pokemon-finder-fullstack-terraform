package service

import (
	"api/internal/config"
	"api/internal/domain"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"time"
)

const (
	POKEMON_BASE_PATH = "/api/v2/pokemon"
)

// ErrNotFound is returned when the requested Pokemon resource does not exist in PokeAPI
var ErrNotFound = errors.New("PokeAPI returned 404 - not found")

// ErrPokeAPI is returned when PokeAPI returned a status code different than 200 or 404
var ErrPokeAPI = errors.New("PokeAPI returned an invalid status code")

type PokemonService struct {
	Config     config.Config
	httpClient *http.Client
}

func NewPokemonService(cfg config.Config) *PokemonService {
	return &PokemonService{Config: cfg, httpClient: &http.Client{Timeout: time.Duration(cfg.HTTPClientTimeoutSeconds) * time.Second}}
}

func (s *PokemonService) GetPokemonByID(ctx context.Context, id int) (domain.Pokemon, error) {
	// build pokemon api url
	pokemonURL, err := url.JoinPath(s.Config.PokeAPIHost, POKEMON_BASE_PATH, strconv.Itoa(id))
	if err != nil {
		return domain.Pokemon{}, fmt.Errorf("invalid host configuration (host = %s): %w", s.Config.PokeAPIHost, err)
	}

	// create http request
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, pokemonURL, nil)
	if err != nil {
		return domain.Pokemon{}, fmt.Errorf("could not build get pokemon http request for id %d: %w", id, err)
	}

	// call pokemon api
	resp, err := s.httpClient.Do(req)
	if err != nil {
		return domain.Pokemon{}, fmt.Errorf("could not perform get pokemon request for id %d: %w", id, err)
	}
	defer resp.Body.Close()

	// check if not found status code
	if resp.StatusCode == http.StatusNotFound {
		return domain.Pokemon{}, ErrNotFound
	}

	// check if status code is not 200
	if resp.StatusCode != http.StatusOK {
		return domain.Pokemon{}, ErrPokeAPI
	}

	// decode the response body
	var pokemon domain.Pokemon
	if err := json.NewDecoder(resp.Body).Decode(&pokemon); err != nil {
		return domain.Pokemon{}, fmt.Errorf("invalid response from PokeAPI: %w", err)
	}

	return pokemon, nil
}
