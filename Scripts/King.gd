extends Piece
class_name King

# Called when the node enters the scene tree for the first time.
func _ready():
	self.white_piece = load("res://Assets/White_King.png")
	self.black_piece = load("res://Assets/Black_King.png")
	
	update_color(get_node(("Sprite")))
	# https://en.wikipedia.org/wiki/Chess_piece_relative_value
	value = 4
	self.prefix = "K"

func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var pos_to_check := grid_pos + Vector2(x,y)
			if board.is_in_grid(pos_to_check):
				if !board.does_pos_have_ally(pos_to_check, self):
					legal_moves.append(pos_to_check)
	
	return legal_moves
