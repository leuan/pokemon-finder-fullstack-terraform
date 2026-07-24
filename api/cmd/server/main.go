package main

import (
	"api/internal/handler"
	"log"
)

func main() {
	log.Println("Starting server...")

	router := handler.NewRouter()

	if err := router.Run(":8080"); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
