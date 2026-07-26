package service

import (
	"api/internal/domain"
)

type PokemonService struct {
}

func NewPokemonService() *PokemonService {
	return &PokemonService{}
}

func (s *PokemonService) GetPokemonByID(id int) domain.Pokemon {
	
}
