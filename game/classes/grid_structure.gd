class_name GridStructure
extends Resource

enum Side{RIGHT, DOWN, LEFT, UP}
const GRID_LIMIT_SIZE = [1, 7]

@export var _main_structure := PackedVector2Array([Vector2i.ZERO]) : set = set_structure, get = get_structure

var current_side: Side = Side.RIGHT : set = set_rotate_side

var _rotated_structures: Array = Array()
var _outlines: Array = Array()

var _structure_size: Array = Array()
var _minimal_position: Array = Array()
var _maximal_position: Array = Array()


func _init() -> void:
	_rotated_structures.resize(4)
	_outlines.resize(4)
	_structure_size.resize(2)
	_minimal_position.resize(2)
	_maximal_position.resize(2)
	_update_rotations()
	_update_outlines()


#Setters
func set_rotate_side(value: int):
	current_side = wrapi(value, 0, 4)


func set_structure(new_structure: PackedVector2Array):
	_main_structure = new_structure
	_update_rotations()
	_update_outlines()


#Getters
func get_structure():
	return _main_structure


func get_center(side: Side = current_side, is_round := true) -> Vector2:
	var result = get_size(side) / 2
	if is_round:
		return result.floor()
	return result


func get_size(side: Side = current_side) -> Vector2:
	return _get_maximal_point(get_rotated_structure(side)) - _get_minimal_point(get_rotated_structure(side))


func get_rotated_structure(side: Side = current_side) -> PackedVector2Array:
	if _rotated_structures[side].is_empty():
		_rotated_structures[side] = _rotate(side)
	return _rotated_structures[side]


func get_outline(side: Side = current_side) -> PackedVector2Array:
	var outline: PackedVector2Array= _outlines[side]
	if outline is PackedVector2Array:
		return outline
	
	_outlines[side] = _count_ountile_positions(side)
	return _outlines[side]


#Functions


#Privet functions
func _test():
	pass


func _update_rotations():
	for side in Side.size():
		_rotated_structures[side] = _rotate(side)


func _rotate(side: Side):
	var rotated_structure := PackedVector2Array()
	for cell in _main_structure:
		var new_cell = cell.rotated(deg_to_rad(90) * side)
		rotated_structure.append(new_cell.round())
	
	var minimal = _get_minimal_point(rotated_structure)
	for ind in rotated_structure.size():
		var cell = rotated_structure[ind]
		rotated_structure[ind] = cell - minimal
	
	return rotated_structure


func _get_minimal_point(structure: PackedVector2Array) -> Vector2:
	var minimal = Vector2.ZERO
	for pos in structure:
		if pos.x < minimal.x:
			minimal.x = pos.x
		if pos.y < minimal.y:
			minimal.y = pos.y
	return minimal


func _get_maximal_point(structure: PackedVector2Array) -> Vector2:
	var maximal = Vector2.ZERO
	for pos in structure:
		if pos.x > maximal.x:
			maximal.x = pos.x
		if pos.y > maximal.y:
			maximal.y = pos.y
	return maximal + Vector2.ONE


func _update_outlines():
	for side in  Side.size():
		_outlines[side] = _count_ountile_positions(side)


func _count_ountile_positions(side: Side):
	var structure = get_rotated_structure(side)
	var array := _found_corners_positions(structure)
	array = Geometry2D.convex_hull(array)
	
	var _indexs := Array()
	var _positions := Array()
	
	for i in array.duplicate().size() - 1:
		var pos = array[i]
		var next_pos = array[i + 1]
		
		if pos.x == next_pos.x or pos.y == next_pos.y:
			continue
		
		var new_pos = _create_conver_position(pos, next_pos)
		if new_pos != pos and new_pos != next_pos:
			var index = array.find(pos)
			_indexs.append(index + 1)
			_positions.append(new_pos)
	
	_indexs.reverse()
	_positions.reverse()
	
	for index in _indexs.size():
		array.insert(_indexs[index], _positions[index])
	
	return PackedVector2Array(array)


func _found_corners_positions(structure: PackedVector2Array) -> PackedVector2Array:
	var array := Array()
	for cell_pos in structure:
		for corner_offset in GlobalData.CORNERS_OFFSET:
			var corner_pos: Vector2 = (cell_pos + corner_offset / 2) * GlobalData.CELL_SIZE
			corner_pos -= (Vector2.ONE * corner_offset * 4)
			array.append(corner_pos) 
			
	return PackedVector2Array(array)


func _create_conver_position(pos: Vector2, next_pos: Vector2) -> Vector2:
	var offset_pos = next_pos - pos
	var new_pos := Vector2.ZERO
	
	if (offset_pos.x >= 0 and offset_pos.y >= 0) or (offset_pos.x < 0 and offset_pos.y < 0):
		new_pos.x = pos.x
		new_pos.y = next_pos.y
	
	else:
		new_pos.x = next_pos.x
		new_pos.y = pos.y
	
	return new_pos


