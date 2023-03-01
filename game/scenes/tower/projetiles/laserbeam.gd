class_name LaserBeam
extends MainProjectile

@export_range(1, ) var beam_wight := 5

var tween: Tween

@onready var sprite_line : Line2D = $Line2D
@onready var hitbox_area : Area2D = $Area2D
@onready var hitbox_shape : CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	hitbox_area.area_entered.connect(_hit)


func deploy(enemy_distance : float) -> void:
	sprite_line.set_point_position(0, Vector2.ZERO)
	sprite_line.set_point_position(1, Vector2(enemy_distance, 0))
	hitbox_shape.shape.a = Vector2.ZERO
	hitbox_shape.shape.b = Vector2(0, -enemy_distance)
	tween_animation()


func tween_animation():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(sprite_line, "width", beam_wight, 0.13)
	tween.tween_property(sprite_line, "width", 0, 0.13)
	tween.tween_callback(_disappear)


func _hit(area : Area2D) -> void:
	var enemy : EnemyObject = area.get_parent()
	hitbox_shape.set_deferred("disabled", true)
	emit_signal("hited", enemy, self)
#	call_deferred("_disappear")


func _reset():
	hitbox_shape.set_deferred("disabled", false)
	sprite_line.width = 0
	self.visible = true


func disappear():
	pass
