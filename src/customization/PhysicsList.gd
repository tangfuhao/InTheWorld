extends VBoxContainer
const physic_param_dic = {"动力学性质":["刚体","柔性物体","流体","织物"],
						"尺寸":["0.1","0.5","1","5","10"],
						"几何形状":["长方形","圆柱体","异形"],
						"是否中空":["是","否"],
						"重量":["0.1","1","10","100","1000"],
						"颜色":["绿","黑","白","红","棕","黄","橙","灰"],
						"图样":[],
						"气味":[],
						"材质":[],
						"损耗方式":["磨损","破碎","形变","溶解","故障","没电"]
						}


onready var list_view = $ParamsListView

func _ready():
	list_view.set_config(physic_param_dic)
	
func get_physics_data():
	return list_view.get_physics_data()
