package main

import (
	"api/internal/config"
	"api/internal/handler"
	"api/internal/log"
	"api/internal/service"
	"log/slog"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	// set release mode
	gin.SetMode(gin.ReleaseMode)
	
	// initialize logger
	log.InitLogger()

	slog.Info("Starting server...")

	// load configuration
	cfg, err := config.Load()
	if err != nil {
		slog.Error("Failed to load server configuration", "error", err)
		os.Exit(1)
	}

	// initialize components
	pokemonService := service.NewPokemonService(cfg)
	pokemonHandler := handler.NewPokemonHandler(pokemonService)
	router := handler.NewRouter(pokemonHandler)

	// start webserver
	if err := router.Run(":8080"); err != nil {
		slog.Error("Failed to start web server", "error", err)
		os.Exit(1)
	}
}
