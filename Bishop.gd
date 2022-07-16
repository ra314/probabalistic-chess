extends Node2D
class_name Bishop

var board: Board = get_parent()
var grid_pos := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func generate_legal_moves() -> Array:
	var legal_moves := []
	var x := grid_pos[0]
	var y := grid_pos[1]
	
	return legal_moves
