package models

import (
	"time"
)

// Todo struct defines the complete model for a todo in the
// database.
type Todo struct {
	ID          uint64    `json:"id" gorm:"not null" gorm:"primarykey"`
	Title       string    `json:"title" gorm:"not null"`
	Description string    `json:"description"`
	Updated     time.Time `json:"updated" gorm:"not null"`
}

// NewTodo struct defines the model used to insert a new todo
// into the database.
type NewTodo struct {
	ID          uint64 `json:"id"`
	Title       string `json:"title" gorm:"not null"`
	Description string `json:"description"`
}
