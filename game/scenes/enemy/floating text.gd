class_name FloatingText
extends Node2D


var _pool: Array[Text] = []


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	self.rotation = - self.get_parent().rotation


func reset():
	for text in self.get_children():
		_on_text_finished(text)


func add_text(value, dir: float, type: GlobalData.AttackType = GlobalData.AttackType.NORMAL):
	var text_pos = Vector2(Text.GRAVITY.y * dir / 1.4, Text.GRAVITY.y / -2)
	var text : Text
	
	if _pool.is_empty():
		text = Text.new(value, text_pos)
	
	else:
		text = _pool.pop_front()
		text.text = str(value)
	
	if not text.is_connected("finished", _on_text_finished):
		text.connect("finished", _on_text_finished)
	
	text.reset()
	text.modulate = GlobalData.ATTACK_TEXT_COLORS[type]
	self.add_child(text)


func _on_text_finished(text: Text):
	self.remove_child(text)
	_pool.append(text)
 

class Text:
	extends Label
	signal finished(node: Text)
	
	const MAX_TIMELIFE = 0.5
	const GRAVITY := Vector2(0, 98)
	const TEXT_FONT = preload("res://assets/fonts/press_start_2p-regular.ttf")
	
	var timelife := 0.0
	var acceleration := Vector2.ZERO
	
	
	func _init(value, beginer_acceleration := Vector2.ZERO) -> void:
		text = str(value)
		acceleration = beginer_acceleration * Vector2(1, randf_range(0.5, 1.5))
		self.set("theme_override_colors/font_outline_color", Color.BLACK)
		self.set("theme_override_constants/outline_size", 35)
		self.set_physics_process(false)
	
	
	func _ready() -> void:
		pass
	
	
	func reset():
		self.timelife = 0.0
		self.self_modulate = Color.WHITE
		
		var rand_limit = 8
		self.position = - self.size / 2
		self.position += Vector2(randi_range(-rand_limit, rand_limit), randi_range(-rand_limit, rand_limit))
	
	
	func _process(delta: float) -> void:
		if self.timelife >= MAX_TIMELIFE:
			emit_signal("finished", self)
			return
		
		self.timelife += delta
		
		acceleration += GRAVITY * delta
		self.position += acceleration.normalized() * PI * delta * 10
		
		var alpha = 1 - self.timelife / MAX_TIMELIFE 
		self.self_modulate = Color.WHITE
		self.self_modulate.a = alpha
		self.scale = Vector2.ONE * (0.5 + alpha)

