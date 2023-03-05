class_name TWeaponDynamic
extends TWeaponObject

const MIN_ROTATE_STEP = deg_to_rad(0.025)

@export var rotate_max_speed = PI * 10


func _ready():
	pass


func _process(delta):
	if _enemies_in_area.is_empty():
		return
	
	select_target()
	
	print(_enemies_in_area)
	print(current_target, 1)
	sprite.look_at(current_target.get_wanted_position())
	if recharge_timer.is_stopped():
		attack()


func attack():
	var projectile := _create_projectile()
	_connect_projectile(projectile)
	if ammo_box.get_children().has(projectile):
		pass
		
	else:
		ammo_box.add_child(projectile)
		
		projectile.set_transform(sprite.get_transform())
		projectile.launch(1500)
		
	recharge_timer.start(1 / stat_firerate)

