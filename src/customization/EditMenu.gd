extends HBoxContainer
export var display_label:String
onready var label = $Label

func _ready():
	label.text = display_label

func get_text() -> String:
	return label.text
