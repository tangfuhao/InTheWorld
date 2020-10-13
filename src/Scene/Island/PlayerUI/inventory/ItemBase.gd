extends MarginContainer
class_name PackgeItemBase

func _on_ColorRect_mouse_entered():
	GlobalRef.set_key_value_global(GlobalRef.global_key.mouse_interaction,self)
	
	


func _on_ColorRect_mouse_exited():
	GlobalRef.remove_value_from_key_global(GlobalRef.global_key.mouse_interaction,self)


func _on_Label_hide():
	GlobalRef.remove_value_from_key_global(GlobalRef.global_key.mouse_interaction,self)



