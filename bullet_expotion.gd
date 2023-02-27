class_name ProjectileBulleExpotion
extends ProjectileBullet

signal explotion_hited(hited_object: EnemyObject)

const TIMELIFE = 0.2

var tween_explotion: Tween

@onready var explotion_area: Area2D = $ExplotionArea
@onready var explotion_shape: CollisionShape2D = $ExplotionArea/ExplotionShape


func _ready() -> void:
	self.visible = true
	explotion_shape.shape = CircleShape2D.new()
	explotion_shape.shape.radius = 100
	launch(100)


func set_exporation_range(range_value: int):
	explotion_shape.shape.radius = range_value


func explotion(range = 10):
	explotion_shape.set_deferred("disabled", false)
	get_tree().create_timer(TIMELIFE).timeout.connect(_disappear)


func _reset():
	if tween_explotion:
		tween_explotion.kill()
	
	set_physics_process(true)
	sprite.visible = true
	collision_shape.disabled = false
	explotion_shape.disabled = true


func _on_hit_area_area_entered(area: Area2D) -> void:
	var enemy : EnemyObject = area.get_parent()
#	sprite.visible = false
	self.set_physics_process(false)
	moving_speed = 0
	explotion(100)
	print("Explotion hitted")


func _on_explotion_area_area_entered(area: Area2D) -> void:
	var enemy : EnemyObject = area.get_parent()
	print("Explotion explotion")
	emit_signal("hited", enemy)



