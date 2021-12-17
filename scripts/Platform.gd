extends KinematicBody2D

const BASE_SPEED := 2.0

export(float) var speed = BASE_SPEED
# Binary flags
export(String, "Horizontal", "Vertical") var direction = "Horizontal"

var kid: KinematicBody2D
var dir := 1

func _physics_process(delta):
	var vel: Vector2
	match direction:
		"Horizontal":
			vel = Vector2(speed * dir, 0) / delta
		"Vertical":
			vel = Vector2(0, speed * dir) / delta
	
	move_and_slide(vel)
	
	if kid and kid.is_on_floor:
		print("lmao")
		kid.move_and_slide(vel)

func _on_Hitbox_body_entered(body):
	dir *= -1


func _on_PlayerHitbox_body_entered(body):
	kid = body


func _on_PlayerHitbox_body_exited(body):
	kid = null
