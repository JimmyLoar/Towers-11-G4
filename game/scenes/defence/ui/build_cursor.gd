extends Node2D

signal pressed(point_position: Vector2)
signal intersection_change(has_intersection: bool)

var last_cell_position := Vector2.ZERO
var structure : GridStructure
var display_icon : Texture

var limit_size = Vector2.ZERO

var collision_conflicts := []
var rotate_side := 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var poly_shape: CollisionPolygon2D = $Area2D/PolyShape
@onready var ui := $".."


func _ready() -> void:
	if not structure:
		structure = GridStructure.new()
		structure.set_structure(PackedVector2Array([Vector2.ZERO]))
	
	limit_size.x = ProjectSettings.get_setting("display/window/size/viewport_width") / GlobalData.CELL_SIZE.x
	limit_size.y = ProjectSettings.get_setting("display/window/size/viewport_height") / GlobalData.CELL_SIZE.y


func _process(_delta):
	if not self.visible or not structure:
		return
	
	var new_pos = CellObject.round_position(get_global_mouse_position(), true)
	var cell_pos = new_pos / GlobalData.CELL_SIZE
	if cell_pos != last_cell_position:
		last_cell_position = cell_pos
		
		var center = structure.get_center(rotate_side)
		var size = structure.get_size(rotate_side)
		var right_side  = Vector2()
		right_side.x = center.x - 1 if fmod(size.x, 2) == 0 else center.x
		right_side.y = center.y - 1 if fmod(size.y, 2) == 0 else center.y
		self.global_position = new_pos


func _input(event):
	if not self.visible:
		return
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("pressed", self.global_position, rotate_side)
	
	elif event.is_action_released("structure_rotate_right"):
		rotate_side = wrap(rotate_side - 1, 0, 4)
		update_collision_shape()
		self.queue_redraw()
	
	elif event.is_action_released("structure_rotate_left"):
		rotate_side = wrap(rotate_side + 1, 0, 4)
		update_collision_shape()
		self.queue_redraw()


func get_cells_at_layer(ind):
	return []


func _draw():
	if not structure:
		return
	
	var center = structure.get_center(rotate_side)
	var color_modulate = Color.WHITE
	if ui.is_destroy_mode():
		color_modulate = Color.RED if ui._posibility_build else Color.GREEN
		draw_dollar(color_modulate)
	
	else:
		color_modulate = Color.LIGHT_CYAN if ui._posibility_build else Color.RED
	
	color_modulate.a = 0.4
	draw_cells(center, color_modulate)
	update_display_icon()


func draw_dollar(color):
	draw_char(load("res://assets/fonts/press_start_2p-regular.ttf"), Vector2(-30, 40), "$", 64, Color.BLACK)
	draw_char(load("res://assets/fonts/press_start_2p-regular.ttf"), Vector2(-25, 34), "$", 54, color)


func draw_cells(center: Vector2, color: Color):
	for pos in structure.get_rotated_structure(rotate_side):
		var rect_size = GlobalData.CELL_SIZE - CellObject.CELL_DRAW_BORDER * 2
		var rect_position = (pos - center) * GlobalData.CELL_SIZE - (CellObject.CELL_OFFSET - CellObject.CELL_DRAW_BORDER)
		draw_rect(Rect2(rect_position, rect_size), Color.WHITE * color)
		draw_rect(Rect2(rect_position, rect_size), Color.WEB_GRAY * color, false, 2)


func update_display_icon():
	if display_icon:
		sprite.visible = true
		sprite.texture = display_icon
		sprite.rotation_degrees = 90 * rotate_side
		sprite.modulate = Color.RED if not ui._posibility_build else Color.LIGHT_GREEN
	
	else:
		sprite.visible = false
	
	var size := structure.get_size(rotate_side)
	var offset = Vector2.ZERO
	offset.x = 0.5 if fmod(size.x, 2) == 0 else 0.0
	offset.y = 0.5 if fmod(size.y, 2) == 0 else 0.0
	sprite.position = -offset * CellObject.CELL_SIZE 
	


func set_structure(new_structure: GridStructure):
	structure = new_structure
	update_collision_shape()


func set_image_icon(new_texture: Texture):
	display_icon = new_texture



func update_collision_shape():
	poly_shape.polygon = structure.get_outline(rotate_side)
	poly_shape.position = -structure.get_center(rotate_side) * CellObject.CELL_SIZE


func _on_area_2d_body_entered(body: Node2D) -> void:
	collision_conflicts.append(body)
	if not collision_conflicts.is_empty():
		emit_signal("intersection_change", true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	collision_conflicts.erase(body)
	if collision_conflicts.is_empty():
		emit_signal("intersection_change", false)
