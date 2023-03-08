extends PanelContainer

signal upgrade_selected(index)

var prise := 0

@onready var label: Label = $HBoxContainer/Label
@onready var button: Button = $HBoxContainer/Button


func _on_button_pressed() -> void:
	emit_signal("upgrade_selected", self.get_index() - 1)


func set_upgrade(upgrade: TowerUpgrade):
	label.text = "%s" % upgrade.name
	button.text = "$%s" % upgrade.prise
	
