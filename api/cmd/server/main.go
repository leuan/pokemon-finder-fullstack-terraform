package main

import (
	"api/internal/config"
	"api/internal/handler"
	"api/internal/log"
	"api/internal/service"
	"fmt"
	"io"
	"log/slog"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	// silence default error writer
	gin.DefaultErrorWriter = io.Discard
	
	// set release mode
	gin.SetMode(gin.ReleaseMode)
	
	// initialize logger
	log.InitLogger()

	// load configuration
	cfg, err := config.Load()
	if err != nil {
		slog.Error("Failed to load server configuration", "error", err)
		os.Exit(1)
	}

	slog.Info("Configuration loaded.")

	// initialize components
	pokemonService := service.NewPokemonService(cfg)
	pokemonHandler := handler.NewPokemonHandler(pokemonService)
	router := handler.NewRouter(pokemonHandler)

	slog.Info(fmt.Sprintf("Starting server on port %d", cfg.ListenPort))

	// start webserver
	if err := router.Run(fmt.Sprintf(":%d", cfg.ListenPort)); err != nil {
		slog.Error("Failed to start web server", "error", err)
		os.Exit(1)
	}
}
