package main

import (
	"api/internal/config"
	"api/internal/handler"
	"api/internal/service"
	"log"
)

func main() {
	log.Println("Starting server...")

	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Error loading server configuration: %v", err)
	}
	pokemonService := service.NewPokemonService(cfg)
	pokemonHandler := handler.NewPokemonHandler(pokemonService)
	router := handler.NewRouter(pokemonHandler)

	if err := router.Run(":8080"); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
