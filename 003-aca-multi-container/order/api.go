package main

import (
	"context"
	"encoding/json"
	"io"
	"log"
	"net/http"

	dapr "github.com/dapr/go-sdk/client"
	"github.com/gorilla/mux"
)

type OrderCreated struct {
	Id string `json:"id"`
}

type Api struct {
	Dapr    dapr.Client
	Router  *mux.Router
	Context context.Context
}

func (a *Api) GetOrderById(w http.ResponseWriter, r *http.Request) {
	v := mux.Vars(r)
	id := v["id"]

	item, err := a.Dapr.GetState(a.Context, "orders", id)
	if err != nil {
		log.Printf("Error while reading order from state store: %s", err)
		http.Error(w, "Internal Server Error", 500)
		return
	}

	if item.Value == nil {
		log.Printf("Order with Id :%s not found in state store", id)
		http.NotFound(w, r)
		return
	}

	w.Write(item.Value)
}

func (a *Api) CreateOrder(w http.ResponseWriter, r *http.Request) {
	v := mux.Vars(r)
	id := v["id"]

	body, err := io.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error while reading request body: %s", err)
		http.Error(w, "Internal Server Error", 500)
		return
	}
	if err := a.Dapr.SaveState(a.Context, "orders", id, body); err != nil {
		log.Printf("Error while saving State via Dapr: %s", err)
		http.Error(w, "Internal Server Error", 500)
		return
	}
	w.WriteHeader(http.StatusCreated)
	w.Header().Set("Content-Type", "application/json")
	o := OrderCreated{
		Id: id,
	}
	json.NewEncoder(w).Encode(o)
}

func (a *Api) Run(addr string) {
	log.Fatal(http.ListenAndServe(addr, a.Router))
}

func NewApi(c dapr.Client) *Api {
	api := &Api{
		Dapr:    c,
		Router:  mux.NewRouter(),
		Context: context.Background(),
	}

	api.Router.HandleFunc("/orders/{id}", api.GetOrderById).Methods(http.MethodGet)
	api.Router.HandleFunc("/orders/{id}", api.CreateOrder).Methods(http.MethodPost)

	return api
}
