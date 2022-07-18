extends Node2D
class_name Piece

const size := Vector2(64,64)
var grid_pos: Vector2
var is_white: bool
var board
var value: int
var prefix: String

# These 2 vars are used in MCTS to enable us to reset after performing rollout
# on a single node.
var is_dead := false
var before_mcts_grid_pos: Vector2

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
	before_mcts_grid_pos = grid_pos
	board.pieces_grid[grid_pos.x][grid_pos.y] = self
	position = size*grid_pos

func update_color(sprite: Sprite) -> void:
	if is_white:
		sprite.texture = white_piece
	else:
		sprite.texture = black_piece

var QUEEN := load("res://Scenes/Queen.tscn")
func place_on(new_grid_pos: Vector2) -> void:
	# Wipe the old position
	board.set_through_grid_pos(grid_pos, null)
	
	# Pawn promotion
	if prefix == "P":
		if (is_white and new_grid_pos.y == 0) or \
			(!is_white and new_grid_pos.y == board.BOARD_SIZE-1):
			var new_queen = QUEEN.instance().set_grid_pos(new_grid_pos).set_color(is_white).init()
			new_queen.board = board
			board.set_through_grid_pos(new_grid_pos, new_queen)
			visible = false
			is_dead = true
			return
	
	board.set_through_grid_pos(new_grid_pos, self)
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

func mcts_reset() -> void:
	is_dead = false
	visible = true
	get_node("Sprite").modulate = Color(1,1,1,1)
	board.set_through_grid_pos(grid_pos, null)
	grid_pos = before_mcts_grid_pos
	position = size * grid_pos
