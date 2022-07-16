extends Node2D
class_name Piece

const size := Vector2(64,64)
var algebraic_pos: String
var grid_pos: Vector2
var is_white: bool
var board

var white_piece
var black_piece

func init(algebraic_pos, is_white):
	self.algebraic_pos = algebraic_pos
	self.is_white = is_white
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()
	grid_pos = board.algebraic_pos_to_grid_pos(algebraic_pos)
	board.grid[grid_pos.x][grid_pos.y] = self
	position = size*grid_pos

func update_color(sprite: Sprite) -> void:
	if is_white:
		sprite.texture = white_piece
	else:
		sprite.texture = black_piece
