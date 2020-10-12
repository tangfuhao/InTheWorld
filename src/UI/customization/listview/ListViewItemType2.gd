extends Panel
onready var label = $HBoxContainer/Label
onready var dropdown = $HBoxContainer/OptionButton
onready var text_edit = $HBoxContainer/TextEdit


var item_index
signal item_value_change(index,key,value)


	
func set_selector_arr(selector_arr:Array,_selected_value):
	if selector_arr and not selector_arr.empty(): 
		var index = 1
		var default_index = 0
		for item in selector_arr:
			dropdown.add_item(str(item),index)
			if _selected_value && str(_selected_value) == str(item):
				default_index = index
			index = index + 1 
		dropdown.select(default_index)
		set_edit_value(_selected_value)
	else:
		dropdown.visible = false

	
func set_label(_display_label):
	label.text = _display_label

func set_edit_value(value):
	if not value:
		text_edit.text = ""
	else:
		text_edit.text = str(value)
		
	
func get_key_and_value():
	var label_str = label.text
	var edit_text = text_edit.text
	return [label_str,edit_text]
#	if is_show_selector:
#		var id = dropdown.get_selected_id()
#		var select_item_text = dropdown.get_item_text(id)
#		return [label_str,select_item_text]
#	else:
#		var edit_text = text_edit.text
#		return [label_str,edit_text]



func _on_TextEdit_text_changed():
	var key = label.text
	var value = text_edit.text
	emit_signal("item_value_change",item_index,key,value)


func _on_OptionButton_item_selected(index):
	var key = label.text
	var id = dropdown.get_selected_id()
	var value = dropdown.get_item_text(id)
	if value == "-":
		value = ""
	set_edit_value(value)
	emit_signal("item_value_change",item_index,key,value)
