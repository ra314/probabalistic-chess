extends Node2D
class_name Knight

var board: Board
var grid_pos := Vector2()
var is_white: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()
	pass # Replace with function body.

func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for x in [-2,-1,1,2]:
		for y in [-2,-1,1,2]:
			if abs(x) == abs(y):
				continue
			var pos_to_check := Vector2(x,y)
			if board.is_in_grid(pos_to_check):
				legal_moves.append(pos_to_check)
	
	return legal_moves
