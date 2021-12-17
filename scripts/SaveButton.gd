extends Area2D

onready var anim_player: AnimationPlayer = $AnimationPlayer

func _on_SaveButton_body_entered(_body):
	anim_player.play("saved")
	
	var kid: KinematicBody2D = get_tree().get_nodes_in_group("kid")[0]
	
	Save.pos = kid.global_position
	Save.xscale = kid.xscale
