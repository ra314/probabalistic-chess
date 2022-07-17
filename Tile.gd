extends Node2D
class_name Tile

var grid_pos: Vector2
const size := Vector2(64,64)
var color: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(grid_pos) -> void:
	self.grid_pos = grid_pos
	position = size*grid_pos

func set_color(color: Color) -> void:
	self.color = color
	$Sprite.modulate = color
