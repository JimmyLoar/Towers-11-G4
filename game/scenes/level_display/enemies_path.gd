extends Path2D


func _ready() -> void:
	for child in self.get_children():
		_connect_enemy(child)


func create_enemy(index: int, wave: int):
	var enemy := Enemies.get_new_object(index)
	_connect_enemy(enemy)
	self.add_child(enemy)
	enemy.reset(wave)


func remove_enemy(index: int):
	var enemy := self.get_child(index)
	self.remove_child(enemy)
	if self.get_child_count() <= 0:
		get_parent()._on_end_wave()
	
	if index == -1:
		print_stack()
		breakpoint


func _connect_enemy(enemy: EnemyObject) -> void:
	if not enemy.is_connected("ended_path", _enemy_ended_path):
		enemy.connect("ended_path", _enemy_ended_path)
	
	if not enemy.is_connected("death", _enemy_death):
		enemy.connect("death", _enemy_death, CONNECT_ONE_SHOT)


func _enemy_ended_path(index: int):
	remove_enemy(index)


func _enemy_death(index: int):
	remove_enemy(index)
