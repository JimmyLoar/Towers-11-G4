class_name GameResource
extends Resource

@export_placeholder("Empty Game Resorce") var _name: String = ""
@export_placeholder("Preffix") var text_preffix := "$"
@export_multiline var discription := "" 
@export var icon: Texture

func get_translate_name():
#	return tr(_name.to_upper())
	return _name

