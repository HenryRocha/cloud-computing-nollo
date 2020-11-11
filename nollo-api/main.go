package main

import (
	"fmt"

	"github.com/gofiber/fiber/v2"
	"github.com/henryrocha/nollo/database"
	"github.com/henryrocha/nollo/routes"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func initDatabaseConnection() {
	var dsn string = "nollo_api:nollo_api_pw@tcp(10.0.1.5:80)/nollo_dev?charset=utf8mb4&parseTime=True&loc=Local"
	var err error

	database.DBConn, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("Failed to connect database.")
	}

	fmt.Println("Successfully connected to database.")
	return
}

func setupRoutes(app *fiber.App) {
	// Health check endpoint.
	app.Get("/api/v1/ping", routes.Ping)

	// Todos endpoints.
	app.Get("/api/v1/todos", routes.GetTodos)
	app.Get("/api/v1/todos/:id", routes.GetTodo)
	app.Post("/api/v1/todos", routes.NewTodo)
	app.Delete("/api/v1/todos/:id", routes.DeleteTodo)
	app.Patch("/api/v1/todos", routes.UpdateTodo)
}

func main() {
	app := fiber.New()
	initDatabaseConnection()
	setupRoutes(app)
	app.Listen(":8001")
}
