extends Node

var chunks = null
var cop_car_path = 'res://CopCar.tscn'
var cop_car_scene = null
var wave_time = 0
var min_wave_time = 2
var max_wave_time = 10
var min_wave_size = 2
var max_wave_size = 5
var cop_cars = null
var cars_destroyed = 0
var scene_path = 'res://Scene.tscn'
var game_scene = null
var game = null
var started = false
var player = null

func _ready():
	cop_cars = []
	cop_car_scene = load(cop_car_path)
	game_scene = load(scene_path)
	load_scene()
	
func first_wave():
	wave_time = rand_range(min_wave_time, max_wave_time)
	var wave_size = 1
	var rails = $Scene/Rails.lanes.duplicate()
	var num_rails = len(rails)
	while wave_size + len(rails) > num_rails:
		if len(rails) == 0:
			return
		var rail = rails[randi() % len(rails)]
		rails.erase(rail)
		var car = cop_car_scene.instance()
		car.can_shoot = false
		#car.emit_signal('set_pos', Vector2(1100, rail.y))
		car.position.x = 1100 + randf() * 200
		car.position.y = rail.y
		car.scale *= 0.5
		$Scene.add_child(car)
		cop_cars.append(car)

func wave():
	wave_time = rand_range(min_wave_time, max_wave_time)
	var wave_size = floor(rand_range(min_wave_size, max_wave_size))
	var rails = $Scene/Rails.lanes.duplicate()
	var num_rails = len(rails)
	while wave_size + len(rails) > num_rails:
		if len(rails) == 0:
			return
		var rail = rails[randi() % len(rails)]
		rails.erase(rail)
		var car = cop_car_scene.instance()
		#car.emit_signal('set_pos', Vector2(1100, rail.y))
		car.position.x = 1100 + randf() * 200
		car.position.y = rail.y
		car.scale *= 0.5
		$Scene.add_child(car)
		cop_cars.append(car)

func load_scene():
	cars_destroyed = 0
	game = game_scene.instance()
	add_child(game)
	chunks = []
	for i in range($Scene/Player.max_health):
		var chunk = $Scene/HealthChunk.duplicate()
		chunk.position.x = $Scene/HealthChunk.position.x * (i + 1)
		$Scene.add_child(chunk)
		chunks.append(chunk)
	$Scene/HealthChunk.visible = false
	player = $Scene/Player
	first_wave()

func reload_scene():
	cop_cars.clear()
	remove_child(game)
	game.queue_free()
	load_scene()

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		reload_scene()
	if player == null:
		return
	$Scene/RichTextLabel.text = 'Cop Cars Destroyed: ' + str(cars_destroyed)
	for i in range(len(chunks)):
		chunks[i].visible = i < $Scene/Player.health
	for i in range(len(cop_cars)):
		if not cop_cars[i]:
			cop_cars.erase(cop_cars[i])
			cars_destroyed += 1
			break
	if len(cop_cars) == 0:
		wave()
