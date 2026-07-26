package domain

type Pokemon struct {
	ID int `json:"id"`
	Name string `json:"name"`
	BaseExperience int `json:"base_experience"`
	Height int `json:"height"`
	Weight int `json:"weight"`
  Stats []PokemonStat `json:"stats"`
}

type PokemonStat struct {
	Name string `json:"name"`
	Base int `json:"base"`
	Effort int `json:"effort"`
}