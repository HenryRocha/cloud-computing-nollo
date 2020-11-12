package main

import (
	"fmt"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/henryrocha/nollo/database"
	"github.com/henryrocha/nollo/routes"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func initDatabaseConnection() {
	var dsn string = os.Getenv("DB_DSN")
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
	app.Use(cors.New())
	app.Use(logger.New())
	initDatabaseConnection()
	setupRoutes(app)
	app.Listen(":8001")
}
