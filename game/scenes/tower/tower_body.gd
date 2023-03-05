class_name TowerBody
extends CellObject

@export var main_weapon_scene: PackedScene 

var main_weapon : TWeaponObject

var current_weapon: TWeaponObject 


func _ready() -> void:
	_init_weapons()
	_rotate_objects()
	sprite.position -= self.center_offset


func swap_weapon():
	pass




func get_current_stat(stat_name: String): 
	#Незабыть удалить, после изменения в "res://game/scenes/defence/objects_manager.gd", 21 сторока
	return 0
	


func _init_weapons():
	main_weapon = _init_weapon(main_weapon_scene)
	main_weapon.position -= self.center_offset
	if not current_weapon:
		current_weapon = main_weapon
		self.add_child(current_weapon)


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

