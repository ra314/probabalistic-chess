extends Node2D
class_name Piece

const size := Vector2(64,64)
var grid_pos: Vector2
var is_white: bool
var board
var value: int
var prefix: String

var white_piece
var black_piece

### These setters are used when instancing this node to allow for one-liners
func set_color(is_white):
	self.is_white = is_white
	return self
func set_grid_pos(grid_pos):
	self.grid_pos = grid_pos
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()
	board.pieces_grid[grid_pos.x][grid_pos.y] = self
	position = size*grid_pos

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
	# Wipe the old position
	board.set_through_grid_pos(grid_pos, null)
	board.set_through_grid_pos(new_grid_pos, self)
	grid_pos = new_grid_pos
	position = size * grid_pos
	
	# Pawn promotion
	if prefix == "P":
		if PAWN.is_on_promotion_square(grid_pos.y, is_white):
			promote_self_to_queen()

func is_attack_successful(defender: Piece) -> bool:
	var maximum = defender.value + value
	var roll: int = RNG.rng.randi_range(1, maximum)
	board.update_chance(self, defender, roll)
	return roll > defender.value

func die() -> void:
	visible = false
	queue_free()
