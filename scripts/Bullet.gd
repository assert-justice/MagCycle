extends Node2D

export var velocity = Vector2(100, 0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	self.position += velocity * delta
	self.rotation = velocity.angle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
