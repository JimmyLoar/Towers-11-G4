extends MainProjectile

const  MAXIMAL_MOVING_SPEED := 3840

@onready var sprite : Sprite2D = $Sprite2D
@onready var area = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D

var moving_speed := 0.0
var velocity := Vector2()


func _ready() -> void:
	pass


func launch(strength: int):
	moving_speed = strength
