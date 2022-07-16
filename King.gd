extends Piece
class_name King

var board: Board
var grid_pos := Vector2()
var is_white: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()
	
	self.white_piece = load("res://Assets/White_King.png")
	self.black_piece = load("res://Assets/Black_King.png")
	
	update_color(get_node(("Sprite")))

func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var pos_to_check := Vector2(x,y)
			if board.is_in_grid(pos_to_check):
				legal_moves.append(pos_to_check)
	
	return legal_moves
