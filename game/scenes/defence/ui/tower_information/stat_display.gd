extends HBoxContainer

@onready var lable_name: Label = $Name
@onready var lable_value: Label = $Value
@onready var lable_change: Label = $Change


func set_stat_name(_name: String):
	lable_name.text = tr("%s" % _name.to_upper())


func set_stat_value(value):
	lable_value.text = tr("%s" % value.to_upper())


func set_stat_change(change_value):
	lable_change.text = tr("%s" % change_value.to_upper())
	
