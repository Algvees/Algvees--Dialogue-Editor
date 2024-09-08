@tool
extends GraphNode

class_name DialogueGraphNode

@export var ID: int
var initial_title:String
var start: bool = false

signal graph_port_removed(node,index)
@export var adjustable_port_number: bool = false

func _ready():
	initial_title = title
	connect("renamed",change_title)
	connect("dragged",dragging_checks)
	change_title()

func initialize():
	pass

func fix_size():
	size = Vector2(0,0)

func dragging_checks(from:Vector2,_to:Vector2):
	if start:
		position_offset = from
		pass
	pass

func populate_data(data:Dictionary) -> void:
	position_offset = Vector2(data.x,data.y)
	_populate_data(data)

func _populate_data(data:Dictionary) -> void:
	pass

func _create_save_dict():
	push_error("node does not have custom create save dict function")
	return {}

func change_title():
	if name.find("@")>-1:
		name = name.replace("@","_")
		return
	title = initial_title+ ":" + name


func port_removed(node):
	if adjustable_port_number:
		for i in get_child_count():
			if get_child(i) == node:
				emit_signal("graph_port_removed",self,i-1)


func set_start():
	start = true
	set_slot_enabled_left(0,false)

func remove_start():
	start = false
	set_slot_enabled_left(0,true)

func create_save_dict():
	var dict = {}
	dict["type"] = ID
	dict["x"] = int(position_offset.x)
	dict["y"] = int(position_offset.y)
	dict.merge(_create_save_dict())
	return dict
