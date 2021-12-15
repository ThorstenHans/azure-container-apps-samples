package main

import (
	"fmt"
	"log"
	"os"

	dapr "github.com/dapr/go-sdk/client"
)

func main() {
	log.SetOutput(os.Stdout)
	c, err := dapr.NewClient()
	if err != nil {
		log.Fatalf("Error while creating dapr client: %s", err)
	}
	defer c.Close()
	api := NewApi(c)
	p, ok := os.LookupEnv("PORT")
	if !ok {
		p = "8080"
	}
	addr := fmt.Sprintf(":%s", p)
	log.Printf("Starting order service at %s...", addr)
	api.Run(addr)

}
