package service

import (
	"api/internal/domain"
)

type PokemonService struct{}

func NewPokemonService() *PokemonService {
	return &PokemonService{}
}

func getPokemonByID(id int) domain.Pokemon {
	return domain.Pokemon{}
}
