extends Piece
class_name Pawn

var board: Board
var grid_pos := Vector2()
var is_white := true

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()

	self.white_piece = load("res://Assets/White_Pawn.png")
	self.black_piece = load("res://Assets/Black_Pawn.png")
	
	update_color(get_node(("Sprite")))

const WHITE_STARTING_ROW = 1
const BLACK_STARTING_ROW = 6

func is_at_starting_position() -> bool:
	if is_white and grid_pos[1] == WHITE_STARTING_ROW:
		return true
	if !is_white and grid_pos[1] == BLACK_STARTING_ROW:
		return true
	return false

func generate_legal_moves() -> Array:
	var legal_moves := []
	var y: int = 1 if is_white else -1
	
	# Moving 1 space as normal
	var pos_to_check: = grid_pos + Vector2(0,y)
	if board.get_tile(pos_to_check) == null:
		legal_moves.append(pos_to_check)
	
	# Moving 2 spaces at the start
	if is_at_starting_position():
		var row_plus_1 = grid_pos + Vector2(0,y)
		var row_plus_2 = grid_pos + Vector2(0,y*2)
		if board.get_tile(row_plus_1) == null and board.get_tile(row_plus_2) == null:
			legal_moves.append(row_plus_2)
	
	# Diagonal capture
	for x in [-1,1]:
		pos_to_check = Vector2(x,y)
		if board.get_tile(pos_to_check) != null:
			legal_moves.append(pos_to_check)
	
	return legal_moves
