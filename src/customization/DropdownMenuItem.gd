extends HBoxContainer
export (NodePath) var dropdown_path
onready var dropdown = get_node(dropdown_path)
onready var label = $Label
export var display_label:String
export var type:String

func _ready():
	label.text = display_label
	add_item()
	
	
func add_item():
	dropdown.add_item("Item 1")
	dropdown.add_item("Item 2")
	dropdown.add_item("Item 3")
	dropdown.add_item("Item 4")
