extends Node2D
class_name BoardPieces

var ROOK := load("res://Scenes/Rook.tscn")
var BISHOP := load("res://Scenes/Bishop.tscn")
var KNIGHT := load("res://Scenes/Knight.tscn")
var QUEEN := load("res://Scenes/Queen.tscn")
var KING := load("res://Scenes/King.tscn")
var PAWN := load("res://Scenes/Pawn.tscn")
var letter_to_piece := {"R": ROOK, "B": BISHOP, "N": KNIGHT, "Q": QUEEN, "K": KING, "P": PAWN}

var all_pieces = {}
var pieces_grid: Array
const BOARD_LETTERS = "abcdefgh"

func init():
	pieces_grid = BoardUtils.initialize_empty_grid()
	intialize_pieces()

func intialize_pieces() -> void:
	var algebraic_pos: String
	
	# Adding pawns
	for letter in BOARD_LETTERS:
		algebraic_pos = letter + str(2)
		add_child(PAWN.instance()\
			.set_grid_pos(BoardUtils.algebraic_pos_to_grid_pos(algebraic_pos))\
			.set_color(true))
		algebraic_pos = letter + str(7)
		add_child(PAWN.instance()\
			.set_grid_pos(BoardUtils.algebraic_pos_to_grid_pos(algebraic_pos))\
			.set_color(false))
	
	# Adding major pieces
	var pieces := "Ra1 Nb1 Bc1 Qd1 Ke1 Bf1 Ng1 Rh1"
	for piece in pieces.split(" "):
		var node = letter_to_piece[piece[0]]
		add_child(node.instance()\
			.set_grid_pos(BoardUtils.algebraic_pos_to_grid_pos(piece.right(1)))\
			.set_color(true))
		add_child(node.instance()\
			.set_grid_pos(BoardUtils.algebraic_pos_to_grid_pos(piece[1] + str(BoardUtils.BOARD_SIZE)))\
			.set_color(false))

func set_through_grid_pos(pos: Vector2, piece) -> void:
	all_pieces.erase(pieces_grid[pos.x][pos.y])
	all_pieces[piece] = true
	pieces_grid[pos.x][pos.y] = piece

func get_piece_from_grid_pos(pos: Vector2):
	return pieces_grid[pos[0]][pos[1]]

func get_piece_from_algebraic_pos(pos: String):
	var grid_pos := BoardUtils.algebraic_pos_to_grid_pos(pos)
	return get_piece_from_grid_pos(grid_pos)

func is_pos_empty(pos: Vector2) -> bool:
	return get_piece_from_grid_pos(pos) == null

func does_pos_have_enemy(pos: Vector2, piece) -> bool:
	if !is_pos_empty(pos):
		return get_piece_from_grid_pos(pos).is_white != piece.is_white
	return false

func does_pos_have_ally(pos: Vector2, piece) -> bool:
	if !is_pos_empty(pos):
		return get_piece_from_grid_pos(pos).is_white == piece.is_white
	return false

func get_pieces() -> Array:
	all_pieces.erase(null)
	return all_pieces.keys()
