class_name TWeaponObject
extends Node2D

enum AimMode {FIRST, LAST, CLOSE, FAR, WEAK, STRONG, RANDOM}
@export var aim_mode : AimMode = AimMode.FIRST

@export_placeholder("Tower Weapon") var weapon_name := ""
@export var projectile_scene: PackedScene

@export_group("TowerUpgrades", "upgrade_")


var base_damage: int = 1
var base_firerate: float = 1.0
var base_range: float = 4.0 : set = set_range

var projectiles_move_speed := 500.0

var heating_power: int = 0
var colding_power: int = 0

var current_target : EnemyObject
var _enemies_in_area := []
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
	if not vision_area.is_connected("area_entered", _on_vision_area_entered):
		vision_area.connect("area_entered", _on_vision_area_entered)
	if not vision_area.is_connected("area_exited", _on_vision_area_exited):
		vision_area.connect("area_exited", _on_vision_area_exited)
	
	vision_shape.shape = CircleShape2D.new()
	set_range(base_range)


func _process(delta) -> void:
	if _enemies_in_area.is_empty():
		return
	
	select_target()


func attack():
	pass


func select_target():
	if not current_target:
		if _enemies_in_area.is_empty():
			return
		
		set_target(_enemies_in_area[0])
		return
	
	match aim_mode:
		AimMode.FIRST:
			set_target(_enemies_in_area.front())
			
		AimMode.LAST:
			set_target(_enemies_in_area.back())
			
		AimMode.CLOSE:
			var closest_enemy = current_target
			for i in len(_enemies_in_area):
				if self.global_position.distance_to(_enemies_in_area[i].global_position) < self.global_position.distance_to(current_target.global_position):
					closest_enemy = _enemies_in_area[i]
			set_target(closest_enemy)
			
		AimMode.FAR:
			var farrest_enemy = current_target
			for i in len(_enemies_in_area):
				if self.global_position.distance_to(_enemies_in_area[i].global_position) > self.global_position.distance_to(current_target.global_position):
					farrest_enemy = _enemies_in_area[i]
			set_target(farrest_enemy)
			
		AimMode.WEAK:
			var weakest_enemy
			for i in len(_enemies_in_area):
				if _enemies_in_area[i].stat_hitpoints < current_target.stat_hitpoints:
					weakest_enemy = _enemies_in_area[i]
			set_target(weakest_enemy)
			
		AimMode.STRONG:
			var strongest_enemy
			for i in len(_enemies_in_area):
				if _enemies_in_area[i].stat_hitpoints > current_target.stat_hitpoints:
					strongest_enemy = _enemies_in_area[i]
			set_target(strongest_enemy)
			
		AimMode.RANDOM:
			set_target(_enemies_in_area.pick_random())


func set_target(new_target: EnemyObject):
	current_target = new_target


func get_target():
	return current_target


func get_main_texture():
	return sprite.texture


func set_range(value: float):
	base_range = value
	self.vision_shape.shape.radius = value * CellObject.CELL_SIZE.x
	

func set_stats(stats: Dictionary):
	for key in stats.keys():
		self.set(key, stats[key])


func _lost_target(enemy : EnemyObject): #Delete
	pass


func _create_projectile() -> MainProjectile:
	var projectile: MainProjectile
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
	var temperature_power = heating_power - colding_power
	if temperature_power > 0:
		enemy.increase_heat(temperature_power)
	
	elif temperature_power < 0:
		enemy.decrease_heat(temperature_power)


func _on_projectile_hited(enemy: EnemyObject, projectile: MainProjectile = null):
	if base_damage > 0:
		enemy.take_damage(base_damage)
	
	_apply_temperature_power(enemy)


func _on_projectile_disappeared(projectile: MainProjectile):
	var parent = projectile.get_parent()
	if parent:
		parent.remove_child(projectile)
	
	if _projectiles_pool.has(projectile):
		return
	
	_projectiles_pool.append(projectile)
#	print_debug("bullet added in pool [%s]" % Engine.get_process_frames())


func _on_vision_area_entered(area: Area2D) -> void:
	var enemy: EnemyObject = area.get_parent()
	if not enemy:
		return
	
	if not _enemies_in_area.has(enemy):
		_enemies_in_area.append(enemy)
	
	select_target()


func _on_vision_area_exited(area: Area2D) -> void:
	var enemy: EnemyObject = area.get_parent()
	if not enemy:
		return
	
	if _enemies_in_area.has(enemy):
		_enemies_in_area.erase(enemy)
	
	current_target = null
	select_target()
