extends VBoxContainer

var _display_pool = Array()

var stat_display_scene = preload("res://game/scenes/defence/ui/tower_information/stat_display.tscn")

@onready var main: VBoxContainer = $Main


func add_group():
	pass


func remove_group():
	pass


func add_display():
	pass


func remove_display():
	pass


func update_display():
	pass


func _get_new_display():
	if not _display_pool.is_empty():
		return _display_pool.pop_front()
	var new_display = stat_display_scene.instantiate()
	return new_display

