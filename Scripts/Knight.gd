extends Piece
class_name Knight

func init():
	self.prefix = "N"
	self.value = 3
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	self.white_piece = load("res://Assets/White_Knight.png")
	self.black_piece = load("res://Assets/Black_Knight.png")
	
	update_color(get_node(("Sprite")))
	init()

func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for x in [-2,-1,1,2]:
		for y in [-2,-1,1,2]:
			if abs(x) == abs(y):
				continue
			var pos_to_check := grid_pos + Vector2(x,y)
			if BoardUtils.is_in_grid(pos_to_check):
				if !board.does_pos_have_ally(pos_to_check, self):
					legal_moves.append(pos_to_check)
	
	return legal_moves
