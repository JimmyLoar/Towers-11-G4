extends Button

@export var test_prise := 10
@export var texture_file : Texture

@onready var icon_texture: TextureRect = $VBoxContainer/IconTexture
@onready var num_indicate: Label = $VBoxContainer/IconTexture/NumIndicate
@onready var prise_label: Label = $VBoxContainer/Prise



func _init():
	pass


func _ready():
	var index = self.get_index()
	var tower_index = GlobalData.towers_selected[index]
	var tower: TowerBody = Towers.get_instanced_object(tower_index)
	call_deferred("_update", tower)
	
	num_indicate.text = "%s" % [index + 1]
	var event := InputEventKey.new() 
	event.keycode = 49 + index
	self.shortcut = Shortcut.new()
	self.shortcut.events.append(event)



func _update(tower: TowerBody):
	icon_texture.texture = tower.get_icon()



