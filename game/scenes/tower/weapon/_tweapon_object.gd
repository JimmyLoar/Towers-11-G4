class_name TWeaponObject
extends Node2D

enum WeaponType {BULLET, LASERBEAM}

@export var weapon_type : WeaponType = 0

@export_placeholder("Tower Weapon") var weapon_name := ""
@export var projectile_scene : PackedScene

@export_group("TowerUpgrades", "upgrade_")

@export_group("WeaponStats", "stat_")
@export_range(0, 1024, 1, "or_greater") var stat_base_damage: int = 1
@export_range(0.0, 100.0, 0.01) var stat_firerate: float = 1.0
@export_range(0.0, 16.0, 0.1, "or_greater") var stat_vision_range: float = 4.0

@export_range(0, 256, 1, "or_greater") var stat_heating_power: int = 0
@export_range(0, 256, 1, "or_greater") var stat_colding_power: int = 0

var target_position := Vector2()

var _projectiles_pool := Array()

@onready var sprite: Sprite2D = $Sprite
@onready var vision_area: Area2D = $VisionArea
@onready var vision_shape: CollisionShape2D = $VisionArea/Collision
@onready var ammo_box: Node2D = $AmmoBox
@onready var recharge_timer: Timer = $RechargeTimer



func _init():
	self.name = "Weapon"
	self.position = Vector2.ZERO


func _ready() -> void:
	if vision_shape.shape is CircleShape2D:
		vision_shape.shape.radius = stat_vision_range * GlobalData.CELL_SIZE.x


func get_main_texture():
	return sprite.texture


func set_target(new_target: Vector2):
	target_position = new_target


func get_target():
	return target_position


func attack():
	pass


func _found_target():
	pass


func _lost_target():
	pass


func _create_projectile() -> MainProjectile:
	var projectile : MainProjectile
#	print("pool size is %s (is empty %s) [%s]" % [_projectiles_pool.size(), _projectiles_pool.is_empty(), Engine.get_process_frames()])
	if _projectiles_pool.is_empty():
#		print_debug("create new bullet [%s]" % Engine.get_process_frames())
		projectile = projectile_scene.instantiate()
	
	else:
#		print_debug("get bullet in pool [%s]" % Engine.get_process_frames())
		projectile = _projectiles_pool.pop_front()
	
	return projectile.reset()


func _connect_projectile(projectile: MainProjectile):
	if not projectile.is_connected("hited", _on_projectile_hited):
		projectile.connect("hited", _on_projectile_hited)
	
	if not projectile.is_connected("disappeared", _on_projectile_disappeared):
		projectile.connect("disappeared", _on_projectile_disappeared)


func _apply_temperature_power(enemy: EnemyObject):
	var temperature_power = stat_heating_power - stat_colding_power
	if temperature_power > 0:
		enemy.increase_heat(temperature_power)
	
	elif temperature_power < 0:
		enemy.decrease_heat(temperature_power)


func _on_projectile_hited(enemy: EnemyObject, projectile: MainProjectile = null):
	if stat_base_damage > 0:
		enemy.take_damage(stat_base_damage)
	
	_apply_temperature_power(enemy)


func _on_projectile_disappeared(projectile: MainProjectile):
	var parent = projectile.get_parent()
	if parent:
		parent.remove_child(projectile)
	
	if _projectiles_pool.has(projectile):
		return
	
	_projectiles_pool.append(projectile)
#	print_debug("bullet added in pool [%s]" % Engine.get_process_frames())
