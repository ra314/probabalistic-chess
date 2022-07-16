extends Node2D
class_name King

var board: Board
var grid_pos := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()
	pass # Replace with function body.


func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var pos_to_check := Vector2(x,y)
			if board.is_in_grid(pos_to_check):
				if board.get_tile(pos_to_check) == null:
					legal_moves.append(pos_to_check)
	
	return legal_moves
