extends Piece
class_name King

func init():
	self.prefix = "K"
	# https://en.wikipedia.org/wiki/Chess_piece_relative_value
	self.value = 4
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	self.white_piece = load("res://Assets/White_King.png")
	self.black_piece = load("res://Assets/Black_King.png")
	
	update_color(get_node(("Sprite")))
	init()

func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var pos_to_check := grid_pos + Vector2(x,y)
			if BoardUtils.is_in_grid(pos_to_check):
				if !board.does_pos_have_ally(pos_to_check, self):
					legal_moves.append(pos_to_check)
	
	return legal_moves
