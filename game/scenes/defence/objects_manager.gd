extends Node2D

var _occupied_cells := {}


var _towers := Array()
var _active := Array()
var _other := Array()



var focused_tower : TowerBody
var is_focused := false


func _draw() -> void:
	if not is_focused:
		return
	
	var pos = focused_tower.current_weapon.global_position
	var vision_range = focused_tower.get_current_stat("vision_range") * CellObject.CELL_SIZE.x
	var color = Color.WHITE_SMOKE
	color.a = 0.25
	draw_circle(pos, vision_range, color)
	color.a *= 2
	draw_arc(pos, vision_range, 0, 2 * PI, 36, color, 4)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click"):
		EventBus.emit_signal("tower_mouse_focused", focused_tower, is_focused)


func build_tower(tower_index, tower_position, side) -> TowerBody:
	var tower : TowerBody = Towers.get_new_object(tower_index)
	tower.call("set_position", tower_position)
	tower.set_rotate_side(side)
	tower.update_center_offset()
	if not tower.is_connected("mouse_fucused", _on_tower_focused.bind(tower)):
		tower.connect("mouse_fucused", _on_tower_focused.bind(tower))
	self.add_child(tower)
	_towers.append(tower)
	return tower


func destroy_tower(tower: CellObject) -> void:
	self.remove_child(tower)
	_towers.erase(tower)


func add_occupied_cell_object(cell_object: CellObject):
	for offset in cell_object.get_rotated_structure():
		var subcell_position = cell_object.get_cell_position() + offset
		_occupied_cells[subcell_position] = cell_object


func add_occupied_cells_array(pos_array: PackedVector2Array):
	var ind = _other.size()
	_other.append(pos_array)
	for cell in pos_array:
		_occupied_cells[cell] = ind
	return ind


func remove_occupied_cells_object(cell_object: CellObject):
	var _position = cell_object.get_cell_position()
	for offset in cell_object.get_rotated_structure():
		var subcell_position = _position + offset
		_occupied_cells.erase(subcell_position)


func remove_occupied_cells_array(array_ind: int):
	if array_ind < 0 or array_ind >= _other.size():
		printerr("ObjectsManager | remove_occupied_cells_array | not exist index (%s) in arrays list (%s)" % [array_ind, _other.size()])
		print_stack()
		breakpoint
	
	var removed_array = _other.pop_at(array_ind)
	for pos in removed_array:
		_occupied_cells.erase(pos)


func has_occupied_cell(cell_pos) -> bool:
	return _occupied_cells.has(cell_pos)


func get_occupied_object(pos: Vector2):
	var cell = _occupied_cells[pos]
	if cell is CellObject:
		return cell
	return null


func _create_active_object():
	pass


func _destroy_active_object():
	pass


func _on_tower_focused(focus: bool, tower: TowerBody):
	focused_tower = tower
	is_focused = focus
	queue_redraw()
