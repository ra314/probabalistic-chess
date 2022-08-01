extends Node2D
class_name BoardAI

var B: Board
var BP: BoardPieces
var FBP: BoardPieces

# Called when the node enters the scene tree for the first time.
func _ready():
	B = get_parent()
	BP = get_parent().get_node("Pieces")

func get_all_legal_moves(color: bool):
	var legal_moves = []
	for piece in FBP.all_pieces[color].keys():
		for legal_move in piece.generate_legal_moves():
			legal_moves.append([piece.grid_pos, legal_move])
	return legal_moves

func order_moves_sorter_helper(move1, move2) -> bool:
	return move_eval_guesses[move1] > move_eval_guesses[move2]

var move_eval_guesses := {}

# Pass in a duplicated array if you don't want the original array to mutate
# Moves that are heuristically evaluated to be better are at the start of the returned array
func order_moves(moves: Array) -> Array:
	move_eval_guesses = {}
	for move in moves:
		var eval = 0
		
		# Reward captures
		var killed_piece = FBP.pieces_grid.get(move[1])
		if killed_piece != null:
			var piece_to_move = FBP.pieces_grid[move[0]]
			var chance_of_success = piece_to_move.odds_of_successful_attack(killed_piece)
			eval += (killed_piece.eval_value * chance_of_success)
		
		move_eval_guesses[move] = eval
	
	moves.sort_custom(self, "order_moves_sorter_helper")
	return moves

var mm_node = {"move": null, "eval": 0}

var num_nodes_evaluated = 0
func evaluate_MM_root(max_depth: int, maximising: bool) -> Array:
	FBP = BP.duplicate()
	BP.duplicate_board(FBP)
	
	var eval = evaluate_MM4(max_depth, maximising, -INF, +INF)
	debug_print_eval_and_moves(eval)
	print(str(num_nodes_evaluated) + " nodes were evaluated at a depth of " + str(max_depth))
	num_nodes_evaluated = 0
	
	FBP.queue_free()
	return eval

func evaluate_MM4(depth: int, maximising: bool, alpha: float, beta: float) -> Array:
	num_nodes_evaluated += 1
	
	if depth == 0:
		return [FBP.eval, []]
	
	var best_eval
	if maximising:
		best_eval = -INF
	else:
		best_eval = INF
	var best_moves = null
	
	for legal_move in order_moves(get_all_legal_moves(maximising)):
		# Playing the proposed move
		var killed_piece = FBP.pieces_grid.get(legal_move[1])
		var chance_of_success := 1.0
		var piece_to_move = FBP.pieces_grid[legal_move[0]]
		if killed_piece != null:
			killed_piece.die()
			chance_of_success = piece_to_move.odds_of_successful_attack(killed_piece)
		piece_to_move.place_on(legal_move[1])
		
		# Evaluation
		var eval_and_moves = evaluate_MM4(depth-1, !maximising, alpha, beta)
		var eval = eval_and_moves[0]
		var moves = eval_and_moves[1]
		
		# TODO
		# Counter the eval given a capture
		# with the eval given that the current play makes not move due to a failed capture
		
		# Updating alpha, beta
		if maximising:
			alpha = max(alpha, eval)
		else:
			beta = min(beta, eval)
		
		# Reset any moves made
		FBP.pieces_grid[legal_move[1]].place_on(legal_move[0])
		if killed_piece != null:
			killed_piece.revive()
		
		# Stop evaluation since the opponent won't pick this branch
		if maximising:
			if eval >= beta:
				return [INF, null]
		else:
			if eval <= alpha:
				return [-INF, null]
		
		if (maximising and (eval > best_eval)) or (!maximising and (eval < best_eval)):
				best_eval = eval
				moves.append(legal_move)
				best_moves = moves
	
	return [best_eval, best_moves]

func debug_print_move(move):
	var print_str = ""
	print_str += BoardUtils.grid_pos_to_algebraic_pos(move[0])
	print_str += "->"
	print_str += BoardUtils.grid_pos_to_algebraic_pos(move[1])
	print_str += " "
	return print_str

func debug_print_eval_and_moves(eval_and_moves):
	var print_str = ""
	print_str += str(eval_and_moves[0]) + ": "
	for move in eval_and_moves[1]:
		print_str += debug_print_move(move)
	print(print_str)
