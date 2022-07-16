extends Node2D

var board: Board = get_parent()
var grid_pos := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func generate_legal_moves() -> Array:
	var legal_moves := []
	var x := grid_pos[0]
	var y := grid_pos[1]
	
	# Move RIGHT
	while x>=0 and x<board.BOARD_SIZE:
		x += 1
		if board.grid[x][grid_pos[1]] == null:
			legal_moves.append(Vector2(x, grid_pos[1]))
	# Move LEFT
	while x>=0 and x<board.BOARD_SIZE:
		x -= 1
		if board.grid[x][grid_pos[1]] == null:
			legal_moves.append(Vector2(x, grid_pos[1]))
	# Move UP
	while y>=0 and y<board.BOARD_SIZE:
		y += 1
		if board.grid[y][grid_pos[1]] == null:
			legal_moves.append(Vector2(y, grid_pos[1]))
	# Move DOWN
	while y>=0 and y<board.BOARD_SIZE:
		y -= 1
		if board.grid[y][grid_pos[1]] == null:
			legal_moves.append(Vector2(y, grid_pos[1]))
	
	return legal_moves
