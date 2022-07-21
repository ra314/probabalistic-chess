extends Piece
class_name Pawn

func init():
	self.prefix = "P"
	self.value = 1
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	self.white_piece = load("res://Assets/White_Pawn.png")
	self.black_piece = load("res://Assets/Black_Pawn.png")
	
	update_color(get_node(("Sprite")))
	init()

const WHITE_STARTING_ROW = 6
const BLACK_STARTING_ROW = 1

static func is_on_promotion_square(row_num: int, is_white: bool) -> bool:
	return (is_white and row_num == BLACK_STARTING_ROW-1) \
			or (!is_white and row_num == WHITE_STARTING_ROW+1)

func is_at_starting_position() -> bool:
	if is_white and grid_pos[1] == WHITE_STARTING_ROW:
		return true
	if !is_white and grid_pos[1] == BLACK_STARTING_ROW:
		return true
	return false

func generate_legal_moves() -> Array:
	var legal_moves := []
	var y: int = -1 if is_white else 1
	
	# Moving 1 space as normal
	var pos_to_check: = grid_pos + Vector2(0,y)
	# TODO: This first if check should not be necessary, try and fix it.
	# This should be handled by auto promotion
	if BoardUtils.is_in_grid(pos_to_check):
		if board.is_pos_empty(pos_to_check):
			legal_moves.append(pos_to_check)
	
	# Moving 2 spaces at the start
	if is_at_starting_position():
		var row_plus_1 = grid_pos + Vector2(0,y)
		var row_plus_2 = grid_pos + Vector2(0,y*2)
		if board.is_pos_empty(row_plus_2):
			legal_moves.append(row_plus_2)
	
	# Diagonal capture
	for x in [-1,1]:
		pos_to_check = grid_pos + Vector2(x,y)
		if BoardUtils.is_in_grid(pos_to_check):
			if board.does_pos_have_enemy(pos_to_check, self):
				legal_moves.append(pos_to_check)
	
	return legal_moves
