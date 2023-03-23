class_name MainProjectile
extends Node

signal hited(enemy: EnemyObject, projectile: MainProjectile)
signal disappeared(projectile: MainProjectile)

@export_range(0.0, 5.0, 0.01, "or_greater") var timelife: float = 0.0


func set_transform(new_transform: Transform2D):
	self.transform = new_transform


func reset():
	self.set_process(true)
	self.set_physics_process(true)
	self.visible = true
	self.call_deferred("_reset")
	if timelife > 0.0:
		self.call_deferred("_connect_timer")
	return self


func _connect_timer():
	get_tree().create_timer(timelife).timeout.connect(_disappear)


func _disappear():
	self.visible = false
	self.set_process(false)
	self.set_physics_process(false)
	emit_signal("disappeared", self)

