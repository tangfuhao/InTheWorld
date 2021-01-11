class_name LogSys


var data_arr := []
var processed_message_queue := []

func log_i(_str):
	processed_message_queue.push_back(_str)
	print(_str)
