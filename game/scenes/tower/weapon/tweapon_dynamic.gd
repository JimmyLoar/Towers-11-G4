class_name TWeaponDynamic
extends TWeaponObject

const MIN_ROTATE_STEP = deg_to_rad(0.025)

@export var rotate_max_speed = PI * 10

var following_target : Node2D
var target_enemy : EnemyObject
var visible_enemies := []


func _process(delta):
	if visible_enemies.is_empty():
		return
	
	if not target_enemy:
		found_target()
	
	sprite.look_at(target_enemy.get_wanted_position())
	if recharge_timer.is_stopped():
		attack()


func attack():
	var projectile := _create_projectile()
	_connect_projectile(projectile)
	if ammo_box.get_children().has(projectile):
		pass
	
	else:
		ammo_box.add_child(projectile)
	
	match weapon_type:
		WeaponType.BULLET:
			projectile.set_transform(sprite.get_transform())
			projectile.launch(1500)
		
		WeaponType.LASERBEAM:
			projectile.set_transform(sprite.get_transform())
			projectile.deploy(self.global_position.distance_to(target_enemy.position))
	
	recharge_timer.start(1 / stat_firerate)


func set_follow_target(new_follow: Node2D):
	following_target = new_follow
	if following_target:
		set_target(following_target.global_position)


func found_target():
	if visible_enemies.is_empty():
		return
	
	target_enemy = visible_enemies.front()


func lost_target():
	target_enemy = null


func _on_vision_area_area_entered(area: Area2D) -> void:
	var enemy: EnemyObject = area.get_parent()
	if not enemy:
		return
	
	if not visible_enemies.has(enemy):
		visible_enemies.append(enemy)
	
	found_target()


func _on_vision_area_area_exited(area: Area2D) -> void:
	var enemy: EnemyObject = area.get_parent()
	if not enemy:
		return
	
	if visible_enemies.has(enemy):
		visible_enemies.erase(enemy)
	
	lost_target()

