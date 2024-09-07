@tool
extends DialogueType

@onready var activator_flag: LineEdit = $ActivatorFlag
@onready var affected_dialogue: LineEdit = $AffectedDialogue

func _get_data_dict() -> Dictionary:
	return {"activator_flag":activator_flag.text,"affect_dialogue":affected_dialogue.text}

func _populate_data(dict:Dictionary) -> void:
	activator_flag.text = dict.activator_flag
	affected_dialogue.text = dict.affect_dialogue

func _clear() -> void:
	activator_flag.text = ""
	affected_dialogue.text = ""
