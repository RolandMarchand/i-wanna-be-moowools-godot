tool
extends KinematicBody2D

func _physics_process(delta):
	move_and_slide(Vector2(3,0) / delta)
	
	if position.x > 852:
		position.x = -64


func _on_Hitbox_area_entered(area):
	position.x = (randi() % 128 + 64) * -1
