extends TextureRect
signal active_button_clicked
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("active_button_clicked")
