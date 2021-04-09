extends Node2D

export var velocity = Vector2(100, 0)

func _physics_process(delta):
	if position.x < 0 or position.x > 1080 or position.y < 0 or position.y > 600:
		queue_free()
	self.position += velocity * delta
	self.rotation = velocity.angle()
	
func _on_Bullet_area_entered(area):
	if area.is_in_group("player"):
		area.emit_signal("damage", 1)
