extends Area2D

export var speed = 1000
export var jump_power = 700
export var gravity_power = 30
export var jump_time = 0.3
export var num_bullets = 10
export var bullet_spacing = 100
var jump_clock = 0
var velocity = Vector2()
var aim = Vector2()
var deadzone = 0.3
var clamp_distance = 10
var rails = [150, 250, 350, 450]
var bullet_path = 'res://Bullet.tscn'
var bullet_scene = null
var bullets = null
var offset_time = 16
var offset_clock = 0

func handle_movement(delta):
	var stick_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	if abs(stick_x) < deadzone:
		stick_x = 0
	elif stick_x < 0:
		stick_x += deadzone
	else:
		stick_x -= deadzone
	stick_x *= 1 / (1 - deadzone)
	velocity.x = stick_x * speed
	aim.x = 0
	aim.y = 0
	aim.x -= Input.get_action_strength("shoot_left")
	aim.x += Input.get_action_strength("shoot_right")
	aim.y -= Input.get_action_strength("shoot_up")
	aim.y += Input.get_action_strength("shoot_down")
	velocity.y += gravity_power
	if (not Input.is_action_pressed("fall")) and (not velocity.y < 0):
		for rail in rails:
			if abs(self.position.y - rail) < clamp_distance:
				self.position.y = rail
				velocity.y = 0
				break
	if Input.is_action_just_pressed("jump"):
		velocity.y -= jump_power
	
	self.position += velocity * delta
	$Gun/BulletMount.visible = aim.length() > deadzone
	if aim.length() > deadzone:
		$Gun.rotation = aim.angle()
		if offset_clock > offset_time / 2:
			$Gun/BulletMount.position.x = bullet_spacing #aim.normalized() * bullet_spacing * 0.5
		else:
			$Gun/BulletMount.position = Vector2()
		offset_clock -= 1
		if offset_clock < 0:
			offset_clock = offset_time

func _ready():
	bullets = []
	bullet_scene = load(bullet_path)
	for i in range(10):
		var bullet = bullet_scene.instance()
		$Gun/BulletMount.add_child(bullet)
		#$Gun/BulletMount.visible = false
		bullet.position.x = (i + 0.5) * bullet_spacing
		bullets.append(bullet)

func _physics_process(delta):
	handle_movement(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
