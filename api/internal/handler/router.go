package handler

import (
	"api/internal/log"
	"api/internal/middleware"

	"github.com/gin-gonic/gin"
)

func NewRouter(pokemonHandler *PokemonHandler) *gin.Engine {
	router := gin.New()

	// middleware declaration here
	router.Use(log.LoggerMiddleware())
	router.Use(middleware.RecoveryMiddleware())

	// route declaration here
	v1 := router.Group("/api/v1")
	v1.GET("/pokemon/:id", pokemonHandler.GetByID)

	return router
}
