extends Node

var audio_player := AudioStreamPlayer.new()

var mus_rock: AudioStream = preload("res://audio/musGuyRock.mp3")

func _ready():
	add_child(audio_player)
	
	audio_player.stream = mus_rock
	audio_player.play()
