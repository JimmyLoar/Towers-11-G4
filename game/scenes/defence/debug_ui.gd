extends Control

@onready var fps: Label = $Lables/FPS


func _process(_delta: float) -> void:
	fps.text = "FPS: %s" % Engine.get_frames_per_second()
