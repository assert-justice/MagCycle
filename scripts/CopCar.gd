extends Node2D

export var bullet_speed = 400
export var fire_time = 0.90
export var speed = 200
export var wiggle_time = 0.1
export var wiggle_distance = 30
export var wiggle_speed = 1000
export var health = 1
export var alive = true
var wiggle_clock = -1
var velocity = Vector2()
var bullet_path = 'res://BadBullet.tscn'
var bullet_scene = null
var fire_clock = 0
var player = null
var wiggle_pos = Vector2()
var wiggle_ang = 0
var damage_val = 0
var gravity = 30

signal damage(value, direction, pos)
signal set_pos(pos)

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	bullet_scene = load(bullet_path)
	fire_clock = randf() * fire_time

func _physics_process(delta):
	if position.y > 600:
		queue_free()
	if player == null:
		return
	if health < 0:
		if position.y > 650:
			queue_free()
		velocity.y += gravity
		position += delta * velocity
		return
	$Wiggle/Gun.rotation = (player.position - self.position).angle()
	fire_clock -= delta
	var dx = (player.position.x - self.position.x) * 30
	velocity.x += dx
	velocity.x = clamp(velocity.x, -speed, speed) * delta
	self.position.x += velocity.x
	if fire_clock < 0:
		fire_clock = fire_time
		var bullet = bullet_scene.instance()
		self.get_parent().add_child(bullet)
		bullet.position = self.position + $Wiggle/Gun.position
		bullet.velocity = (player.position - self.position).normalized() * bullet_speed
		$ShootSound.play()
	var sensitivity = 10
	if not wiggle_clock < 0:
		wiggle_clock -= delta
		$DamageParticles.emitting = true
		health -= damage_val * delta
		if ($Wiggle.position - wiggle_pos).length() < sensitivity:
			# reset wiggle
			var angle = randf() * PI * 2
			wiggle_pos.x = cos(angle)
			wiggle_pos.y = sin(angle)
			wiggle_pos *= wiggle_distance
			wiggle_ang = (randf() - 0.5) * PI / 16
	else:
		wiggle_pos = Vector2()
		wiggle_ang = 0
		$DamageParticles.emitting = false
	if ($Wiggle.position - wiggle_pos).length() >= sensitivity:
		$Wiggle.position += (wiggle_pos - $Wiggle.position).normalized() * wiggle_speed * delta
		var turn = sign(wiggle_ang - $Wiggle.rotation) * 10 * delta
		$Wiggle.rotation += turn
	else:
		$Wiggle.rotation = 0

func _on_CopCar_damage(value, direction, pos):
	damage_val = value
	if health < 0:
		alive = false
		velocity.y -= 10
		if $DieSound != null:
			$DieSound.play()
			var sound = $DieSound
			remove_child(sound)
			get_parent().add_child(sound)
	wiggle_clock = wiggle_time
	$DamageParticles.direction = direction
	


func _on_CopCar_set_pos(pos):
	position = pos
