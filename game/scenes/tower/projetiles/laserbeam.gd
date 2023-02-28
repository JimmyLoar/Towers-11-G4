class_name LaserBeam
extends MainProjectile

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


func _hit(area : Area2D) -> void:
	var enemy : EnemyObject = area.get_parent()
	hitbox_shape.set_deferred("disabled", true)
	self.visible = false
	emit_signal("hited", enemy, self)
	call_deferred("_disappear")


func _reset():
	hitbox_shape.set_deferred("disabled", false)
	self.visible = true


func disappear():
	pass
