extends KinematicBody2D

signal hit

const HSPEED := 16.0

var dir := 1

func _ready():
	scale.x *= dir

func _physics_process(delta):
	move_and_slide(Vector2(HSPEED * dir, 0) / delta)


func _on_Hitbox_body_entered(body):
	print("lmao")
	emit_signal("hit", body)
	queue_free()