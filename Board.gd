extends Node2D
class_name Board

var grid
const BOARD_SIZE = 8
const BOARD_LETTERS = "abcdefgh"

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = initialize_empty_grid()
	intialize_pieces()
	initialize_background_tiles()
	$Button.connect("button_up", self, "debug")

func debug():
	for algebraic_pos in "a1 b1 c1 d1 e1 a2".split(" "):
		print(get_piece_from_algebraic_pos(algebraic_pos))
		for legal_move in get_piece_from_algebraic_pos(algebraic_pos).generate_legal_moves():
			print(grid_pos_to_algebraic_pos(legal_move))


const TILE_DIRECTORY: String = "res://Tile.tscn"
var Tile = load(TILE_DIRECTORY) as Resource
var board_offset: Vector2
export(Color) var tile_color
export(Color) var tile_color_alternate

func initialize_background_tiles() -> void:
	var alternate = false
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var tile = Tile.instance() as Tile
			tile.init(Vector2(y, x) + board_offset)
			
			if !alternate:
				tile.set_color(tile_color)
			else:
				tile.set_color(tile_color_alternate)
				
			alternate = !alternate
				
			$Tiles.add_child(tile)
		# Switches the tile color on a new row
		alternate = !alternate

func initialize_empty_grid() -> Array:
	grid = []
	for x in range(BOARD_SIZE):
		grid.append([])
		for y in range(BOARD_SIZE):
			grid[x].append(null)
	return grid

var ROOK := load("res://Rook.tscn")
var BISHOP := load("res://Bishop.tscn")
var KNIGHT := load("res://Knight.tscn")
var QUEEN := load("res://Queen.tscn")
var KING := load("res://King.tscn")
var PAWN := load("res://Pawn.tscn")

func intialize_pieces() -> void:
	var algebraic_pos: String
	
	# Adding pawns
	for letter in BOARD_LETTERS:
		algebraic_pos = letter + str(2)
		add_child(PAWN.instance().init(algebraic_pos, true))
		algebraic_pos = letter + str(7)
		add_child(PAWN.instance().init(algebraic_pos, false))
	
	# Adding major pieces
	var pieces := "Ra1 Nb1 Bc1 Qd1 Ke1 Bf1 Ng1 Rh1"
	var letter_to_piece := {"R": ROOK, "B": BISHOP, "N": KNIGHT, "Q": QUEEN, "K": KING}
	for piece in pieces.split(" "):
		var node = letter_to_piece[piece[0]]
		add_child(node.instance().init(piece.right(1), true))
		add_child(node.instance().init(piece[1] + str(BOARD_SIZE), false))

func get_piece_from_grid_pos(pos: Vector2) -> Piece:
	return grid[pos[0]][pos[1]]

func get_piece_from_algebraic_pos(pos: String) -> Piece:
	var grid_pos := algebraic_pos_to_grid_pos(pos)
	return get_piece_from_grid_pos(grid_pos)

func is_tile_empty(pos: Vector2) -> bool:
	return get_piece_from_grid_pos(pos) == null

func does_tile_have_enemy(pos: Vector2, piece: Piece) -> bool:
	if !is_tile_empty(pos):
		return get_piece_from_grid_pos(pos).is_white != piece.is_white
	return false

func does_tile_have_ally(pos: Vector2, piece: Piece) -> bool:
	if !is_tile_empty(pos):
		return get_piece_from_grid_pos(pos).is_white == piece.is_white
	return false

func is_in_grid(pos: Vector2) -> bool:
	for num in [pos.x, pos.y]:
		if num<0 or num>=BOARD_SIZE:
			return false
	return true

func algebraic_pos_to_grid_pos(pos: String) -> Vector2:
	assert(len(pos)==2)
	assert(pos[1].is_valid_integer())
	
	var new_pos: Vector2
	new_pos.x = ord(pos.to_lower()[0])-ord('a')
	new_pos.y = BOARD_SIZE - int(pos[1])
	return new_pos

func grid_pos_to_algebraic_pos(pos: Vector2) -> String:
	return char(pos.x+ord('a')) + str(BOARD_SIZE - int(pos.y))
