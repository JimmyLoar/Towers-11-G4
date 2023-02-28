extends Node

enum AttackType{NORMAL, HEAT}
const ATTACK_TEXT_COLORS = [
	Color.WHITE_SMOKE, 
	Color.ORANGE_RED,
]

var towers_selected: Array = [0, 1, 0, 1] #tower indexs


enum ResourcesType{MONEY = 100, INFORMATION = 128}
const RESOURCE_DATA = {
	ResourcesType.MONEY: preload("res://game/database/game_resources/money_data.tres"),
}
var _resource_value := Dictionary()


func get_resource_value(resouce_type: GlobalData.ResourcesType) -> int:
	if _resource_value.has(resouce_type):
		return _resource_value[resouce_type]
	return 0


func change_resource_value(resouce_type: GlobalData.ResourcesType, on_value: int) -> void:
	if _resource_value.has(resouce_type):
		_resource_value[resouce_type] += on_value
	else:
		_resource_value[resouce_type] = on_value
	EventBus.emit_signal("ui_resource_value_changed", resouce_type, _resource_value[resouce_type])


func has_resource_value(type: ResourcesType, check_value: int, is_decrese := false):
	check_value = abs(check_value)
	if get_resource_value(type) < check_value:
		return false
	if is_decrese:
		change_resource_value(type, check_value)
	return true
