extends HBoxContainer
export var display_label:String
onready var label = $Label
onready var text_edit = $TextEdit

func _ready():
	label.text = display_label

func get_text():
	return text_edit.text

func set_text(_text):
	text_edit.text = _text
