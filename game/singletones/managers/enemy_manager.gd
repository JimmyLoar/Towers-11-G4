extends ObjectsManager


func _init_paths_to_load():
	self._class_type = "enemies"
	_paths_to_load = [
		"res://game/database/enemies/000_test.tscn",
	]
