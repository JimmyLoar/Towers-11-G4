extends MarginContainer

var upgrade_item_scene = preload("res://game/scenes/defence/ui/tower_upgrade/upgrade_item.tscn")

@onready var item_container: VBoxContainer = $VBoxContainer
@onready var label: Label = $Label

var _tower : CellObject


func update_upgrades(tower: CellObject):
	_tower = tower
	var indexes := tower.get_upgrade_indexs()
	if indexes.is_empty():
		item_container.hide()
		label.show()
		return
	
	elif not item_container.visible:
		item_container.show()
		label.hide()
	
	var difference = (item_container.get_child_count() - 1) - indexes.size()
	if difference < 0:
		add_upgrade_items(abs(difference))
	
	elif difference > 0:
		remove_upgrade_items(difference)
	
	update_upgrade_items(indexes)


func add_upgrade_items(count: int):
	for _i in count:
		var new_item = upgrade_item_scene.instantiate()
		new_item.connect('upgrade_selected', _on_upgrade_selected)
		item_container.add_child(new_item)


func remove_upgrade_items(count: int):
	for _i in count:
		var child = item_container.get_child(1)
		item_container.remove_child(child)


func update_upgrade_items(indexes: Array):
	for i in item_container.get_child_count():
		if i == 0:
			continue
		
		var index = indexes[i - 1]
		var item = item_container.get_child(i)
		item.set_upgrade(_tower.get_upgrade(index))


func _on_upgrade_selected(index: int):
	_tower.upgrade_selecte(index)
	var parent = self.get_parent().get_parent()
	parent.call("_on_tower_focused", _tower, true)
	
