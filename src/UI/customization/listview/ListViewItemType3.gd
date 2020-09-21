extends Container

onready var label = $MarginContainer/MarginContainer/Label
onready var label_bg = $MarginContainer/NinePatchRect


var item_index

	

func set_label(_label):
	label.text = _label
	


#func _on_Label_resized():
#	if label and label_bg:
#		var rect_size = Vector2()
#		label_bg.set_custom_minimum_size(rect_size)
func text_line_break(_text,_newline_num):
	var string_arr:PoolStringArray
	var break_line = _newline_num + 1
	var text_length = _text.length()
	var sub_offset = text_length / break_line
	for index in range(break_line):
		if index == _newline_num:
			var sub_text = _text.substr(index * sub_offset,text_length)
			string_arr.append(sub_text)
		else:
			var sub_text = _text.substr(index * sub_offset,sub_offset)
			text_length = text_length - sub_offset
			string_arr.append(sub_text)
			string_arr.append("\n")
	var result_str  = string_arr.join("")
	label.text = result_str

func _on_Label_resized():
	if label:
		var size = label.get_size()
		var newline_num := int(size.x) / 360
		if newline_num >= 1:
			text_line_break(label.text,newline_num)
