extends Panel

onready var list_view = $CommonListView


var data_arr := []



func add_message(_content_type,_content_text):
	var index = data_arr.size()
	list_view.add_content_text(index,_content_text,_content_type)
	data_arr.push_back(_content_text)
	
