extends Node2D


func _ready() -> void:
	seed("cherry".hash())
	$Platform/AnimationPlayer.seek(randf())
	$Platform2/AnimationPlayer.seek(randf())
	$Platform3/AnimationPlayer.seek(randf())
