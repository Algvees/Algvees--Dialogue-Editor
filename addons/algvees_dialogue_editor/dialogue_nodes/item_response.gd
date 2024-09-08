@tool
extends DialogueGraphNode

const LINE_EDITOR = preload("res://addons/algvees_dialogue_editor/node_components/line_editor.tscn")

@onready var nothing_response = $NothingResponse


func initialize():
	create_new_line()

func _populate_data(data:Dictionary):
	for line in data.items:
		var new_line = create_new_line()
		new_line.line_edit.text = line
		pass
	pass

func _create_save_dict():
	var dict = {}
	dict["items"] = []
	for i in range(2,get_child_count()):
		var child = get_child(i)
		dict.items.append(child.line_edit.text)
	return dict

func create_new_line():
	var new_line = LINE_EDITOR.instantiate()
	new_line.parent = self
	add_child(new_line)
	new_line.dragbutton.visible = false
	new_line.line_edit.placeholder_text = "item"
	new_line.margin.custom_minimum_size.x = 15
	set_slot_enabled_right(get_child_count()-1,true)
	return new_line

func _on_button_pressed():
	create_new_line()
