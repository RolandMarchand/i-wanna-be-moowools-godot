extends Node2D

onready var tween := $Tween

onready var spikes: Array = $Spikes.get_children()
var _delay := 0.0

func _ready():
	spikes.shuffle()
	
	_start_tween()

func _start_tween() -> void:
	for s in spikes:
		tween.interpolate_property(s, "position", s.position, s.position + Vector2(0,720), 6, Tween.TRANS_QUINT, Tween.EASE_IN, _delay)
		_delay += clamp(randf(), 0.3, 1.0) 
	
	_delay = 0.0
	tween.start()

func _reset_spike_pos() -> void:
	for s in spikes:
		s.position = s.position + Vector2(0,-750)

func _on_Tween_tween_completed(object, key):
	tween.remove(object, key)
	object.position -= Vector2(0,720)
	tween.interpolate_property(object, "position", object.position, object.position + Vector2(0,720), 6, Tween.TRANS_QUINT, Tween.EASE_IN, _delay)
