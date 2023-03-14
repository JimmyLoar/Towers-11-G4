extends PanelContainer

@export var resource_type:  GlobalData.ResourcesType = GlobalData.ResourcesType.MONEY
@export var prise := -1

@onready var icon: TextureRect = $HBoxContainer/Icon
@onready var preffix_label: Label = $HBoxContainer/Preffix
@onready var value_label: Label = $HBoxContainer/Value


func _ready() -> void:
	update_data()
	EventBus.ui_resource_value_changed.connect(_on_resource_amount_changed)


func update_data(type: GlobalData.ResourcesType = resource_type) -> void:
	var data: GameResource = GlobalData.RESOURCE_DATA[type]
	icon.texture = data.icon
	if not data.icon:
		icon.visible = false
		preffix_label.visible = true
		preffix_label.text = data.text_preffix
	
	else:
		icon.visible = true
		icon.texture = data.icon
		preffix_label.visible = false
	
	update_value(type)


func update_value(type: GlobalData.ResourcesType = resource_type) -> void:
	var value := GlobalData.get_resource_value(type)
	value_label.text = "%s" % [value if prise < 0 else prise] 


func set_prise(value: int):
	prise = value
	update_value()


func _on_resource_amount_changed(type, new_value):
	if type != resource_type:
		return
	
	update_data(type)
