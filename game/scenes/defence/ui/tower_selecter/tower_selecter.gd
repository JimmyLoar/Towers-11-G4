extends HBoxContainer

signal tower_selected(tower_index)
signal cansel_selected

var item_scene := load("res://game/scenes/defence/ui/tower_selecter/selecter_item.tscn") as PackedScene
var _towers := Array()

var _normal_size = Vector2(120, 132)
var _mini_size = Vector2(120, 44)

var _is_minimal := true

@onready var build_buttons: HBoxContainer = $BG/BuildButtons
@onready var clear_item: Button = $ClearItem


func init(towers: Array = []):
	_towers = towers
	var difference = towers.size() - build_buttons.get_child_count()
	if difference > 0:
		for i in difference:
			_create_items()
	
	elif difference < 0:
		remove_item()
	
	_update_items()
	
	if not clear_item.is_connected("pressed", _pressed_button):
		clear_item.pressed.connect(_pressed_button.bind(-1))


func _create_items():
	var new_item : Button = item_scene.instantiate() #instantiate
	build_buttons.add_child(new_item)
	new_item.pressed.connect(_pressed_button.bind(new_item.get_index()))


func remove_item():
	if build_buttons.get_child_count() <= 0:
		return
	
	var item = build_buttons.get_child(0)
	build_buttons.remove_child(item)
	item.queue_free()


func _update_items():
	for child in build_buttons.get_children():
		if not child.is_connected("pressed", Callable(self, "_pressed_button")):
			child.pressed.connect(_pressed_button.bind(child.get_index()))
	


func _pressed_button(index):
	var send_value = _towers[index]
	if index == -1:
		send_value = -1
	
	emit_signal("tower_selected", send_value)



func _on_toggle_button_pressed() -> void:
	var tween = create_tween()
	var final_size = Vector2(self.size.x, self.size.y)
	final_size.y = _normal_size.y if _is_minimal else _mini_size.y
	tween.tween_property(self, "size", final_size, 1.0)
	_is_minimal = not _is_minimal
