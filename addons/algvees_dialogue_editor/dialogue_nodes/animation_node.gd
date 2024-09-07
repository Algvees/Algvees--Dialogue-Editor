@tool
extends DialogueGraphNode

@onready var animation_name = $"VBoxContainer/HBoxContainer/animation name"
@onready var pause_check = $"VBoxContainer/pause check"

func _populate_data(data:Dictionary):
	animation_name.text = data.animation_name 
	pause_check.button_pressed = data.pause_check

func create_save_dict():
	var dict = {}
	dict["animation_name"] = animation_name.text
	dict["pause_check"] = pause_check.button_pressed
	return dict
