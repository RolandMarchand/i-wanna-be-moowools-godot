extends Node2D

func _ready():
	for kid in get_tree().get_nodes_in_group("kid"):
		print(kid)
		kid.connect("death", self, "_on_Kid_death")

func _on_Kid_death():
	$GameOver/MarginContainer.show()
	$DeathMusic.play()

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _on_Warp_body_entered(body):
	get_tree().quit(0)
