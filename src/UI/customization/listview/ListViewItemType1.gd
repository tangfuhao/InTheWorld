extends Panel
const active_logo = preload("res://assert/ui/check.png")
const un_active_logo = preload("res://assert/ui/wrong.png")

onready var label = $Label
onready var background =$Backgournd
onready var active_button =$ActiveButton


var item_index := -1
var item_active
var item_selected = false


signal active_change(index,is_active)
signal item_selected(index)



func set_label(_label):
	label.text = _label
	
func set_active(_active):
	active_button.visible = true
	item_active = _active
	
	if item_active:
		active_button.texture = active_logo
	else:
		active_button.texture = un_active_logo
		

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if not item_selected:
				emit_signal("item_selected",item_index)
			


func _on_ActiveButton_active_button_clicked():
	set_active(!item_active)  
	emit_signal("active_change",item_index,item_active)
