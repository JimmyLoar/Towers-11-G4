extends ObjectsManager



func _init_paths_to_load():
	self._class_type = "towers"
	_paths_to_load = [
		"res://game/database/towers/000_test.tscn",
		"res://game/database/towers/001_test_2.tscn",
	]
