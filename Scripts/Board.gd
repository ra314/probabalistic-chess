extends Node2D
class_name Board


var rng = RandomNumberGenerator.new()
var is_white_turn := true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Pieces.init()
	$Visuals.init()
	$Button.connect("button_up", self, "get_ai_suggestion")
	rng.randomize()

func get_ai_suggestion():
	var move = monte_carlo_search()
	$Visuals.click_grid_pos(move[0])
	yield(get_tree().create_timer(1), "timeout")
	$Visuals.click_grid_pos(move[1])

var BOARD := load("res://Scenes/Board.tscn")
func init_fake() -> Board:
	var fake_board = BOARD.instance()
	fake_board.pieces_grid = BoardUtils.initialize_empty_grid()
	for piece in $Pieces.get_pieces():
		var new_piece = $Pieces.letter_to_piece[piece.prefix].instance()\
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
	var piece_to_move = $Pieces.get_piece_from_grid_pos(start_pos)
	return $Pieces.does_pos_have_enemy(end_pos, piece_to_move)

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
