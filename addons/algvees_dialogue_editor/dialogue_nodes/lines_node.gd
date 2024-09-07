@tool
extends DialogueGraphNode

const LINE_EDITOR = preload("res://addons/algvees_dialogue_editor/node_components/line_editor.tscn")

func initialize():
	create_line()

func _populate_data(data:Dictionary):
	for line in data.lines:
		var new_line = create_line()
		new_line.line_edit.text = line


func create_save_dict():
	var dict = {}
	var lines:Array[String] = []
	for i in range(1,get_child_count()):
		var child = get_child(i)
		lines.append(child.line_edit.text)
	dict.lines = lines
	return dict

func create_line():
	var new_line = LINE_EDITOR.instantiate()
	new_line.parent = self
	new_line.custom_minimum_size.y = 100
	add_child(new_line)
	return new_line

func _on_add_line_pressed():
	create_line()
