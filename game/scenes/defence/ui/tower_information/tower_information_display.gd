extends PanelContainer

const stat_display_scene = preload("res://game/scenes/defence/ui/tower_information/stat_display.tscn") 

var testing_tower_index := 0

var focus_tower : TowerBody 

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var stat_container: VBoxContainer = $VBoxContainer/StatsMenu/StatContainer



func _ready() -> void:
	self.hide()
	EventBus.tower_mouse_focused.connect(_on_tower_focused)



func _on_tower_focused(tower: TowerBody, focus: bool):
	if not focus:
		self.hide()
		return
	
	if not self.visible:
		self.show()
	
	update_name(tower.get_object_name())
	update_stats(tower.get_current_stats())


func update_name(_name):
	name_label.text = "%s" % _name


func update_stats(stats: Dictionary):
	var difference = (stat_container.get_child_count() / 2) - stats.size()
	if difference < 0:
		add_stat_display(abs(difference))
	
	elif difference > 0:
		remove_stats_display(difference)
	
	update_stat_display(stats)


func add_stat_display(count: int):
	for _i in count:
		var new_stat_display := stat_display_scene.instantiate()
		stat_container.add_child(new_stat_display)
		var separater := HSeparator.new()
		stat_container.add_child(separater)


func remove_stats_display(count: int):
	for _i in count:
		stat_container.get_child(0).queue_free()
		stat_container.get_child(0).queue_free()


func update_stat_display(stats: Dictionary):
	for index in stat_container.get_child_count() / 2:
		var child := stat_container.get_child(index * 2)
		if child is HSeparator:
			continue
		
		var stat_key: String = stats.keys()[index] 
		child.set_stat_name(stat_key)
		child.set_stat_value(stats[stat_key])
		child.set_stat_change(0)
