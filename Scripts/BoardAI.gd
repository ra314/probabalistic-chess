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

var mm_node = {"move": null, "eval": 0}

var num_nodes_evaluated = 0
func evaluate_MM_root(max_depth: int, maximising: bool) -> Array:
	FBP = BP.duplicate()
	BP.duplicate_board(FBP)
	
	#var eval = evaluate_MM(1, max_depth, maximising, -INF, +INF)
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
	
	for legal_move in get_all_legal_moves(maximising):
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

func evaluate_MM3(depth: int, maximising: bool, alpha: float, beta: float) -> Array:
	num_nodes_evaluated += 1
	
	if depth == 0:
		return [FBP.eval, null]
	
	var alpha_moves = null
	for legal_move in get_all_legal_moves(maximising):
		# Playing the proposed move
		var killed_piece = FBP.pieces_grid.get(legal_move[1])
		var chance_of_success := 1.0
		var piece_to_move = FBP.pieces_grid[legal_move[0]]
		if killed_piece != null:
			killed_piece.die()
			chance_of_success = piece_to_move.odds_of_successful_attack(killed_piece)
		piece_to_move.place_on(legal_move[1])
		
		#print(debug_print_move(legal_move))
		if legal_move[0] == Vector2(7,3):
			if legal_move[1] == Vector2(4,0):
				pass
				#print("Killed")
		
		var eval_and_moves = evaluate_MM3(depth-1, !maximising, alpha, beta)
		var eval = eval_and_moves[0]
		var moves = eval_and_moves[1]
		
		# Reset any moves made
		FBP.pieces_grid[legal_move[1]].place_on(legal_move[0])
		if killed_piece != null:
			killed_piece.revive()
		
		# Pruning
		if (eval >= beta):
			print("")
			return [beta, null]
		if eval > alpha:
			alpha = eval
			if moves == null:
				alpha_moves = []
			else:
				alpha_moves = moves
			alpha_moves.append(legal_move)
	
	#print("alpha: " + str(alpha))
	return [alpha, alpha_moves]

func evaluate_MM2(depth: int, maximising: bool, alpha: float, beta: float) -> Array:
	if depth == 0:
		return [FBP.eval, []]
	
	var eval_and_moves
	if maximising:
		eval_and_moves = [-INF]
	else:
		eval_and_moves = [INF]
	
	for legal_move in get_all_legal_moves(maximising):
		# Playing the proposed move
		var killed_piece = FBP.pieces_grid.get(legal_move[1])
		var chance_of_success := 1.0
		var piece_to_move = FBP.pieces_grid[legal_move[0]]
		if killed_piece != null:
			killed_piece.die()
			chance_of_success = piece_to_move.odds_of_successful_attack(killed_piece)
		piece_to_move.place_on(legal_move[1])
		
		# Deepening
		var new_eval_and_moves = evaluate_MM2(depth-1, alpha, beta, !maximising)
		new_eval_and_moves[1].append(legal_move)
		num_nodes_evaluated += 1
		
		# Reset any moves made
		FBP.pieces_grid[legal_move[1]].place_on(legal_move[0])
		if killed_piece != null:
			killed_piece.revive()
		
		# Pruning
		if maximising:
			if eval_and_moves[0] < new_eval_and_moves[0]:
				eval_and_moves = new_eval_and_moves
			if eval_and_moves[0] >= beta:
				break
			alpha = max(alpha, eval_and_moves[0])
		else:
			if eval_and_moves[0] > new_eval_and_moves[0]:
				eval_and_moves = new_eval_and_moves
			if eval_and_moves[0] <= alpha:
				break
			beta = min(beta, eval_and_moves[0])
		
	return eval_and_moves

# Assumes that the move in the node has been applied and is the ccurent state of FBP
func evaluate_MM(curr_depth: int, max_depth: int, maximising: bool, alpha: float, beta: float) -> Array:
	var evals_and_moves = []
	var eval: int
	var legal_moves = get_all_legal_moves(maximising)
	var eval_if_kill_fails : float
	if maximising:
		evals_and_moves.append([-INF])
	else:
		evals_and_moves.append([INF])
	
	if curr_depth == max_depth:
		eval_if_kill_fails = FBP.eval
	else:
		eval_if_kill_fails = evaluate_MM(curr_depth+1, max_depth, !maximising, alpha, beta)[0]
	
	for legal_move in legal_moves:
		var killed_piece = FBP.pieces_grid.get(legal_move[1])
		var chance_of_success := 1.0
		var piece_to_move = FBP.pieces_grid[legal_move[0]]
		
		
		if killed_piece != null:
			killed_piece.die()
			chance_of_success = piece_to_move.odds_of_successful_attack(killed_piece)
		piece_to_move.place_on(legal_move[1])
		
		var pruned = false
		if curr_depth == max_depth:
			eval = (chance_of_success * FBP.eval) + ((1-chance_of_success) * eval_if_kill_fails)
			evals_and_moves.append([eval, [legal_move]])
		else:
			var eval_and_moves = evaluate_MM(curr_depth+1, max_depth, !maximising, alpha, beta)
			if len(eval_and_moves) == 1:
				pruned = true
			else:
				eval_and_moves[1].append(legal_move)
				eval_and_moves[0] = (chance_of_success * eval_and_moves[0]) + ((1-chance_of_success) * eval_if_kill_fails)
				evals_and_moves.append(eval_and_moves)
		
		# Reset any moves made
		FBP.pieces_grid[legal_move[1]].place_on(legal_move[0])
		if killed_piece != null:
			killed_piece.revive()
		
		if pruned:
			continue
		
		var latest_eval = evals_and_moves[len(evals_and_moves)-1][0]
		if maximising:
			if latest_eval >= beta:
				return [latest_eval]
				break
			alpha = max(alpha, latest_eval)
		else:
			if latest_eval <= alpha:
				return [latest_eval]
				break
			beta = min(beta, latest_eval)
	
	num_nodes_evaluated += len(legal_moves)
	var best_eval = get_best_eval(evals_and_moves, maximising)
	var best_evals_and_moves = get_best_evals_and_moves(evals_and_moves, best_eval)
	
	if curr_depth == 1:
		for eval_and_moves in best_evals_and_moves:
			debug_print_eval_and_moves(eval_and_moves)
	return RNG.select_random(best_evals_and_moves)

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
	print_str += "\n"
	print(print_str)

func get_best_eval(evals_and_moves: Array, maximising: bool) -> float:
	var best_eval
	var eval
	if maximising: 
		best_eval = -INF
		for eval_and_moves in evals_and_moves:
			eval = eval_and_moves[0]
			if eval > best_eval:
				best_eval = eval
	else:
		best_eval = INF
		for eval_and_moves in evals_and_moves:
			eval = eval_and_moves[0]
			if eval < best_eval:
				best_eval = eval
	return best_eval

func get_best_evals_and_moves(evals_and_moves: Array, best_eval: float) -> Array:
	var best_evals_and_moves = []
	for eval_and_moves in evals_and_moves:
		if eval_and_moves[0] == best_eval:
			best_evals_and_moves.append(eval_and_moves)
	return best_evals_and_moves
