extends Node2D
class_name Board

var pieces_grid: Array
var tiles_grid: Array
const BOARD_LETTERS = "abcdefgh"
var rng = RandomNumberGenerator.new()
var is_white_turn := true

# Called when the node enters the scene tree for the first time.
func _ready():
	pieces_grid = BoardUtils.initialize_empty_grid()
	intialize_pieces()
	tiles_grid = BoardUtils.initialize_empty_grid()
	initialize_background_tiles()
	$Button.connect("button_up", self, "get_ai_suggestion")
	rng.randomize()

func get_ai_suggestion():
	var move = monte_carlo_search()
	click_grid_pos(move[0])
	yield(get_tree().create_timer(1), "timeout")
	click_grid_pos(move[1])

func get_tile_from_grid_pos(pos: Vector2) -> Tile:
	return tiles_grid[pos[0]][pos[1]]

var prev_selected_tile_pos: Vector2
var highlighted_movement_tiles: Array

func was_pos_previously_available_for_movement(grid_pos: Vector2) -> bool:
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
		var prev_selected_piece = get_piece_from_grid_pos(prev_selected_tile_pos)
		if does_pos_have_enemy(grid_pos, prev_selected_piece):
			var enemy = get_piece_from_grid_pos(grid_pos)
			var retval = prev_selected_piece.is_attack_successful(enemy)
			if retval["attack_success"]:
				update_chance(prev_selected_piece, enemy, retval["roll"])
				enemy.die()
				prev_selected_piece.place_on(grid_pos)
		else:
			prev_selected_piece.place_on(grid_pos)
		highlighted_movement_tiles = []
		is_white_turn = !is_white_turn
		return
	else:
		undo_highlight()
		show_chance(false)

	highlighted_movement_tiles = []
	
	if !is_pos_empty(grid_pos):
		# Highlight the selected tile
		get_tile_from_grid_pos(grid_pos).select()
		prev_selected_tile_pos = grid_pos
		
		# Highlight the possible movement tiles
		for legal_move in get_piece_from_grid_pos(grid_pos).generate_legal_moves():
			var tile: Tile = get_tile_from_grid_pos(legal_move)
			tile.highlight_movement()
			highlighted_movement_tiles.append(tile)

var TILE := load("res://Scenes/Tile.tscn")
export(Color) var tile_color
export(Color) var tile_color_alternate

func initialize_background_tiles() -> void:
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



var ROOK := load("res://Scenes/Rook.tscn")
var BISHOP := load("res://Scenes/Bishop.tscn")
var KNIGHT := load("res://Scenes/Knight.tscn")
var QUEEN := load("res://Scenes/Queen.tscn")
var KING := load("res://Scenes/King.tscn")
var PAWN := load("res://Scenes/Pawn.tscn")
var letter_to_piece := {"R": ROOK, "B": BISHOP, "N": KNIGHT, "Q": QUEEN, "K": KING, "P": PAWN}

func intialize_pieces() -> void:
	var algebraic_pos: String
	
	# Adding pawns
	for letter in BOARD_LETTERS:
		algebraic_pos = letter + str(2)
		add_child(PAWN.instance()\
			.set_grid_pos(BoardUtils.algebraic_pos_to_grid_pos(algebraic_pos))\
			.set_color(true))
		algebraic_pos = letter + str(7)
		add_child(PAWN.instance()\
			.set_grid_pos(BoardUtils.algebraic_pos_to_grid_pos(algebraic_pos))\
			.set_color(false))
	
	# Adding major pieces
	var pieces := "Ra1 Nb1 Bc1 Qd1 Ke1 Bf1 Ng1 Rh1"
	for piece in pieces.split(" "):
		var node = letter_to_piece[piece[0]]
		add_child(node.instance()\
			.set_grid_pos(BoardUtils.algebraic_pos_to_grid_pos(piece.right(1)))\
			.set_color(true))
		add_child(node.instance()\
			.set_grid_pos(BoardUtils.algebraic_pos_to_grid_pos(piece[1] + str(BoardUtils.BOARD_SIZE)))\
			.set_color(false))

func set_through_grid_pos(pos: Vector2, piece) -> void:
	pieces_grid[pos.x][pos.y] = piece

func get_piece_from_grid_pos(pos: Vector2):
	return pieces_grid[pos[0]][pos[1]]

func get_piece_from_algebraic_pos(pos: String):
	var grid_pos := BoardUtils.algebraic_pos_to_grid_pos(pos)
	return get_piece_from_grid_pos(grid_pos)

func is_pos_empty(pos: Vector2) -> bool:
	return get_piece_from_grid_pos(pos) == null

func does_pos_have_enemy(pos: Vector2, piece) -> bool:
	if !is_pos_empty(pos):
		return get_piece_from_grid_pos(pos).is_white != piece.is_white
	return false

func does_pos_have_ally(pos: Vector2, piece) -> bool:
	if !is_pos_empty(pos):
		return get_piece_from_grid_pos(pos).is_white == piece.is_white
	return false

export(Color) var chance_visual_white = Color.white
export(Color) var chance_visual_black = Color.black

func show_chance(show: bool) -> void:
	$"Chance Visual".visible = show
	
func update_chance(attacker, defender, roll: int) -> void:
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

func get_pieces() -> Array:
	var pieces = []
	for x in range(BoardUtils.BOARD_SIZE):
		for y in range(BoardUtils.BOARD_SIZE):
			var piece = pieces_grid[x][y]
			if piece != null:
				pieces.append(piece)
	return pieces

var BOARD := load("res://Scenes/Board.tscn")
func init_fake() -> Board:
	var fake_board = BOARD.instance()
	fake_board.pieces_grid = BoardUtils.initialize_empty_grid()
	for piece in get_pieces():
		var new_piece = letter_to_piece[piece.prefix].instance()\
						.set_grid_pos(piece.grid_pos).set_color(piece.is_white)\
						.init()
		new_piece.board = fake_board
		new_piece.visible = false
		fake_board.pieces_grid[new_piece.grid_pos.x][new_piece.grid_pos.y] = new_piece
	return fake_board

func index_random(array):
	return rng.randi() % len(array)

func select_random(array):
	return array[index_random(array)]

func select_random_and_remove(array):
	array = array.duplicate()
	var index = index_random(array)
	var selection = array[index]
	array.remove(index)
	return selection

var mcts_node = {"children": {}, "wins": 0, "parent": null, "total": 0,\
				 "move": [], "killed":null}
							# killed is killed_piece
const MAX_ITERS := 100

func does_move_kill(start_pos: Vector2, end_pos: Vector2) -> bool:
	var piece_to_move = get_piece_from_grid_pos(start_pos)
	return does_pos_have_enemy(end_pos, piece_to_move)

# Performs null_check
static func is_king(piece):
	if piece != null:
		return piece.prefix == "K"
	return false

# The legal move is an array of 2 vectors.
# The start pos and end pos.
func generate_random_legal_moves(pieces: Array) -> Array:
	var legal_moves = []
	for piece in pieces:
		if !piece.is_dead:
			for legal_move in piece.generate_legal_moves():
				legal_moves.append([piece.grid_pos, legal_move])
	return select_random(legal_moves)

func get_best_move(mcts_node) -> Array:
	var best_chance = 0.0
	var best_move = []
	for child in mcts_node["children"].values():
		if child["total"] == 0:
			continue
		var chance = child["wins"]/child["total"]
		if chance > best_chance:
			best_chance = chance
			best_move = child["move"]
	return best_move

# Returns the best move in algebraic notation
func monte_carlo_search() -> Array:
	# DEBUG SUBSTITUTION
	var fake_board = self
	# var fake_board: Board = init_fake()
	
	var all_pieces = {true: [], false: []}
	var is_white_turn := self.is_white_turn
	
	for piece in fake_board.get_pieces():
		all_pieces[piece.is_white].append(piece)
	
	# STORE THE POSITIONS TEMPORARILY
	for piece in fake_board.get_pieces():
		piece.before_mcts_grid_pos = piece.grid_pos
	
	var mcts_tree = mcts_node.duplicate(true)
	var num_iters := 0
	while num_iters < MAX_ITERS:
		num_iters += 1
		var curr_node = mcts_tree
		
		# Repeated selection
		while len(curr_node["children"]) != 0:
			is_white_turn = !is_white_turn
			var target_pieces: Array = all_pieces[is_white_turn]
			var selected_move = fake_board.generate_random_legal_moves(target_pieces)
			if curr_node["children"].has(selected_move):
				curr_node = curr_node["children"][selected_move]
				fake_board.get_piece_from_grid_pos(selected_move[0]).place_on(selected_move[1])
			else:
				break
		
		# Rollout
		while !is_king(curr_node["killed"]):
			var target_pieces: Array = all_pieces[is_white_turn]
			var selected_move = fake_board.generate_random_legal_moves(target_pieces)
			var new_node = mcts_node.duplicate(true)
			new_node["parent"] = curr_node
			new_node["move"] = selected_move
			if fake_board.does_move_kill(selected_move[0], selected_move[1]):
				var killed_piece = fake_board.get_piece_from_grid_pos(selected_move[1])
				new_node["killed"] = killed_piece
				killed_piece.get_node("Sprite").modulate = Color(0.5, 0.5, 0.5, 0.5)
				killed_piece.is_dead = true
			
			fake_board.get_piece_from_grid_pos(selected_move[0]).place_on(selected_move[1])
			curr_node["children"][selected_move] = new_node
			curr_node = new_node
			is_white_turn = !is_white_turn
			
			# DEBUG
#			print(grid_pos_to_algebraic_pos(curr_node["move"][0]), \
#				grid_pos_to_algebraic_pos(curr_node["move"][1]))
#				yield(get_tree().create_timer(0.1), "timeout")
		
		# Back propogration
		var winner_is_target_color = curr_node["killed"].is_white == self.is_white_turn
		while curr_node["parent"] != null:
			curr_node["total"] += 1
			curr_node["wins"] += int(winner_is_target_color)
			curr_node = curr_node["parent"]
		curr_node["total"] += 1
		curr_node["wins"] += int(winner_is_target_color)
		
		# Reset pieces
		for set_of_pieces in all_pieces.values():
			for piece in set_of_pieces:
				piece.mcts_reset()
		# This needs to be done in 2 phases.
		# Otherwise if a piece is occupying the place of another piece.
		# It may set that tile to null after the original owner has arrived.
		for set_of_pieces in all_pieces.values():
			for piece in set_of_pieces:
				fake_board.set_through_grid_pos(piece.grid_pos, piece)
	
	return get_best_move(mcts_tree)
