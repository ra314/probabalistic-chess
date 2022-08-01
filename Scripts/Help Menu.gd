extends Node2D

var B: Board

# Called when the node enters the scene tree for the first time.
func _ready():
	B = get_parent()
	$Back.connect("button_up", self, "toggle_help_menu")

func toggle_help_menu():
	B.get_node("Visuals").visible = true
	B.get_node("Pieces").visible = true
	visible = false
