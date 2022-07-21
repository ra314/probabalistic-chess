### ALL UTILS MUST BE STATIC
class_name BoardUtils

const BOARD_SIZE = 8

static func initialize_empty_grid() -> Array:
	var grid = []
	for x in range(BOARD_SIZE):
		grid.append([])
		for _y in range(BOARD_SIZE):
			grid[x].append(null)
	return grid

static func algebraic_pos_to_grid_pos(pos: String) -> Vector2:
	assert(len(pos)==2)
	assert(pos[1].is_valid_integer())
	
	var new_pos := Vector2()
	new_pos.x = ord(pos.to_lower()[0])-ord('a')
	new_pos.y = BOARD_SIZE - int(pos[1])
	return new_pos

static func grid_pos_to_algebraic_pos(pos: Vector2) -> String:
	return char(pos.x+ord('a')) + str(BOARD_SIZE - int(pos.y))

static func is_in_grid(pos: Vector2) -> bool:
	for num in [pos.x, pos.y]:
		if num<0 or num>=BOARD_SIZE:
			return false
	return true
