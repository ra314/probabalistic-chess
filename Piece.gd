extends Node2D
class_name Piece

export(int) var x
export(int) var y

export(int) var size_x = 64
export(int) var size_y = 64

export(bool) var is_white_piece = true

var white_piece
var black_piece

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = size_x * x
	position.y = size_y * y
		
func update_color(sprite: Sprite) -> void:
	
	if is_white_piece:
		sprite.texture = white_piece
	else:
		sprite.texture = black_piece
