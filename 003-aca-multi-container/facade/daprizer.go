package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

type Daprizer struct {
	InventoryServiceName string
	DaprSidecarRootUrl   string
	OrderServiceName     string
}

func New() *Daprizer {

	isn, ok := os.LookupEnv("INVENTORY_SERVICE_NAME")
	if !ok {
		log.Fatalf("INVENTORY_SERVICE_NAME not set. Sorry")
	}

	osn, ok := os.LookupEnv("ORDER_SERVICE_NAME")
	if !ok {
		log.Fatalf("ORDER_SERVICE_NAME not set. Sorry")
	}

	port, ok := os.LookupEnv("DAPR_HTTP_PORT")
	if !ok {
		log.Fatalf("DAPR_HTTP_PORT not set. Sorry")
	}

	return &Daprizer{
		InventoryServiceName: isn,
		OrderServiceName:     osn,
		DaprSidecarRootUrl:   fmt.Sprintf("http://localhost:%s", port),
	}
}

func (d *Daprizer) getIdFromRoute(r *http.Request) string {
	vars := mux.Vars(r)
	return vars["id"]
}

func (d *Daprizer) HandleGetOrder(w http.ResponseWriter, r *http.Request) {
	id := d.getIdFromRoute(r)
	if len(id) == 0 {
		http.NotFound(w, r)
		return
	}

	c := &http.Client{}
	req, _ := http.NewRequest(http.MethodGet, fmt.Sprintf("%s/orders/%s", d.DaprSidecarRootUrl, id), nil)
	req.Header.Set("dapr-app-id", d.OrderServiceName)
	res, err := c.Do(req)

	if err != nil {
		log.Printf("Error while sending downstream request: %s", err)
		http.Error(w, "Internal Server Error", 500)
		return
	}
	if res.StatusCode > 299 {
		log.Printf("Received Status Code %d with message %s from order service", res.StatusCode, res.Status)
		w.WriteHeader(res.StatusCode)
		return
	}
	written, err := io.Copy(w, res.Body)
	if err != nil {
		log.Printf("Error while piping response body: %s", err)
	}
	log.Printf("Successfully written %s bytes to response body", written)

	defer res.Body.Close()

}

func (d *Daprizer) HandleCreateOrder(w http.ResponseWriter, r *http.Request) {

	id := uuid.New()

	c := &http.Client{}
	req, _ := http.NewRequest(http.MethodPost, fmt.Sprintf("%s/orders/%s", d.DaprSidecarRootUrl, id), r.Body)
	req.Header.Set("dapr-app-id", d.OrderServiceName)
	res, err := c.Do(req)

	if err != nil {
		log.Printf("Error while sending downstream request: %s", err)
		http.Error(w, "Internal Server Error", 500)
		return
	}
	defer res.Body.Close()
	w.WriteHeader(res.StatusCode)
	io.Copy(w, res.Body)
}

func (d *Daprizer) HandleGetInventory(w http.ResponseWriter, r *http.Request) {
	id := d.getIdFromRoute(r)
	if len(id) == 0 {
		http.NotFound(w, r)
		return
	}
	c := &http.Client{}
	req, _ := http.NewRequest(http.MethodGet, fmt.Sprintf("%s/items/%s", d.DaprSidecarRootUrl, id), nil)
	req.Header.Set("dapr-app-id", d.InventoryServiceName)
	res, err := c.Do(req)

	if err != nil {
		log.Printf("Error while sending downstream request: %s", err)
		http.Error(w, "Internal Server Error", 500)
		return
	}
	defer res.Body.Close()

	io.Copy(w, res.Body)
}
