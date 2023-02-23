extends HBoxContainer

@onready var lable_name: Label = $Name
@onready var lable_value: Label = $Value
@onready var lable_change: Label = $Change


func set_stat_name(_name: String):
	lable_name.text = tr("%s" % _name.to_upper())


func set_stat_value(value):
	lable_value.text = "%s" % value


func set_stat_change(change_value):
	if change_value == 0:
		lable_change.hide()
	else:
		lable_change.show()
		lable_change.text = "%s" % change_value
	
