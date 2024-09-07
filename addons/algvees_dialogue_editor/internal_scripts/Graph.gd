@tool
extends GraphEdit

@onready var r_click_menu: PopupMenu = $RClickMenu
@onready var node_menu: PopupMenu = $NodeMenu
@export var dialogue_root: Control
var node_types: Dictionary = {}

var selected: Array[DialogueGraphNode] = []
var editing: DialogueGraphNode
var start_node: DialogueGraphNode = null:
	set(new_node):
		if start_node != null:
			start_node.remove_start()
		new_node.set_start()
		start_node = new_node

var graph_nodes: Array[GraphElement] = []

func _ready() -> void:
	add_valid_connection_type(0,0)
	add_valid_connection_type(1,0)
	scan_node_directory()

func get_local_position():
	return (get_viewport().get_mouse_position() + scroll_offset - position) / zoom

func scan_node_directory():
	node_types.clear()
	node_menu.clear()
	var node_dir := DirAccess.open("res://addons/algvees_dialogue_editor/dialogue_nodes/")
	if node_dir:
		for file in node_dir.get_files():
			if file.find(".tscn")>-1:
				var new_packed_node: PackedScene = load("res://addons/algvees_dialogue_editor/dialogue_nodes/"+file)
				var new_node:DialogueGraphNode = new_packed_node.instantiate()
				node_types[new_node.ID] = new_packed_node
				node_menu.add_item(file.replace(".tscn",""),new_node.ID)
	else:
		push_error("dialogue_nodes directory missing")

func clear():
	for connection in get_connection_list():
		disconnect_from_dict(connection)
	for node in graph_nodes:
		node.name = "aaaaaaaaaaaaaaa"
		node.queue_free()
	graph_nodes.clear()

func disconnect_from_dict(dict):
	disconnect_node(dict.from_node,dict.from_port,dict.to_node,dict.to_port)

func create_node(id) -> GraphNode:
	var new_graph_node:DialogueGraphNode = node_types[id].instantiate()
	graph_nodes.append(new_graph_node)
	add_child(new_graph_node)
	return new_graph_node

func remove_node_connections(node,preserve_left_connection:bool = false):
	for connection in get_connection_list():
		if connection.to_node == node.name:
			disconnect_from_dict(connection)
		if !preserve_left_connection && connection.from_node == node:
			disconnect_from_dict(connection)

func create_graph_from_dict(dia_dict:Dictionary):
	for key in dia_dict.nodes.keys():
		var node_dict = dia_dict.nodes[key]
		var new_node = create_node(node_dict.type)
		new_node.name = key
		new_node.position_offset = Vector2(node_dict.x,node_dict.y)
		new_node.populate_data(node_dict)
		for i in node_dict.connections.size():
			if node_dict.connections[i] != null:
				var test = connect_node(key,i,node_dict.connections[i],0)
	start_node = get_node(dia_dict.start_node)

func _on_rc_menu_id_pressed(id: int) -> void:
	match id:
		0:
			node_menu.position = r_click_menu.position
			node_menu.popup()

func _on_node_menu_id_pressed(id: int) -> void:
	var new_node = create_node(id)
	new_node.position_offset = get_local_position()


func _on_node_selected(node):
	selected.append(node)

func _on_node_deselected(node):
	selected.erase(node)

func _on_connection_request(from_node, from_port, to_node, to_port):
	var from_type = get_node(str(from_node)).get_output_port_type(from_port)
	var to_type = get_node(str(to_node)).get_input_port_type(to_port)
	if is_valid_connection_type(from_type,to_type):
		for dict in get_connection_list():
			if from_node == dict.from_node:
				if from_port == dict.from_port:
					disconnect_from_dict(dict)
	
		connect_node(from_node,from_port,to_node,to_port)

func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node,from_port,to_node,to_port)

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node = get_node(str(node_name))
		if node == start_node:
			##to do: add error label
			#dialogue_editor.set_error_label("Cannot delete start node")
			continue
		remove_node_connections(node)
		graph_nodes.erase(node)
		node.queue_free()
	selected = []

func _on_popup_request(at_position: Vector2) -> void:
	r_click_menu.position = DisplayServer.mouse_get_position()
	r_click_menu.popup()
