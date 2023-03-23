class_name UI
extends CanvasLayer

#TODO Переделать систему строительства

signal tower_builded(tower_index: int, tower_position: Vector2, rotate_side: int)
signal tower_distroed(tower_position: Vector2)

enum {MODE_BUILD, MODE_DESTROY}

@export_category("TowerBuilder")
@export var enable: bool = false : set=set_enable

var selected_tower_index : int = 0
var object_structure := []
var _posibility_build = true
var _is_destroy = false

@onready var background: ColorRect = $Background
@onready var tower_selecter: HBoxContainer = $TowerSelecter
@onready var _cursor: Node2D = $BuildCursor


func _ready():
	set_enable(enable)
	tower_selecter.init(GlobalData.towers_selected)


func _input(event: InputEvent) -> void:
	if not enable:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		set_enable(not enable)


func set_enable(new: bool):
	enable = new
#	tower_selecter.visible = not enable
	background.visible = enable
	_cursor.visible = enable
	_cursor.queue_redraw()
	Engine.time_scale = 0.05 if enable else 1
	EventBus.emit_signal("tower_mouse_focused", null, false)
	if not enable and is_destroy_mode():
		_is_destroy = false


func set_posibility_build(posibility: bool):
	_posibility_build = posibility
	_cursor.queue_redraw()


func is_destroy_mode():
	return _is_destroy


func _on_tower_selerter_tower_selected(_index: int) -> void:
	var structure : GridStructure
	set_enable(true)
	selected_tower_index = _index
	if selected_tower_index == -1:
		_is_destroy = true
		background.color = Color("ff91913c")
		_cursor.set_image_icon(null)
		structure = GridStructure.new()
	
	else:
		_is_destroy = false
		background.color = Color("68ceff3c")
		var tower : TowerBody = Towers.get_instanced_object(selected_tower_index)
		structure = tower.structure
		_cursor.set_image_icon(tower.get_icon())
	
	_cursor.set_structure(structure)


func _on_build_cursor_pressed(point_position: Vector2, rotate_side: int):
	var tower: TowerBody = Towers.get_instanced_object(selected_tower_index)
	if _posibility_build and GlobalData.has_resource_value(GlobalData.ResourcesType.MONEY, tower.get_upgrade().prise ):
		GlobalData.change_resource_value(GlobalData.ResourcesType.MONEY, - tower.get_upgrade().prise )
		emit_signal("tower_builded", selected_tower_index, point_position, rotate_side)
		


func _on_build_cursor_intersection_change(has_intersection) -> void:
	set_posibility_build(not has_intersection)



