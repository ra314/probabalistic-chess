extends Node2D
class_name Piece

const SIZE := Vector2(64,64)
const INVALID_GRID_POS := Vector2(-1,-1)
var grid_pos: Vector2 = INVALID_GRID_POS
var is_white: bool
var board: BoardPieces
var value: int
var prefix: String

var white_piece
var black_piece

### These setters are used when instancing this node to allow for one-liners
func set_color(is_white):
	self.is_white = is_white
	return self
func set_board(board: BoardPieces):
	self.board = board
	board.all_pieces[is_white][self] = true
	return self
func set_grid_pos(grid_pos):
	position = SIZE*grid_pos
	place_on(grid_pos)
	return self

func init2(is_white: bool, board: BoardPieces, grid_pos: Vector2) -> Piece:
	self.is_white = is_white
	self.board = board
	board.all_pieces[is_white][self] = true
	position = SIZE*grid_pos
	place_on(grid_pos)
	return self

func update_color(sprite: Sprite) -> void:
	if is_white:
		sprite.texture = white_piece
	else:
		sprite.texture = black_piece

var QUEEN := load("res://Scenes/Queen.tscn")
func promote_self_to_queen() -> void:
	var new_queen = QUEEN.instance().set_grid_pos(grid_pos).set_color(is_white).init()
	new_queen.board = board
	board.add_child(new_queen)
	# This also wipes the pawn from the current position
	board.set_through_grid_pos(grid_pos, new_queen)
	# Get rid of the pawn visually and from memory
	visible = false
	die()

var PAWN := load("res://Scripts/Pawn.gd")
func place_on(new_grid_pos: Vector2) -> void:
	if grid_pos != INVALID_GRID_POS:
		# Wipe the old position
		board.set_through_grid_pos(grid_pos, null)
	board.set_through_grid_pos(new_grid_pos, self)
	grid_pos = new_grid_pos
	position = SIZE * grid_pos
	
	# Pawn promotion
	if prefix == "P":
		if PAWN.is_on_promotion_square(grid_pos.y, is_white):
			promote_self_to_queen()

func odds_of_successful_attack(defender: Piece) -> float:
	return float(value)/float(defender.value + value)
# Returns {"attack_success": bool, "roll": int}
func is_attack_successful(defender: Piece) -> Dictionary:
	var maximum = defender.value + value
	var roll: int = RNG.rng.randi_range(1, maximum)
	return {"attack_success": roll > defender.value, "roll": roll}

func die() -> void:
	board.all_pieces[is_white].erase(self)
	visible = false

func revive() -> void:
	board.set_through_grid_pos(grid_pos, self)
	board.all_pieces[is_white][self] = true
	visible = true
