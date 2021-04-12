extends Node2D

export (Array, Vector2) var rails = null
export (Array, Vector2) var lanes = null
export var default_rails = "0100111"

func set_rails(pattern):
	rails.clear()
	lanes.clear()
	var rail_nodes = get_children()
	for i in len(pattern):
		if i == len(rail_nodes):
			return
		rail_nodes[i].visible = pattern[i] == '1'
		if rail_nodes[i].visible:
			rails.append(position + rail_nodes[i].position)
		else:
			lanes.append(position + rail_nodes[i].position)
			

func _ready():
	rails = []
	lanes = []
	set_rails(default_rails)
