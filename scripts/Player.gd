extends Area2D

export var speed = 1000
export var jump_power = 600
export var gravity_power = 30
export var jump_time = 0.3
export var num_bullets = 10
export var bullet_spacing = 100
export var shoot_slowdown = 0.4
export var flash_time = 1
export var flash_cycle = 0.25
export var flash_thresh = 0.5
export var max_health = 3
export var health = 0
var flash_clock = -1
var jump_clock = 0
var velocity = Vector2()
var aim = Vector2()
var deadzone = 0.3
var clamp_distance = 10
var rails = null
var bullet_path = 'res://Bullet.tscn'
var bullet_scene = null
var bullets = null
var offset_time = 16
var offset_clock = 0
var space_state = null

signal damage(value)

func shoot():
	space_state = get_world_2d().direct_space_state
	var test = space_state.intersect_ray(self.position, aim.normalized() * 5000, [self])
	if len(test) > 0:
		test.collider.emit_signal("damage", 1, aim.normalized(), test.position)

func handle_movement(delta):
	var stick_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	if abs(stick_x) < deadzone:
		stick_x = 0
	elif stick_x < 0:
		stick_x += deadzone
	else:
		stick_x -= deadzone
	stick_x *= 1 / (1 - deadzone)
	
	aim.x = 0
	aim.y = 0
	aim.x -= Input.get_action_strength("shoot_left")
	aim.x += Input.get_action_strength("shoot_right")
	aim.y -= Input.get_action_strength("shoot_up")
	aim.y += Input.get_action_strength("shoot_down")
	velocity.y += gravity_power
	if (not Input.is_action_pressed("fall")) and (not velocity.y < 0):
		if rails == null:
			rails = get_tree().get_nodes_in_group("Rails")[0].rails
		for rail in rails:
			if abs(self.position.y - rail.y) < clamp_distance:
				self.position.y = rail.y
				velocity.y = 0
				break
	if Input.is_action_just_pressed("jump"):
		velocity.y -= jump_power
	
	self.position += velocity * delta
	$Gun/BulletMount.visible = aim.length() > deadzone
	if aim.length() > deadzone:
		if not $ShootSound.playing:
			$ShootSound.play()
		shoot()
		#stick_x *= shoot_slowdown
		$Gun.rotation = aim.angle()
		if offset_clock > offset_time / 2:
			$Gun/BulletMount.position.x = bullet_spacing #aim.normalized() * bullet_spacing * 0.5
		else:
			$Gun/BulletMount.position = Vector2()
		offset_clock -= 1
		if offset_clock < 0:
			offset_clock = offset_time
	velocity.x = stick_x * speed

func _ready():
	health = max_health
	bullets = []
	bullet_scene = load(bullet_path)
	for i in range(50):
		var bullet = bullet_scene.instance()
		$Gun/BulletMount.add_child(bullet)
		bullet.position.x = (i + 0.5) * bullet_spacing
		bullets.append(bullet)

func _physics_process(delta):
	if health < 0:
		velocity.y += gravity_power
		position += velocity * delta
		return
	if position.y > 650:
		queue_free()
	handle_movement(delta)
	position.x = clamp(position.x, 0, 1030)
	if (flash_clock < 0):
		$Flash.visible = false
	else:
		flash_clock -= delta
		var cycle = flash_clock - floor(flash_clock / flash_cycle) * flash_cycle
		$Flash.visible = cycle < flash_cycle * flash_thresh

func _on_Player_damage(value):
	if (flash_clock < 0):
		health -= value
		if health < 0:
			$DeathParticles.emitting = true
		flash_clock = flash_time
