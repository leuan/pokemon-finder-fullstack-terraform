package handler

import (
	"github.com/gin-gonic/gin"
)

func NewRouter(pokemonHandler *PokemonHandler) *gin.Engine {
	router := gin.Default()

	// route declaration here
	v1 := router.Group("/api/v1")
	v1.GET("/pokemon/:id", pokemonHandler.GetByID)

	return router
}
