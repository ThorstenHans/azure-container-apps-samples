package main

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

func getPort() int {
	port := 80
	p := os.Getenv("PORT")
	if len(p) == 0 {
		return port
	}
	port, _ = strconv.Atoi(p)
	return port
}
func main() {
	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()
	r.GET("/hello", func(ctx *gin.Context) {
		ctx.JSON(200, gin.H{
			"message": "Hello from Azure Container Apps",
		})
	})

	r.GET("/healthz/readiness", func(ctx *gin.Context) {
		time.Sleep(time.Second)
		ctx.Status(200)
	})

	r.GET("/healthz/liveness", func(ctx *gin.Context) {
		time.Sleep(250 * time.Millisecond)
		ctx.Status(200)
	})

	r.GET("/healthz/startup", func(ctx *gin.Context) {
		time.Sleep(400 * time.Millisecond)
		ctx.Status(200)
	})
	port := fmt.Sprintf(":%d", getPort())
	fmt.Printf("Going to start API at %s\n", port)
	r.Run(port)
}
