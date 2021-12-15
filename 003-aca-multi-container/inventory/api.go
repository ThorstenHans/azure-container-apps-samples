package main

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
)

type Api struct {
	Router *mux.Router
}

type ItemsResponse struct {
	Id        string `json:"id"`
	IsInStock bool   `json:"inStock"`
}

func (a *Api) handleHello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello"))
}

func (a *Api) handleItems(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	if len(id) == 0 {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	res := ItemsResponse{
		Id:        id,
		IsInStock: true,
	}
	json.NewEncoder(w).Encode(res)
}
func (a *Api) Run(addr string) error {

	a.Router.HandleFunc("/", a.handleHello).Methods(http.MethodGet)
	a.Router.HandleFunc("/items/{id}", a.handleItems).Methods(http.MethodGet)

	return http.ListenAndServe(addr, a.Router)
}

type ApiBuilder struct {
	r *mux.Router
}

func NewBuilder() *ApiBuilder {
	return &ApiBuilder{}
}

func (ab *ApiBuilder) WithRouter(r *mux.Router) *ApiBuilder {
	ab.r = r
	return ab
}

func (ab *ApiBuilder) Build() *Api {
	return &Api{
		Router: ab.r,
	}
}
