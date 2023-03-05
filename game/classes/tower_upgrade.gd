class_name TowerUpgrade
extends Resource

@export_placeholder("UpgradeNameKey") var name := "Main"
@export_placeholder("UpgradeDiscriptionKey") var discription := ""
@export var weapon: PackedScene

@export_group("Stats", "stat_")
@export_subgroup("Base", "stat_base_")
@export_range(0, 100, 1, "or_greater") var stat_base_damage: int = 1
@export_range(0, 16.0, 0.1, "or_greater") var stat_base_range: float = 1.0
@export_range(0, 100, 1, "or_greater") var stat_base_firerate: float = 1.0

@export_subgroup("Projectiles", "stat_projectiles")


var _stat_dictionary := Dictionary() #для сохранения данных, предотвразене лишних пересчетов одного и того-же


func get_stats() -> Dictionary:
	if not _stat_dictionary.is_empty():
		return _stat_dictionary
	
	var _stat_dictionary := Dictionary()
	for property in self.get_property_list():
		var stat_name : String = property.name
		if not "stat_" in stat_name:
			continue
		var stat_key = stat_name.trim_prefix("stat_")
		_stat_dictionary[stat_key] = self.get(stat_name)
	
	return _stat_dictionary


func get_current_stat(stat_name: String):
	var stats := self.get_stats()
	if stats.has(stat_name):
		return stats[stat_name]
	
	printerr("Upgrade '%s' | stat '%s' not exist\n Existed stats: %s" % [self.name, stat_name, stats.keys()])
	print_stack()
	return 0
