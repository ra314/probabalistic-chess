extends Node2D
class_name BoardPieces

var ROOK := load("res://Scenes/Rook.tscn")
var BISHOP := load("res://Scenes/Bishop.tscn")
var KNIGHT := load("res://Scenes/Knight.tscn")
var QUEEN := load("res://Scenes/Queen.tscn")
var KING := load("res://Scenes/King.tscn")
var PAWN := load("res://Scenes/Pawn.tscn")
var letter_to_piece := {"R": ROOK, "B": BISHOP, "N": KNIGHT, "Q": QUEEN, "K": KING, "P": PAWN}

var white_pieces = {}
var black_pieces = {}
var all_pieces = {true: white_pieces, false: black_pieces}
var pieces_grid := {}
const BOARD_LETTERS = "abcdefgh"
var eval := 0.0

func init():
	intialize_pieces()

func duplicate_board(boardPieces) -> void:
	for piece in get_pieces():
		letter_to_piece[piece.prefix].instance()\
		.init().init2(piece.is_white, boardPieces, piece.grid_pos).init()

func intialize_pieces() -> void:
	var algebraic_pos: String
	var grid_pos: Vector2
	
	# Adding pawns
	for letter in BOARD_LETTERS:
		algebraic_pos = letter + str(2)
		grid_pos = BoardUtils.algebraic_pos_to_grid_pos(algebraic_pos)
		add_child(PAWN.instance().init().init2(true, self, grid_pos))
		algebraic_pos = letter + str(7)
		grid_pos = BoardUtils.algebraic_pos_to_grid_pos(algebraic_pos)
		add_child(PAWN.instance().init().init2(false, self, grid_pos))
	
	# Adding major pieces
	var pieces := "Ra1 Nb1 Bc1 Qd1 Ke1 Bf1 Ng1 Rh1"
	for piece in pieces.split(" "):
		var node = letter_to_piece[piece[0]]
		grid_pos = BoardUtils.algebraic_pos_to_grid_pos(piece.right(1))
		add_child(node.instance().init().init2(true, self, grid_pos))
		grid_pos = BoardUtils.algebraic_pos_to_grid_pos(piece[1] + str(BoardUtils.BOARD_SIZE))
		add_child(node.instance().init().init2(false, self, grid_pos))
	
	# Create initial cache of legal moves
	for piece in get_pieces():
		piece.cached_legal_moves = piece.generate_legal_moves()

func get_piece_from_algebraic_pos(pos: String):
	var grid_pos := BoardUtils.algebraic_pos_to_grid_pos(pos)
	return pieces_grid[grid_pos]

func is_pos_empty(pos: Vector2) -> bool:
	return !pieces_grid.has(pos)

func does_pos_have_enemy(pos: Vector2, piece) -> bool:
	if !is_pos_empty(pos):
		return pieces_grid[pos].is_white != piece.is_white
	return false

func does_pos_have_ally(pos: Vector2, piece) -> bool:
	if !is_pos_empty(pos):
		return pieces_grid[pos].is_white == piece.is_white
	return false

func get_pieces() -> Array:
	return white_pieces.keys() + black_pieces.keys()

func debug_print() -> String:
	var retval = ""
	for row in pieces_grid:
		for piece in row:
			if piece == null:
				retval += '#'
			else:
				retval += str(piece.value)
		retval += "\n"
	return retval
