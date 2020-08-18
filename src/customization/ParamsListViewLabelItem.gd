extends Panel
onready var label = $HBoxContainer/Panel/Label
onready var dropdown = $HBoxContainer/Control/OptionButton
onready var text_edit = $HBoxContainer/Control/TextEdit

var is_show_selector = false
	
func set_selector_arr(selector_arr:Array):
	if selector_arr && selector_arr.empty() == false: 
		is_show_selector = true
		dropdown.visible = true
		text_edit.visible = false
		for item in selector_arr:
			dropdown.add_item(str(item))
	else:
		is_show_selector = false
		dropdown.visible = false
		text_edit.visible = true
	
func set_label(_display_label):
	label.text = _display_label
	
func get_key_and_value():
	var label_str = label.text
	if is_show_selector:
		var id = dropdown.get_selected_id()
		var select_item_text = dropdown.get_item_text(id)
		return [label_str,select_item_text]
	else:
		var edit_text = text_edit.text
		return [label_str,edit_text]
		
func set_params(params):
	pass
