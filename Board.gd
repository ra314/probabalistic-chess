extends Node2D
class_name Board

var grid
const BOARD_SIZE = 8
const TILE_DIRECTORY: String = "res://Tile.tscn"

var Tile = load(TILE_DIRECTORY) as Resource

export(int) var board_offset_x
export(int) var board_offset_y

export(Color) var tile_color
export(Color) var tile_color_alternate

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = initialize_grid()
	$Button.connect("button_up", self, "debug")

func debug():
	print($Rook.generate_legal_moves())
	print($Bishop.generate_legal_moves())
	print($Queen.generate_legal_moves())
	print($King.generate_legal_moves())
	print($Pawn.generate_legal_moves())
	print($Knight.generate_legal_moves())

func initialize_grid() -> Array:
	grid = []
	var alternate = false
	for x in range(BOARD_SIZE):
		grid.append([])
		for y in range(BOARD_SIZE):
			var tile = Tile.instance() as Tile
			tile.init(y + board_offset_x, x + board_offset_y)
			
			if !alternate:
				tile.set_color(tile_color)
			else:
				tile.set_color(tile_color_alternate)
				
			alternate = !alternate
				
			$Tiles.add_child(tile)
			grid[x].append(tile)
		
		# Switches the tile color on a new row
		alternate = !alternate
	return grid

func get_tile(pos: Vector2):
	return grid[pos[0]][pos[1]]

func is_in_grid(pos: Vector2) -> bool:
	for num in [pos.x, pos.y]:
		if num<0 or num>=BOARD_SIZE:
			return false
	return true
