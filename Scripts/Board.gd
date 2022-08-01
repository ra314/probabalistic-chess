extends Node2D
class_name Board


var rng = RandomNumberGenerator.new()
var is_white_turn := true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Pieces.init()
	$Visuals.init()
	RNG.init()
	$Visuals/Reset.connect("button_up", self, "reset")

func reset():
	get_tree().reload_current_scene() 


