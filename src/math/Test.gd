extends Node2D


func _ready():
	test_cal()

func test_cal():
	var values = {}
	values["dddd"] = 56
	
	var formulas = {}
	formulas["eeee"] = "#{dddd}*20"
	
	var expression = "#{eeee}*-12+13-#{dddd}+24"
	var parser = FormulaParser.new()
	var result = parser.parse(expression, formulas, values)
	assert(result == -13459.0,"sss")
