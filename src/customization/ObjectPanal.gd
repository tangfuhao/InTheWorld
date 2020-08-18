extends VBoxContainer

onready var stuff_name = $NameList/StuffName
onready var physic_list = $PhysicsList

func is_prepare()-> bool:
	return true

func get_physics_data():
	return physic_list.get_physics_data()

func get_object_name():
	return stuff_name.get_text()
