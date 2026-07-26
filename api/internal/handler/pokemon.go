package handler

import (
	"api/internal/service"
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type PokemonHandler struct {
	Service *service.PokemonService
}

func NewPokemonHandler(svc *service.PokemonService) *PokemonHandler {
	return &PokemonHandler{Service: svc}
}

func (h *PokemonHandler) GetByID(c *gin.Context) {
	// get id from url
	idString := c.Param("id")

	// validate id
	id, err := strconv.Atoi(idString)
	if err != nil {
		// attach error to context
		c.Error(err)

		// return http error
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid Pokemon ID"})
		return
	}

	// query PokeAPI
	pokemon, err := h.Service.GetPokemonByID(c.Request.Context(), id)
	if err != nil {
		// attach error to context
		// todo logging middleware!
		c.Error(err)

		if errors.Is(service.ErrNotFound, err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "pokemon could not be found"})
			return
		}
		
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	// pokemon fields are automatically escaped by the encoder
	c.JSON(http.StatusOK, pokemon)
}
