extends Piece
class_name Rook

# Called when the node enters the scene tree for the first time.
func _ready():
	self.white_piece = load("res://Assets/White_Rook.png")
	self.black_piece = load("res://Assets/Black_Rook.png")
	
	update_color(get_node(("Sprite")))

var pos_to_check: Vector2
func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for method_name in ["move_N", "move_S", "move_E", "move_W"]:
		pos_to_check = grid_pos
		call(method_name)
		while board.is_in_grid(pos_to_check):
			if !board.does_tile_have_ally(pos_to_check, self):
				legal_moves.append(pos_to_check)
			if !board.is_tile_empty(pos_to_check):
				break
			call(method_name)
	
	return legal_moves

func move_N():
	pos_to_check += Vector2(0,1)
func move_S():
	pos_to_check += Vector2(0,-1)
func move_E():
	pos_to_check += Vector2(1,0)
func move_W():
	pos_to_check += Vector2(-1,0)