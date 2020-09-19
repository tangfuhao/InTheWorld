extends Panel

onready var label = $MarginContainer/HBoxContainer/NinePatchRect/MarginContainer/Label
onready var label_bg = $MarginContainer/HBoxContainer/NinePatchRect


var item_index

func _ready():
	set_label("阿达是否阿s阿阿达是否阿s")

func set_label(_label):
	label.text = _label


func _on_Label_resized():
	if label and label_bg:
		var rect_size = Vector2(label.rect_size)
		label_bg.set_custom_minimum_size(rect_size)
