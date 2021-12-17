extends Node2D

var mus_death: AudioStream = preload("res://audio/musOnDeath.mp3")

func _ready():
	for kid in get_tree().get_nodes_in_group("kid"):
		kid.connect("death", self, "_on_Kid_death")
		
		if Save.pos:
			kid.global_position = Save.pos
		if Save.xscale:
			kid.xscale = Save.xscale

func _on_Kid_death():
	$GameOver/MarginContainer.show()
	
	$Music.stream = mus_death
	$Music.play()

func _unhandled_key_input(_event):
	if Input.is_action_just_pressed("reset"):
	# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()


func _on_Warp_body_entered(_body):
	get_tree().quit(0)
