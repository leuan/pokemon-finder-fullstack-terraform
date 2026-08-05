package domain

type Pokemon struct {
	ID             int            `json:"id"`
	Name           string         `json:"name"`
	BaseExperience int            `json:"base_experience"`
	Height         int            `json:"height"`
	Weight         int            `json:"weight"`
	Stats          []PokemonStat  `json:"stats"`
	Sprites        PokemonSprites `json:"sprites"`
}

type PokemonStat struct {
	Base   int `json:"base_stat"`
	Effort int `json:"effort"`
	Stat   PokemonStatAPIResource `json:"stat"`
}

type PokemonStatAPIResource struct {
	Name string `json:"name"`
	URL  string `json:"url"`
}

type PokemonSprites struct {
	FrontDefault string `json:"front_default"`
	FrontShiny   string `json:"front_shiny"`
}
