extends Node2D

var level : LevelDisplay

var active_object = load("res://game/scenes/tower/cell_object.tscn").instantiate()
var last_tower_index := -1
var last_rotate_side := 0
var focus_tower : CellObject

@onready var ui: CanvasLayer = $UI
@onready var objects_manager: Node2D = $ObjectsManager


func  _init() -> void:
	LoadingScreen.add_task("init_defence_scene")
	LoadingScreen.open()


func _ready() -> void:
	self.add_child(active_object)
	active_object.modulate = Color(1, 1, 1, 0)
	init_level()
	GlobalData.set_resource_value(GlobalData.ResourcesType.PLAYER_LIFE, 25)


func init_level():
	level = Levels.get_instanced_object(0)
	self.add_child(level)
	self.move_child(level, 0)
	LoadingScreen.remove_task("init_defence_scene")
	objects_manager.add_occupied_cells_array(level.call("get_cells_at_layer", 1))
	objects_manager.add_occupied_cells_array(level.get_cells_at_layer(2))


func _on_ui_tower_builded(tower_index, tower_position, side) -> void:
	var _tower = objects_manager.build_tower(tower_index, tower_position, side)


func _on_ui_tower_distroed(tower_position: Vector2) -> void:
	var cell_pos = CellObject.convert_position_to_cell(tower_position)
	if not objects_manager.has_occupied_cell(cell_pos):
		return
	
	ui.set_posibility_build(true)
	var tower = objects_manager.get_occupied_object(cell_pos)
	if tower is CellObject:
		objects_manager.destroy_tower(tower)
	
	focus_tower = null
	active_object.set_structure(PackedVector2Array([Vector2.ZERO]))


func _update_active_object(tower_index: int, new_pos: Vector2):
	if last_tower_index != tower_index:
		if ui.is_destroy_mode():
			active_object.set_structure(PackedVector2Array([Vector2.ZERO]))
			active_object.set_position(new_pos)
	
		else:
			var tower: TowerBody = Towers.get_instanced_object(tower_index)
			active_object.set_structure(tower.get_structure())
			active_object.set_position(new_pos)

