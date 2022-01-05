extends Area2D

func _ready() -> void:
	$AnimationPlayer.seek(randf())

func _on_AirJump_body_entered(player: KinematicBody2D) -> void:
	player.djump = true
	$CollisionShape2D.set_deferred("disabled", true)
	hide()
	$Timer.start()


func _on_Timer_timeout():
	$CollisionShape2D.set_deferred("disabled", false)
	show()
