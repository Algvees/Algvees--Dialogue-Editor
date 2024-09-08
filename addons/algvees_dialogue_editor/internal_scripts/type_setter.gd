@tool
extends HFlowContainer
class_name TypeSetter

var types: Dictionary
var selected_type: DialogueType
@onready var type_selector: OptionButton = $TypeSelector

func _ready() -> void:
	scan_type_dir()

func populate_data(dict:Dictionary) -> void:
	select_type(dict.type)
	type_selector.select(type_selector.get_item_index(dict.type))
	if dict.type > 0:
		selected_type._populate_data(dict)

func get_type_data_dict() -> Dictionary:
	var dict = {}
	if selected_type:
		dict = {"type" : selected_type.id}
		dict.merge(selected_type._get_data_dict())
	else:
		dict = {"type" : 0}
	return dict

func scan_type_dir() -> void:
	for node in types:
		node.queue_free()
	types.clear()
	type_selector.clear()
	type_selector.add_item("default",0)
	var node_dir := DirAccess.open("res://addons/algvees_dialogue_editor/dialogue_types/")
	if node_dir:
		for file in node_dir.get_files():
			if file.find(".tscn")>-1:
				var new_node: Control = load("res://addons/algvees_dialogue_editor/dialogue_types/"+file).instantiate()
				types[new_node.id] = new_node
				new_node.visible = false
				add_child(new_node)
				type_selector.add_item(file.replace(".tscn",""))
	else:
		push_error("dialogue_types directory missing")

func disable():
	type_selector.disabled = true

func enable():
	type_selector.disabled = false

func select_type(id:int):
	if selected_type:
		selected_type.visible = false
	if id > 0:
		selected_type = types[id]
		selected_type.visible = true
		selected_type._clear()
	else:
		selected_type = null

func _on_type_selector_item_selected(index: int) -> void:
	select_type(type_selector.get_item_id(index))
