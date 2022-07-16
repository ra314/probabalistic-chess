extends Node2D
class_name Rook

var board: Board
var grid_pos := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()
	pass # Replace with function body.

func generate_legal_moves() -> Array:
	var legal_moves := []
	
	print(board)
	
	# Move RIGHT
	var x := grid_pos[0]+1
	var pos_to_check := Vector2(x, grid_pos[1])
	while board.is_in_grid(pos_to_check):
		if board.get_tile(pos_to_check) == null:
			legal_moves.append(pos_to_check)
		x += 1
		pos_to_check = Vector2(x, grid_pos[1])
	
	# Move LEFT
	x = grid_pos[0]-1
	pos_to_check = Vector2(x, grid_pos[1])
	while board.is_in_grid(pos_to_check):
		if board.get_tile(pos_to_check) == null:
			legal_moves.append(pos_to_check)
		x -= 1
		pos_to_check = Vector2(x, grid_pos[1])
	
	# Move UP
	var y := grid_pos[1]+1
	pos_to_check = Vector2(grid_pos[0], y)
	while board.is_in_grid(pos_to_check):
		if board.get_tile(pos_to_check) == null:
			legal_moves.append(pos_to_check)
		y += 1
		pos_to_check = Vector2(grid_pos[0], y)
	
	# Move DOWN
	y = grid_pos[1]-1
	pos_to_check = Vector2(grid_pos[0], y)
	while board.is_in_grid(pos_to_check):
		if board.get_tile(pos_to_check) == null:
			legal_moves.append(pos_to_check)
		y -= 1
		pos_to_check = Vector2(grid_pos[0], y)
	
	return legal_moves
