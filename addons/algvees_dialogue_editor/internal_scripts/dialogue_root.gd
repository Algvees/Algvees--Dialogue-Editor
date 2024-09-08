@tool
extends Control

@export var graph_containter: Control
@export var list_containter: Control
@export var dialogue_button_list: Control
@export var graph_edit: GraphEdit

@export var dialogue_line_edit: LineEdit 
@export var type_selector: TypeSetter 

@export var default_dialogue: DialogueResource
@export var item_dialogue_check: CheckBox 

var dialogue_resource: DialogueResource
var dialogue_base_dictionary: Dictionary:
	get:
		return dialogue_resource.Base_Dialogue
var dialogue_path:String
var current_dialogue: String = ""

func _ready() -> void:
	dialogue_resource = DialogueResource.new()
	new_resource()

func clear_list() -> void:
	for child in dialogue_button_list.get_children():
		child.name = "zxyzxy"
		child.queue_free()

func create_dialogue_button(dialogue_name):
	var new_button = Button.new()
	new_button.name = dialogue_name
	new_button.text = dialogue_name
	dialogue_button_list.add_child(new_button)
	new_button.pressed.connect(dia_button_pressed.bind(new_button))

func new_resource():
	dialogue_resource = default_dialogue.duplicate(true)
	open_resource()

func new_dialogue() -> void:
	save_dialogue()
	graph_edit.clear()
	var dia_name:String
	for i in INF:
		if dialogue_base_dictionary.has("dialogue" + str(i)):
			continue
		dia_name = "dialogue" + str(i)
		break
	current_dialogue = dia_name
	type_selector.select_type(0)
	graph_edit.start_node = graph_edit.create_node(0)
	create_dialogue_button(dia_name)
	dialogue_base_dictionary[dia_name] = {"special":0,"type":0}
	switch_dialogue(current_dialogue)

func delete_dialogue() -> void:
	if dialogue_base_dictionary[current_dialogue].special > 0: return
	dialogue_base_dictionary.erase(current_dialogue)
	dialogue_button_list.get_node(current_dialogue).queue_free()
	open_dialogue("default")

func load_resource(path:String) -> void:
	dialogue_resource = ResourceLoader.load(path,"DialogueResource")
	dialogue_path = path
	open_resource()

func open_resource():
	clear_list()
	graph_edit.clear()
	for dialogue_name in dialogue_base_dictionary.keys():
		create_dialogue_button(dialogue_name)
	open_dialogue("default")

func save_dialogue() -> void:
	var dict : Dictionary = dialogue_base_dictionary[current_dialogue]
	dict.nodes = {}
	dict.merge(type_selector.get_type_data_dict(),true)
	dict.item_dialogue = item_dialogue_check.button_pressed
	dict.start_node = str(graph_edit.start_node.name)

	var connections: Array = graph_edit.get_connection_list()
	dict.nodes = {}
	for node in graph_edit.graph_nodes:
		var node_dict = node.create_save_dict()
		var node_connections = []
		node_connections.resize(node.get_output_port_count())
		for connection in connections:
			if str(connection.from_node) == node.name:
				node_connections[connection.from_port] = (str(connection.to_node))
		
		node_dict["connections"] = node_connections
		dict.nodes[str(node.name)] = node_dict


func save_resource(path:String) -> void:
	save_dialogue()
	var test = ResourceSaver.save(dialogue_resource,path,ResourceSaver.FLAG_CHANGE_PATH)
	if test != OK:
		push_error("save failed at " + path)

func open_dialogue(dialogue_name:String) -> void:
	graph_edit.clear()
	current_dialogue = dialogue_name
	var dialogue_dictionary = dialogue_base_dictionary[dialogue_name]
	type_selector.populate_data(dialogue_dictionary)
	item_dialogue_check.button_pressed = dialogue_dictionary.item_dialogue
	if dialogue_base_dictionary[current_dialogue].special > 0:
		dialogue_line_edit.editable = false
		item_dialogue_check.disabled = true
		type_selector.disable()
	else:
		dialogue_line_edit.editable = true
		item_dialogue_check.disabled = false
		type_selector.enable()
	dialogue_line_edit.text = dialogue_name
	graph_edit.create_graph_from_dict(dialogue_dictionary)

func switch_dialogue(dialogue_name:String) -> void:
	save_dialogue()
	open_dialogue(dialogue_name)

func dia_button_pressed(button:Button) -> void:
	switch_dialogue(button.text)

func switch_view() -> void:
	if graph_containter.visible:
		list_containter.visible = true
		graph_containter.visible = false
	else:
		graph_containter.visible = true
		list_containter.visible = false

func change_dialogue_name(new_name:String) -> void:
	if dialogue_base_dictionary.has(new_name): return
	
	var button = dialogue_button_list.get_node(current_dialogue)
	button.name = new_name
	button.text = new_name
	dialogue_base_dictionary[new_name] = dialogue_base_dictionary[current_dialogue]
	dialogue_base_dictionary.erase(current_dialogue)
	current_dialogue = new_name

func _on_r_click_menu_id_pressed(id: int) -> void:
	if id == 1:
		if dialogue_path:
			save_resource(dialogue_path)
		else:
			$FileSaver.position = DisplayServer.mouse_get_position()
			$FileSaver.popup()


func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			new_resource()
		1:
			$FileSaver.position = DisplayServer.mouse_get_position()
			$FileSaver.popup()
		2:
			$FileLoader.position = DisplayServer.mouse_get_position()
			$FileLoader.popup()


func _on_dialogue_name_focus_exited() -> void:
	change_dialogue_name(dialogue_line_edit.text)
