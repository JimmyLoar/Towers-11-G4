extends PanelContainer

signal upgrade_selected(index)
const key_indexs = [KEY_Q, KEY_W, KEY_E]

var prise := 0

@onready var label: Label = $HBoxContainer/Label
@onready var button: Button = $HBoxContainer/VBox/Button
@onready var resource_display: PanelContainer = $HBoxContainer/VBox/ResourceDisplay


func _ready() -> void:
	EventBus.ui_resource_value_changed.connect(check_on_enough_value)


func _on_button_pressed() -> void:
	GlobalData.change_resource_value(GlobalData.ResourcesType.MONEY, - prise)
	emit_signal("upgrade_selected", self.get_index() - 1)


func set_upgrade(upgrade: TowerUpgrade):
	label.text = "%s" % upgrade.name
	prise = upgrade.prise
	resource_display.set_prise(prise)
	
	var key_index = key_indexs[self.get_index() - 1]
	button.text = "Buy [%s]" % char(key_index)
	button.shortcut = Shortcut.new()
	var input = InputEventKey.new()
	input.keycode = key_index
	button.shortcut.events.append(input)


func check_on_enough_value(type, check):
	if prise > check:
		button.disabled = true
	
	else:
		button.disabled = false
