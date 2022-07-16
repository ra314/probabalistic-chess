extends Node2D
class_name Bishop

var board: Board
var grid_pos := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()
	pass # Replace with function body.

func generate_legal_moves() -> Array:
	var legal_moves := []
	
	# Move NE
	var x := grid_pos[0] + 1
	var y := grid_pos[1] - 1 
	var pos_to_check := Vector2(x, y)
	while board.is_in_grid(pos_to_check):
		if board.get_tile(pos_to_check) == null:
			legal_moves.append(pos_to_check)
		x += 1
		y -= 1
		pos_to_check = Vector2(x, y)
	
	# Move NW
	x = grid_pos[0]-1
	y = grid_pos[1]-1
	pos_to_check = Vector2(x, y)
	while board.is_in_grid(pos_to_check):
		if board.get_tile(pos_to_check) == null:
			legal_moves.append(pos_to_check)
		x -= 1
		y -= 1
		pos_to_check = Vector2(x, y)
	
	# Move SE
	x = grid_pos[0]+1
	y = grid_pos[1]+1
	pos_to_check = Vector2(x, y)
	while board.is_in_grid(pos_to_check):
		if board.get_tile(pos_to_check) == null:
			legal_moves.append(pos_to_check)
		x += 1
		y += 1
		pos_to_check = Vector2(x, y)
	
	# Move SW
	x = grid_pos[0]-1
	y = grid_pos[1]+1
	pos_to_check = Vector2(x, y)
	while board.is_in_grid(pos_to_check):
		if board.get_tile(pos_to_check) == null:
			legal_moves.append(pos_to_check)
		x -= 1
		y += 1
		pos_to_check = Vector2(x, y)
	
	return legal_moves
