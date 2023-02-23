extends CanvasLayer


var queue_list := Array()
var current_place: int = 0
var next_scene : PackedScene

var loader := ResourceLoader

var _tasks := Dictionary()

func _init() -> void:
	pass


func _process(_delta: float) -> void:
	if queue_list.is_empty() and _tasks.is_empty():
		self.close()


func open():
#	get_tree().paused = true
	self.show()


func close():
#	get_tree().paused = false
	self.hide()


func add_task(task_name: String, max_stage := 1):
	if _tasks.has(task_name):
		push_error("LoadingScreen | attempt to add exist task '%s': %s" % [task_name, _tasks])
		print_stack()
	
	else:
		print("LoadingScreen | add new task '%s', max stage %s'" % [task_name, max_stage + 1])
	
	_tasks[task_name] = [0, max_stage]


func set_task_stage(task_name: String, stage: int):
	if not _tasks.has(task_name):
		push_error("LoadingScreen | attempt to add exist task '%s': %s" % [task_name, _tasks])
		print_stack()
	
	else:
		print("LoadingScreen | set task '%s' stage '%s'" % [task_name, stage + 1])
	
	_tasks[task_name][0] = stage
	if _tasks[task_name][0] == _tasks[task_name][1]:
		remove_task(task_name) 


func remove_task(task_name: String):
	if not _tasks.has(task_name):
		printerr("LoadingScreen | attempt to remove not exist task '%s': %s" % [task_name, _tasks])
		print_stack()
	
	else:
		print("LoadingScreen | completion task '%s'" % task_name)
		print()
	
	_tasks.erase(task_name)


func add_to_queue():
	pass


func load_next_scene(path: String):
	loader.load_threaded_request(path, "PackedScene", true)


func load_next_in_queue():
	pass

