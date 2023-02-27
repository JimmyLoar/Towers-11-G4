class_name EnemyObject
extends PathFollow2D

signal ended_path
signal death

const COLD_GRADIENT = preload("res://game/resources/gradient/cold_modulate.tres")
const HEAT_GRADIENT = preload("res://game/resources/gradient/heat_modulate.tres")
const UPDATE_IN_SECOND = 4

@export_placeholder("New Enemy") var object_name := ""
@export_group("Moving", "moving_")
@export_range(0, 100, 1) var moving_speed := 20
@export var moving_is_stopped := true
@export_range(0, 10, 0.01, "or_greater") var _density: float = 1.0

#@export_group("Stats", "stat_")
@export_range(0, 1000, 1, "or_greater") var stat_hitpoints := 100

var temperature := Temperature.new(0.0, true)
var move_slowing := 0.0 #Limit 0 - 1
var  _damaged_cache := {
	GlobalData.AttackType.NORMAL : 0.0,
	GlobalData.AttackType.HEAT : 0.0,
}

var _deathed := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var ui: Node2D = $UI
@onready var hitpoints_bar: TextureProgressBar = $UI/HitpointsBar
@onready var body_shape: CollisionShape2D = $Body/CollisionShape2D
@onready var floating_text: Node2D = $FloatingText


func _ready() -> void:
	self.add_child(temperature)
	if not temperature.is_connected("value_changed", _on_temperature_value_changed):
		temperature.connect("value_changed", _on_temperature_value_changed)


func _process(_delta: float) -> void:
	ui.rotation = self.global_rotation * -1


func _physics_process(delta: float) -> void:
	if moving_is_stopped or _deathed:
		return
	
	self.progress += delta * moving_speed * 5 * (1.0 - move_slowing)
	if progress_ratio >= 1.0:
		emit_signal("ended_path", self.get_index())
		moving_is_stopped = true
	
	if fmod(Engine.get_physics_frames(), Engine.physics_ticks_per_second / UPDATE_IN_SECOND) == 0:
		_show_damage_text()
		_update_temperature_modulate()


func reset(wave: float):
	temperature.set_power(0)
	
	sprite.modulate = Color.WHITE
	self.progress_ratio = 0
	moving_is_stopped = false
	body_shape.disabled = false
	
	var max_hp = stat_hitpoints + stat_hitpoints * (wave / 5)
	hitpoints_bar.max_value = max_hp
	hitpoints_bar.value = max_hp
	_deathed = false
	
	
	for key in _damaged_cache.keys():
		_damaged_cache[key] = 0.0
	
	floating_text.reset()



func take_damage(taked_damage: float, damage_type : GlobalData.AttackType = GlobalData.AttackType.NORMAL):
	if _deathed:
		return
	
	hitpoints_bar.value -= taked_damage
	if hitpoints_bar.value <= 0.0:
		_death()
	
	if not _damaged_cache.has(damage_type):
		print_debug("%s| taked unknow damage type (%s)" % [self.name, damage_type])
		return
	
	_damaged_cache[damage_type] += taked_damage


func recovery_hitpoints(recovered_hp: float):
	hitpoints_bar.value += recovered_hp


func is_dead() -> bool:
	if hitpoints_bar.value <= 0 or _deathed:
		return true
	return false


func increase_heat(on_increase : int):
	temperature.increase_power(on_increase)


func decrease_heat(on_decrease : int):
	temperature.decrease_power(on_decrease)


func get_wanted_position() -> Vector2:
	return self.global_position + self.transform.x * moving_speed


func _death():
	emit_signal("death", self.get_index())
	moving_is_stopped = true
	body_shape.set_deferred("disabled", true) 
	_deathed = true


func  _on_temperature_value_changed(value: int, changing_on: int):
	if _deathed:
		return
	
	if value >= 0:
		if changing_on > 0:
			var heat_damage := _count_heat_damage(value, changing_on)
#			print_debug("enemy damaged is are overheat")
			take_damage(heat_damage, GlobalData.AttackType.HEAT)
	
	else:
		move_slowing = temperature.get_value() / (Temperature.VALUE_LIMITS[0] * 1.15)


func _update_temperature_modulate():
	if not self.get_parent():
		return
	
	var value = temperature.get_value()
	var color: Color
	if value >= 0:
		var offset = temperature.get_value() / Temperature.VALUE_LIMITS[1]
		color = HEAT_GRADIENT.sample(offset)
	
	else:
		var offset = temperature.get_value() / Temperature.VALUE_LIMITS[0]
		color = COLD_GRADIENT.sample(offset)
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", color, 1 / UPDATE_IN_SECOND)


func _count_heat_damage(start_value: int, number: int) -> int:
	var end_value = start_value + number
	var damage: int = ((start_value + end_value) / 2) * (number + 1) / 2
#	print_debug("sv %s  ev %s | N %s | damage %s" % [start_value, end_value, number, damage])
	return damage / 4


func _show_damage_text():
	var displayed_text = ""
	for type in _damaged_cache.keys():
		if _damaged_cache[type] <= 0.0:
			continue
		
		displayed_text = str(_damaged_cache[type])
		floating_text.add_text(displayed_text, 0.0, type)
		_damaged_cache[type] = 0.0


class Temperature:
	extends Node
	
	signal value_changed(last_value: int, changing_on: int)
	
	const COLD_MODIFY  = -2.0
	const VALUE_LIMITS = [-273.15, 1500.0]
	const POWER_LIMITS = [-pow(VALUE_LIMITS[0], 2), pow(VALUE_LIMITS[1], 2)]
	
	var _power: float = 0.0
	var value: int = 0
	var last_value: int = 0
	var enable := true
	
	
	func _init(starting_power: float = 0.0, is_enable := true):
		_power = starting_power
		enable = is_enable
		value = get_value()
	
	
	func _physics_process(delta: float) -> void:
		if _power == 0.0:
			return
		
		elif abs(_power) <= 1.0:
			_power = 0.0
			return 
		
		var step = sqrt(abs(_power)) * delta * 25
		if _power < 0:
			step *= COLD_MODIFY
		
		_power = clamp(_power - step, POWER_LIMITS[0], POWER_LIMITS[1])
#		print("Power %s | Value %s | Step %s" % [_power, get_value(), step])
		_check_on_change()
	
	
	func increase_power(increase_value: float):
		increase_value = abs(increase_value)
		_power = clamp(_power + increase_value, POWER_LIMITS[0], POWER_LIMITS[1])
		_check_on_change()
	
	
	func decrease_power(decrease_value: float):
		decrease_value = sqrt(abs(decrease_value))
		_check_on_change()
	
	
	func set_power(new_power):
		_power = new_power
		value = get_value()
		last_value = value
	
	
	func get_power():
		return _power
	
	
	func get_value() -> int:
		var returning_value := 0.0
		if _power < 0:
			returning_value = sqrt(abs(_power)) / COLD_MODIFY
		if _power > 0:
			returning_value = sqrt(_power)
		else:
			returning_value = _power
		return clamp(roundi(returning_value), VALUE_LIMITS[0], VALUE_LIMITS[1])
	
	
	func _check_on_change():
		last_value = value
		value = get_value()
		if value == last_value:
			return
		
		emit_signal("value_changed", last_value, value - last_value)
	















