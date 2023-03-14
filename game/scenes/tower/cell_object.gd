class_name CellObject
extends StaticBody2D

signal mouse_fucused(is_focus : bool)

const CELL_SIZE = Vector2.ONE * 60
const CELL_OFFSET = CELL_SIZE / 2
const CELL_DRAW_BORDER = Vector2.ONE * 2
const CELL_MODULATE = Color(1, 1, 1, 0.7)
const NEIBORNS_OFFSET = [
	Vector2.RIGHT, 
	Vector2.DOWN, 
	Vector2.LEFT, 
	Vector2.UP,
]
const CORNERS_OFFSET = [
	Vector2(-1, -1),
	Vector2(1, -1),
	Vector2(1, 1),
	Vector2(-1, 1),
]

@export_category("CellObject")

#@export_group("Ojbect", "object")
@export_placeholder("Name") var object_name: String = ""
@export_range(0, 100, 1, "or_greater") var build_prise = 100

@export_group("Textures", "textures_")
@export var main_icon : Texture
@export var structure : GridStructure

@export_group("Upgrades", "_upgrade")
@export var _upgrade_main: TowerUpgrade
@export var _upgrade_resources: Array[TowerUpgrade] = []
@export var _upgrade_structure: Array[String] = []
@export var _upgrade_level := String()

@export_group("Flags", "_flag")
@export var _flag_painting_cells: bool = false
@export var _flag_painting_outline: bool = false

var rotate_side: int = GridStructure.Side.RIGHT 
var center_offset := Vector2.ZERO

var _rotated_structure := PackedVector2Array()
var _outline_positions := PackedVector2Array()
var _disabled := false
var _outline_cache := []

@onready var shape = $Shape
@onready var sprite: Sprite2D = $Sprite


func _init() -> void:
	_outline_cache.resize(4)


func _ready():
	if not structure:
		printerr("Tower '%s' have not stucture" % self.name)
		return
	
	structure.current_side = rotate_side


func _process(_delta):
	pass


func _draw():
	if _flag_painting_cells:
		_draw_subcells()
		draw_circle(Vector2.ZERO, 16, Color.RED)
	
	if _flag_painting_outline:
		_draw_outline()


func _draw_subcells() -> void:
	var center = structure.get_center(rotate_side)
	for pos in structure.get_rotated_structure(rotate_side):
		var cell_pos = pos - center
		var rect_size = CELL_SIZE - CELL_DRAW_BORDER * 2
		var rect_position = cell_pos * CELL_SIZE - (CELL_OFFSET - CELL_DRAW_BORDER)
		draw_rect(Rect2(rect_position, rect_size), Color.WHITE * CELL_MODULATE)


func _draw_outline():
	var center := structure.get_center(rotate_side)
	var points = structure.get_outline(rotate_side)
	var offset = structure.get_center(rotate_side) * CELL_SIZE * -1 
	for ind in points.size() - 1:
		draw_line(points[ind] + offset, points[ind + 1] + offset, Color.BLUE, 8)


func get_icon() -> Texture:
	return main_icon


func get_cell_textures() -> Texture:
	return sprite.texture


func get_object_name() -> String:
	return tr(self.object_name)


func set_flag_pointing(flag: String, value: bool):
	match flag:
		"outline":
			_flag_painting_outline = value
		"cell":
			_flag_painting_cells = value
	self.queue_redraw()


func set_enable(_is: bool):
	self.visible = _is
	_disabled = not _is


func set_rotate_side(new_side: GridStructure.Side):
	rotate_side = new_side
	self.queue_redraw()
	call_deferred("_rotate_objects")
	call_deferred("update_collision_shape")


func update_collision_shape():
	shape.polygon = structure.get_outline(rotate_side)
	shape.position = -structure.get_center(rotate_side) * self.CELL_SIZE


func update_center_offset():
	var size = structure.get_size(rotate_side)
	center_offset.x = 0.5 if fmod(size.x, 2) == 0 else 0.0
	center_offset.y = 0.5 if fmod(size.y, 2) == 0 else 0.0
	center_offset = center_offset * CELL_SIZE


func get_global_structure() -> PackedVector2Array:
	var global_structure := PackedVector2Array()
	for pos in structure.get_rotated_structure(rotate_side):
		global_structure.append(get_cell_position() + pos)
	return global_structure


func get_rotated_structure() -> PackedVector2Array:
	return _rotated_structure


func get_global_rotated_structure() -> PackedVector2Array:
	var global_structure := PackedVector2Array()
	for pos in _rotated_structure:
		global_structure.append(get_cell_position() + pos)
	return global_structure 


func set_point_position(value: Vector2) -> void:
	self.position = round_position(value)


func get_point_position() -> Vector2:
	return self.position


func set_cell_position(cell_posision: Vector2):
	self.position = Vector2(cell_posision) * CELL_SIZE


func get_cell_position() -> Vector2:
	return self.convert_position_to_cell(self.position) - structure.get_center(rotate_side)


func get_global_cell_position():
	return convert_position_to_cell(self.global_position)


static func round_position(value: Vector2, is_mouse := false) -> Vector2:
	if is_mouse:
		value += CELL_OFFSET
	
	value = value.snapped(CELL_SIZE) - CELL_OFFSET 
	return value


static func convert_position_to_cell(convert_position: Vector2) -> Vector2:
	return (convert_position / CELL_SIZE).floor()


func get_upgrade_indexs(level: String = _upgrade_level) -> Array:
	var indexs := Array()
	
	for key in _upgrade_structure:
		if key.length() - 1 != level.length() or not key.begins_with(level):
			continue
		
		var index = _upgrade_structure.find(key)
		indexs.append(index)
	
	return indexs


func get_upgrade(index: int):
	if _upgrade_resources.is_empty():
		return _upgrade_main
	
	index = wrapi(index, 0, _upgrade_resources.size())
	return _upgrade_resources[index]


func get_currect_upgrade() -> TowerUpgrade:
	var index = _upgrade_structure.find(_upgrade_level)
	if index == -1:
		return _upgrade_main
	return _upgrade_resources[index]


func apply_upgrade(upgrade: TowerUpgrade):
	pass


func upgrade_selecte(ind: int):
	var index = self.get_upgrade_indexs()[ind]
	var upgrade = self.get_upgrade(index)
	self._upgrade_level = _upgrade_structure[index]
	self.apply_upgrade(upgrade)


func _rotate_objects():
	sprite.rotation_degrees = 90 * rotate_side


func _on_mouse_entered():
	call_deferred("emit_signal", "mouse_fucused", true)
	set_flag_pointing("outline", true)


func _on_mouse_exited():
	emit_signal("mouse_fucused", false)
	set_flag_pointing("outline", false)


func _on_vision_notifier_screen_entered():
	self.show()


func _on_vision_notifier_screen_exited():
	self.hide()


