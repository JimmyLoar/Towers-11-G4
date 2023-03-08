class_name TowerBody
extends CellObject

var current_weapon: TWeaponObject 


func _ready() -> void:
	_rotate_objects()
	apply_upgrade(_upgrade_main)
	sprite.position -= self.center_offset


func swap_weapon():
	pass


func get_current_stat(stat_name: String): 
	#Незабыть удалить, после изменения в "res://game/scenes/defence/objects_manager.gd", 21 сторока
	return 0


func apply_upgrade(upgrade: TowerUpgrade):
	if not upgrade:
		printerr("Tower %s | can not apply upgrade, upgrade not exist")
		print_stack()
		print()
		return
	
	if upgrade.weapon:
		if current_weapon:
			self.remove_child(current_weapon)
		
		current_weapon = upgrade.weapon.instantiate()
		self.add_child(current_weapon)
	
	var stats = upgrade.get_stats()
	current_weapon.set_stats(stats)
	
	




func _init_weapon(_scene: PackedScene) -> TWeaponObject:
	if not _scene:
		print("TowerBody | tower %s have not weapon" % self.get_object_name())
		breakpoint
		return null
	
	var new_weapon = _scene.instantiate()
	if not new_weapon is TWeaponObject:
		printerr(" TowerBody | Tower %s not install new_weapon weapon %s" % [self.object_name, new_weapon.name] )
		return null
	return new_weapon


func _rotate_objects():
	var degrees = 90 * rotate_side
	if current_weapon:
		current_weapon.rotation_degrees = degrees
	
	sprite.rotation_degrees = degrees


