extends Node2D
class_name Board

var grid
const BOARD_SIZE = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = initialize_null_grid()

func initialize_null_grid() -> Array:
	grid = []
	for i in range(BOARD_SIZE):
		grid.append([])
		for j in range(BOARD_SIZE):
			grid[i].append(null)
	return grid
