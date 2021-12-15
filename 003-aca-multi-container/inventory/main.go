package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gorilla/mux"
)

func main() {

	r := mux.NewRouter()
	api := NewBuilder().WithRouter(r).Build()

	p, exists := os.LookupEnv("PORT")

	if !exists {
		p = "8080"
	}
	addr := fmt.Sprintf(":%s", p)
	log.Fatalf("%s", api.Run(addr))

}
