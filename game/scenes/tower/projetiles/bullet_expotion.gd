class_name ProjectileBulleExpotion
extends ProjectileBullet

signal explotion_hited(hited_object: EnemyObject)

const TIMELIFE = 0.4

var tween_explotion: Tween

@onready var explotion_area: Area2D = $ExplotionArea
@onready var explotion_shape: CollisionShape2D = $ExplotionArea/ExplotionShape
@onready var explotion_particles: GPUParticles2D = $ExplotionParticles


func _ready() -> void:
	self.visible = true
	explotion_shape.shape = CircleShape2D.new()
	launch(100)


func set_exporation_range(range_value: int):
	explotion_shape.shape.radius = range_value


func explotion(range = 10):
	set_exporation_range(range)
	explotion_shape.set_deferred("disabled", false)
	explotion_particles.visible = true
	explotion_particles.restart()
	get_tree().create_timer(TIMELIFE).timeout.connect(_disappear)


func _reset():
	if tween_explotion:
		tween_explotion.kill()
	
	explotion_particles.lifetime = TIMELIFE
	explotion_particles.visible = false #Костыль - НЕ ТРОГАТЬ!
	
	set_physics_process(true)
	sprite.visible = true
	collision_shape.disabled = false
	explotion_shape.disabled = true


func _on_hit_area_area_entered(area: Area2D) -> void:
	var enemy : EnemyObject = area.get_parent()
	sprite.visible = false
	self.set_physics_process(false)
	moving_speed = 0
	emit_signal("hited", enemy)
	explotion(100)


func _on_explotion_area_area_entered(area: Area2D) -> void:
	var enemy : EnemyObject = area.get_parent()
	emit_signal("hited", enemy)



