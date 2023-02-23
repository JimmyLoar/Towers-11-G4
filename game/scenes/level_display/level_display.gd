class_name LevelDisplay
extends Node2D

@export_placeholder("LevelNoName") var level_name := String()
@export var wave_max_amount := 10 
@export var enemies_count_in_wave: int = 10
@export var enemies_list : Array[int] = [0]
@export var enemies_unique : Array[int] = [1]

@onready var tile_map: TileMap = $TileMap
@onready var enemies_path: Path2D = $EnemiesPath2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_recharge_timer: Timer = $WaveRecharge

var spawn_count_reaming: int = 0
var current_wave := 0


func _ready() -> void:
	pass


func get_cells_at_layer(ind: int) -> Array[Vector2i]:
	if ind < 1 or ind >= tile_map.get_layers_count():
		printerr("index not exist")
		print_stack()
		breakpoint
	return tile_map.get_used_cells(ind)


func start_next_wave(_wave: int = 0):
	EventBus.emit_signal("ui_defence_wave_number_change", _wave + 1, wave_max_amount)
	if spawn_count_reaming > 0:
		printerr("Level | cannot statr next wave because not all enemiest spawn")
		print_stack()
		return
	
	spawn_count_reaming = enemies_count_in_wave + 1 * int(current_wave / 3)
	spawn_timer.start()


func stop_wave():
	pass


func _on_end_wave():
	if wave_max_amount == current_wave:
		return
	
	current_wave += 1
	wave_recharge_timer.start()


func _on_spawn_timer_timeout() -> void:
	spawn_count_reaming -= 1
	if spawn_count_reaming < 0:
		spawn_timer.stop()
	
	else:
		enemies_path.create_enemy(0, current_wave)


func _on_wave_recharge_timeout() -> void:
	start_next_wave(current_wave)


func _on_start_wave_pressed() -> void:
	start_next_wave(current_wave)
