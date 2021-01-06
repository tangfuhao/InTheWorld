extends Control

var zone_scene = preload("res://src/Scene/Island/Island.tscn")
var edit_object_scene = preload("res://src/UI/customization/CreateObjectPanel.tscn")
var lobby_scene = preload("res://src/Scene/Lobby/Lobby.tscn")



func _on_Button_pressed():
	get_tree().change_scene_to(lobby_scene)


func _on_Button2_pressed():
	get_tree().change_scene_to(edit_object_scene)


func _on_Button3_pressed():
	pass # Replace with function body.
