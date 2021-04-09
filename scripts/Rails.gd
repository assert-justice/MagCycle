extends Node2D

export (Array, Vector2) var rails = null

func set_rails(pattern):
	rails.clear()
	var rail_nodes = get_children()
	for i in len(pattern):
		if i == len(rail_nodes):
			return
		rail_nodes[i].visible = pattern[i] == '1'
		if rail_nodes[i].visible:
			rails.append(position + rail_nodes[i].position)
			

func _ready():
	rails = []
	set_rails("1100011")
