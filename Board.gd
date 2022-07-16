extends Node2D
class_name Board

var grid
const BOARD_SIZE = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = initialize_null_grid()
	$Button.connect("button_up", self, "debug")

func debug():
	print($Rook.generate_legal_moves())
	print($Bishop.generate_legal_moves())

func initialize_null_grid() -> Array:
	grid = []
	for i in range(BOARD_SIZE):
		grid.append([])
		for j in range(BOARD_SIZE):
			grid[i].append(null)
	return grid

func get_tile(pos: Vector2):
	return grid[pos[0]][pos[1]]

func is_in_grid(pos: Vector2) -> bool:
	for num in [pos.x, pos.y]:
		if num<0 or num>=BOARD_SIZE:
			return false
	return true
