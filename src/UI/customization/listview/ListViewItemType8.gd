extends Control

onready var label = $MarginContainer/Label



var item_index

signal on_click(_item)


func set_label(_label):
	label.text = _label


func _on_Button_pressed():
	emit_signal("on_click",self)
