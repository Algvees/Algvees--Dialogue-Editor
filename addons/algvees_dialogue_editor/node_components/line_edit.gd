@tool
extends HBoxContainer

@onready var timer = $Timer
@onready var line_edit = $LineEdit
@onready var margin = $Margin
@onready var dragbutton = $dragbutton

var parent
var dragging: bool = false
var wait: bool = false

func _input(event):
	if wait:
		return
	if dragging:
		if event is InputEventMouseMotion:
			if event.relative.y > 1:
				reorder(1)
			if event.relative.y < -1:
				reorder(-1)
			wait = true
			timer.start(0.2)


func reorder(direction:int):
	parent.move_child(self,\
	clamp(get_index()+direction \
	,1,parent.get_child_count()))

func _on_dragbutton_button_down():
	dragging = true


func _on_dragbutton_button_up():
	dragging = false



func _on_timer_timeout():
	wait = false
	pass # Replace with function body.


func _on_x_button_pressed():
	parent.port_removed(self)
	call_deferred("free")
	parent.call_deferred("fix_size")
