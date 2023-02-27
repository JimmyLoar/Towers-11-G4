class_name MainProjectile
extends Node

signal hited(enemy: EnemyObject, projectile: MainProjectile)
signal disappeared(projectile: MainProjectile)


func set_transform(new_transform: Transform2D):
	self.transform = new_transform


func reset():
	self.set_process(true)
	self.set_physics_process(true)
	self.visible = true
	self.call_deferred("_reset")
	return self


func _disappear():
	self.set_process(false)
	self.set_physics_process(false)
	self.visible = false
	emit_signal("disappeared", self)
	print_stack()

