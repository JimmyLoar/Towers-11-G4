class_name ProjectileBullet
extends MainProjectile

enum Env{AIR, METAL}

const  MAXIMAL_MOVING_SPEED := 3840

var moving_speed := 0.0
var velocity := Vector2()
var penetration: int = 3
var _reaming_penetration = penetration

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var collision_shape: CollisionShape2D = $HitArea/CollisionShape2D

func _ready() -> void:
	reset()
	self.visible = true


func _physics_process(delta: float) -> void:
	velocity = min(moving_speed, MAXIMAL_MOVING_SPEED) * self.transform.x 
	self.position += velocity * delta
	
	if moving_speed <= 0:
		_disappear()

	else:
		moving_speed -= delta * 10


func launch(strength: int):
	moving_speed = strength


func _reset() -> void:
	sprite.visible = true
	collision_shape.disabled = false


func _on_hit_area_area_entered(area: Area2D) -> void:
	var enemy : EnemyObject = area.get_parent()
	sprite.visible = false
	moving_speed = 0
	emit_signal("hited", enemy, self)
	call_deferred("_disappear")
	collision_shape.set_deferred("disabled", true)



func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	self.visible = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	self.visible = false
	_disappear()
