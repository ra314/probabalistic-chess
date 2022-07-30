extends Node

const tile_color = Color( 0.47451, 0.282353, 0.223529, 1 )
const tile_color_alternate = Color( 0.364706, 0.196078, 0.192157, 1 )
var TILE := load("res://Scenes/Tile.tscn")
var tiles_grid: Array
var B: Board
var BP: BoardPieces
var BAI: BoardAI

func _ready():
	B = get_parent()
	BP = get_parent().get_node("Pieces")
	BAI = get_parent().get_node("AI")
	$Button.connect("button_up", self, "get_ai_suggestion")

func init() -> void:
	tiles_grid = BoardUtils.initialize_empty_grid()
	initialize_background_tiles(tiles_grid)

func get_tile_from_grid_pos(pos: Vector2) -> Tile:
	return tiles_grid[pos[0]][pos[1]]

var prev_selected_tile_pos: Vector2
var highlighted_movement_tiles: Array

func was_pos_previously_available_for_movement(grid_pos: Vector2) -> bool:
	# Return false if the same tile was clicked twice
	if prev_selected_tile_pos == grid_pos:
		return false
	for tile in highlighted_movement_tiles:
		if tile.grid_pos == grid_pos:
			return true
	return false

# Deselecting previous actions
func undo_highlight() -> void:
	get_tile_from_grid_pos(prev_selected_tile_pos).deselect()
	for tile in highlighted_movement_tiles:
		tile.dehighlight_movement()

func click_grid_pos(grid_pos: Vector2) -> void:
	undo_highlight()
	
	if was_pos_previously_available_for_movement(grid_pos):
		var prev_selected_piece = BP.pieces_grid[prev_selected_tile_pos]
		if BP.does_pos_have_enemy(grid_pos, prev_selected_piece):
			var enemy = BP.pieces_grid[grid_pos]
			var retval = prev_selected_piece.is_attack_successful(enemy)
			update_chance(prev_selected_piece, enemy, retval["roll"])
			if retval["attack_success"]:
				enemy.die()
				prev_selected_piece.place_on(grid_pos)
		else:
			prev_selected_piece.place_on(grid_pos)
		highlighted_movement_tiles = []
		B.is_white_turn = !B.is_white_turn
		return
	else:
		undo_highlight()
		show_chance(false)

	highlighted_movement_tiles = []
	
	if !BP.is_pos_empty(grid_pos):
		# Highlight the selected tile
		get_tile_from_grid_pos(grid_pos).select()
		prev_selected_tile_pos = grid_pos
		
		# Highlight the possible movement tiles
		for legal_move in BP.pieces_grid[grid_pos].generate_legal_moves():
			var tile: Tile = get_tile_from_grid_pos(legal_move)
			tile.highlight_movement()
			highlighted_movement_tiles.append(tile)

func initialize_background_tiles(tiles_grid: Array) -> void:
	var white = true
	for x in range(BoardUtils.BOARD_SIZE):
		for y in range(BoardUtils.BOARD_SIZE):
			var tile = TILE.instance()
			tile.init(Vector2(x, y))
			
			if !white:
				tile.set_color(tile_color)
			else:
				tile.set_color(tile_color_alternate)
				
			white = !white
			
			$Tiles.add_child(tile)
			tiles_grid[x][y] = tile
			tile.connect("button_up", self, "click_grid_pos", [tile.grid_pos])
		# Switches the tile color on a new row
		white = !white

export(Color) var chance_visual_white = Color.white
export(Color) var chance_visual_black = Color.black

func show_chance(show: bool) -> void:
	$"Chance Visual".visible = show
	
func update_chance(attacker: Piece, defender: Piece, roll: int) -> void:
	show_chance(true)
	
	var tween: Tween = $Tween
	
	var value: int = attacker.value
	var maximum: int = defender.value + value
	var roll_to_capture: int = defender.value + 1
	
	var attack_sprite = $"Chance Visual/Attacking" as Sprite
	var defend_sprite = $"Chance Visual/Defending" as Sprite
	
	attack_sprite.texture = (attacker.get_node("Sprite") as Sprite).texture
	defend_sprite.texture = (defender.get_node("Sprite") as Sprite).texture
	
	var bar = $"Chance Visual/Chance Bar" as TextureProgress
	
	# Chance the Texture Bar to have the color attacking on the left
	# Filling up to the right
	if attacker.is_white:
		bar.tint_progress = chance_visual_white
		bar.tint_under = chance_visual_black
	else:
		bar.tint_progress = chance_visual_black
		bar.tint_under = chance_visual_white
	
	bar.max_value = maximum
	
	tween.interpolate_property(bar, "value", float(0), float(roll), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	
	var roll_control = $"Chance Visual/Roll" as Node2D
	var roll_text =  $"Chance Visual/Roll/Text" as Label
	
	roll_text.text = "%s" % [roll_to_capture]
	roll_control.position.x = bar.rect_position.x + (float(roll_to_capture) / float(maximum)) * bar.rect_size.x
	
	var odds = $"Chance Visual/Odds/Text" as Label
	
	odds.text = "%s:%s" % [attacker.value, defender.value]

# CURRENTLY ONLY MAKES SUGGESTIONS FOR BLACK
func get_ai_suggestion():
	var moves = BAI.evaluate_MM_root(6, false)[1]
	var move = moves[len(moves)-1]
	click_grid_pos(move[0])
	yield(get_tree().create_timer(1), "timeout")
	click_grid_pos(move[1])
