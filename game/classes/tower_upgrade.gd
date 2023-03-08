class_name TowerUpgrade
extends Resource

@export_placeholder("UpgradeNameKey") var name := "Main"
@export_placeholder("UpgradeDiscriptionKey") var discription := ""
@export var weapon: PackedScene
@export var projectile: PackedScene
@export_range(0, 100, 1, "or_greater") var prise := 0

@export_group("Stats", "stat_")
@export_subgroup("Base", "stat_base_")
@export_range(0, 100, 1, "or_greater") var stat_base_damage: int = 1
@export_range(0, 16.0, 0.1, "or_greater") var stat_base_range: float = 1.0
@export_range(0.01, 10.0, 0.01, "or_greater") var stat_base_firerate: float = 1.0

@export_subgroup("Projectiles", "stat_projectiles")
@export_range(0.0, 5.0, 0.1, "or_greater") var stat_projectiles_timelife := 0.0
@export_range(0, 1500, 1, "or_greater") var stat_projectiles_move_speed := 1500 

@export_subgroup("Hitscan", "stat_hitscan")

@export_subgroup("Attribute", "stat_attribute")
@export_range(0, 100.0, 0.1, "or_greater") var stat_attribute_heating_power := 0.0
@export_range(0, 100.0, 0.1, "or_greater") var stat_attribute_colding_power := 0.0

@export_subgroup("Hitpoints", "stat_hitpoints")
@export_range(0, 100.0, 0.1, "or_greater") var stat_hitpoints_recovery := 0.0
@export_range(0, 100.0, 0.1, "or_greater") var stat_hitpoints_selffire := 0.0

@export_group("Other", "other_")
@export_flags_2d_physics var other_projectiles_layers := 88
@export_flags_2d_physics var other_hitscan_layers := 88


var _stat_dictionary: Dictionary #для сохранения данных, предотвразене лишних пересчетов одного и того-же


func get_stats() -> Dictionary:
	if not _stat_dictionary.is_empty():
		return _stat_dictionary
	
	for property in self.get_property_list():
		var stat_name : String = property.name
		if not stat_name.begins_with("stat_"):
			continue
		
		var stat_key = stat_name.trim_prefix("stat_")
		var value = self.get(stat_name)
		if value > 0.0:
			_stat_dictionary[stat_key] = value
	
	return _stat_dictionary


func get_current_stat(stat_name: String):
	var stats := self.get_stats()
	if stats.has(stat_name):
		return stats[stat_name]
	
	printerr("Upgrade '%s' | stat '%s' not exist\n Existed stats: %s" % [self.name, stat_name, stats.keys()])
	print_stack()
	return 0


