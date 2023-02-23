class_name ObjectsManager
extends Node

var _class_type := 'objects'
var _ignor_pool := false

var _packed := Array()
var _instanced := Array()

var _paths_to_load := Array()
var _pool := Array()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_paths_to_load()
	init_objects()


func _init_paths_to_load(): 
	pass


func init_objects():
	if _paths_to_load.is_empty():
		print("Manager '%s' not init objects, path list is empty" % self._class_type)
		return
	
	LoadingScreen.add_task("init_%s" % self._class_type, _paths_to_load.size() - 1)
	LoadingScreen.open()
	if not _ignor_pool:
		for _i in _paths_to_load.size():
			_pool.append(Array())
	
	for ind in _paths_to_load.size():
		var path = _paths_to_load[ind]
		var _scene = ResourceLoader.load(path, "PackedScene")
		_packed.append(_scene)
		_instanced.append(_instantiate_object(ind, false))
		LoadingScreen.set_task_stage("init_%s" % self._class_type, ind)


func get_packed_scene(ind: int = 0) -> PackedScene:
	ind = wrapi(ind, 0, _paths_to_load.size())
	return _packed[ind]


func get_instanced_object(ind: int = 0):
	ind = wrapi(ind, 0, _paths_to_load.size())
	return _instanced[ind]


func get_new_object(ind: int) -> Node2D:
	ind = wrapi(ind, 0, _paths_to_load.size())
	var pool: Array = _pool[ind]
	if pool.is_empty():
		return _instantiate_object(ind)
	return pool.pop_front()


func  _instantiate_object(ind: int, is_init := false):
	var scene = get_packed_scene(ind)
	var object: Node2D =  scene.instantiate()
	if not _ignor_pool:
		object.tree_exited.connect(_return_object_in_pool.bind(object, ind))
	
	if is_init:
		self.add_child(object)
		object.set_enable(false)
	return object


func _return_object_in_pool(object: Node2D, ind):
	_pool[ind].append(object)


func _round_index(index : int) -> int:
	if index != 0:
		index = fmod(index, self._paths_to_load.size())
		index *= 1 if index >= 0 else -1
	return index
