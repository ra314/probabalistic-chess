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

func place_on(new_grid_pos: Vector2) -> void:
	board.pieces_grid[grid_pos.x][grid_pos.y] = null
	board.pieces_grid[new_grid_pos.x][new_grid_pos.y] = self
	grid_pos = new_grid_pos
	position = size * grid_pos

func is_attack_successful(defender: Piece) -> bool:
	var maximum = defender.value + value
	var roll: int = RNG.rng.randi_range(1, maximum)
	board.update_chance(self, defender, roll)
	return roll > defender.value

func die() -> void:
	visible = false
	queue_free()
