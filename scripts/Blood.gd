extends KinematicBody2D

var _hspeed: float
var _vspeed: float
var _stuck := false
var _grav: float
var _coll: bool = false

var _blood0 = preload("res://sprites/sprBlood_0.png")
var _blood1 = preload("res://sprites/sprBlood_1.png")
var _blood2 = preload("res://sprites/sprBlood_2.png")
var _blood_array: Array = [_blood0, _blood1, _blood2]

onready var sprite: Sprite = $Sprite

func _ready():
	_set_speed()
	_set_grav()

	var blood = randi() % _blood_array.size()
	sprite.texture = _blood_array[blood]

func _physics_process(delta):
	_vspeed += _grav

	if not _stuck:
		move_and_slide(Vector2(_hspeed, _vspeed) / delta)
	else:
		set_physics_process(false)

	if _coll and randf() > 0.5:
		_stuck = true

func _set_speed() -> void:
	var d = floor(randf() * 36) * 10
	var s = randf() * 6

	_hspeed = cos(deg2rad(d)) * s
	_vspeed = -sin(deg2rad(d)) * s

func _set_grav():
	_grav = 0.1 + randf() * 0.2

func _on_Hitbox_body_entered(body):
	_coll = true

func _on_Hitbox_body_exited(body):
	_coll = false
