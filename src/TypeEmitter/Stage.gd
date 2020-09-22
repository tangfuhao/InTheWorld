extends Panel

onready var list_view = $CommonListView
onready var message_dispacher_timer = $message_dispach_timer

var data_arr := []
var processed_message_queue := []
var processed_message_type_queue := []


func add_message(_content_type,_content_text):
	processed_message_queue.push_back(_content_text)
	processed_message_type_queue.push_back(_content_type)

	

func update_message_queue():
	if not processed_message_queue.empty():
		var content_text = processed_message_queue.pop_front()
		var content_type = processed_message_type_queue.pop_front()
		var index = data_arr.size()
		list_view.add_content_text(index,content_text,content_type)
		data_arr.push_back(content_text)


func _on_message_dispach_timer_timeout():
	yield(get_tree(),"idle_frame")
	update_message_queue()
#	message_dispacher_timer.start(0.5)
