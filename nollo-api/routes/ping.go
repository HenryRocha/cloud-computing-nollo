package routes

import "github.com/gofiber/fiber/v2"

// Ping : testing endpoint.
func Ping(c *fiber.Ctx) error {
	return c.SendString("Pong!")
}
