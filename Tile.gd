extends Node2D
class_name Tile

export(int) var x
export(int) var y
export(int) var size_x = 64
export(int) var size_y = 64
export(Color) var color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(x, y) -> void:
	self.x = x
	self.y = y
	
	position.x = size_x * x
	position.y = size_y * y

func set_color(color: Color) -> void:
	self.color = color
	$Sprite.modulate = color
