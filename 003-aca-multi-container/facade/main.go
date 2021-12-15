package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

func handleHello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello"))
}

func main() {
	log.SetOutput(os.Stdout)
	api := New()
	r := mux.NewRouter()

	r.Use(setContentTypeMiddleware)

	r.HandleFunc("/hello", handleHello).Methods(http.MethodGet)
	r.HandleFunc("/orders", api.HandleCreateOrder).Methods(http.MethodPost)
	r.HandleFunc("/orders/{id}", api.HandleGetOrder).Methods(http.MethodGet)
	r.HandleFunc("/inventory/{id}", api.HandleGetInventory).Methods(http.MethodGet)

	p, ok := os.LookupEnv("PORT")
	if !ok {
		p = "8080"
	}
	addr := fmt.Sprintf(":%s", p)
	log.Printf("Starting Facade at %s...", addr)
	http.ListenAndServe(addr, r)

}

func setContentTypeMiddleware(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		h.ServeHTTP(w, r)
	})
}
