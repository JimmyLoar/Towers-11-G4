extends Node

enum AttackType{NORMAL, HEAT}
const ATTACK_TEXT_COLORS = [
	Color.WHITE_SMOKE, 
	Color.ORANGE_RED,
]

var towers_selected: Array = [2, 2, 2, 2] #tower indexs


enum ResourcesType{MONEY = 100, INFORMATION = 128, PLAYER_LIFE = 555}
const RESOURCE_DATA = {
	ResourcesType.MONEY: preload("res://game/database/game_resources/money_data.tres"),
	ResourcesType.INFORMATION: preload("res://game/database/game_resources/information_data.tres"),
	ResourcesType.PLAYER_LIFE: preload("res://game/database/game_resources/player_life.tres"),
}
var _resource_value := Dictionary()


func get_resource_value(resource_type: GlobalData.ResourcesType) -> int:
	if _resource_value.has(resource_type):
		return _resource_value[resource_type]
	return 0


func set_resource_value(type: ResourcesType, value):
	_resource_value[type] = float(value)
	EventBus.emit_signal("ui_resource_value_changed", type, value)


func change_resource_value(resouce_type: GlobalData.ResourcesType, on_value: float) -> void:
	if _resource_value.has(resouce_type):
		_resource_value[resouce_type] += on_value
		EventBus.emit_signal("ui_resource_value_changed", resouce_type, _resource_value[resouce_type])
		return
	
	set_resource_value(resouce_type, on_value)


func has_resource_value(type: ResourcesType, check_value: int, is_decrese := false):
	check_value = abs(check_value)
	if get_resource_value(type) < check_value:
		return false
	if is_decrese:
		change_resource_value(type, check_value)
	return true
