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
	
	var eval = evaluate_MM(1, max_depth, maximising)
	print("Minimax eval is " + str(eval))
	print(str(num_nodes_evaluated) + " nodes were evaluated")
	num_nodes_evaluated = 0
	
	FBP.queue_free()
	return eval

# Assumes that the move in the node has been applied and is the ccurent state of FBP
func evaluate_MM(curr_depth: int, max_depth: int, maximising: bool) -> Array:
	var evals_and_moves = []
	var eval: int
	var legal_moves = get_all_legal_moves(maximising)
	for legal_move in legal_moves:
		var killed_piece = FBP.pieces_grid.get(legal_move[1])
		var chance_of_success := 1.0
		var piece_to_move = FBP.pieces_grid[legal_move[0]]
		if killed_piece != null:
			killed_piece.die()
			chance_of_success = piece_to_move.odds_of_successful_attack(killed_piece)
		piece_to_move.place_on(legal_move[1])
		
		if curr_depth == max_depth:
			eval = chance_of_success * FBP.eval
			evals_and_moves.append([eval, [legal_move]])
		else:
			var eval_and_moves = evaluate_MM(curr_depth+1, max_depth, !maximising)
			eval_and_moves[1].append(legal_move)
			eval_and_moves[0] *= chance_of_success
			evals_and_moves.append(eval_and_moves)
		
		# Reset any moves made
		FBP.pieces_grid[legal_move[1]].place_on(legal_move[0])
		if killed_piece != null:
			killed_piece.revive()
	
	num_nodes_evaluated += len(legal_moves)
	var best_eval = get_best_eval(evals_and_moves, maximising)
	var best_evals_and_moves = get_best_evals_and_moves(evals_and_moves, best_eval)
	return RNG.select_random(best_evals_and_moves)

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
