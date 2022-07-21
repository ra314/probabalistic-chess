extends Piece
class_name Bishop

func init():
	self.prefix = "B"
	self.value = 3
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	self.white_piece = load("res://Assets/White_Bishop.png")
	self.black_piece = load("res://Assets/Black_Bishop.png")
	
	update_color(get_node(("Sprite")))
	init()

var pos_to_check: Vector2
func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for method_name in ["move_NE", "move_SE", "move_NW", "move_SW"]:
		pos_to_check = grid_pos
		call(method_name)
		while BoardUtils.is_in_grid(pos_to_check):
			if !board.does_pos_have_ally(pos_to_check, self):
				legal_moves.append(pos_to_check)
			if !board.is_pos_empty(pos_to_check):
				break
			call(method_name)
	
	return legal_moves

func move_SW():
	pos_to_check += Vector2(-1,1)
func move_SE():
	pos_to_check += Vector2(1,1)
func move_NW():
	pos_to_check += Vector2(-1,-1)
func move_NE():
	pos_to_check += Vector2(1,-1)
