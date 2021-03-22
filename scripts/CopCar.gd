extends Node2D

export var bullet_speed = 400
export var fire_time = 0.5
var bullet_path = 'res://BadBullet.tscn'
var bullet_scene = null
var fire_clock = 0
var player = null

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	bullet_scene = load(bullet_path)
	
func _physics_process(delta):
	$Wiggle/Gun.rotation = (player.position - self.position).angle()
	fire_clock -= delta
	if fire_clock < 0:
		fire_clock = fire_time
		var bullet = bullet_scene.instance()
		self.get_parent().add_child(bullet)
		bullet.position = self.position + $Wiggle/Gun.position
		bullet.velocity = (player.position - self.position).normalized() * bullet_speed
