extends KinematicBody2D

const JUMP_SPEED := -8.5
const DJUMP_SPEED := -7.0
const WALK_SPEED := 3.0
const JUMP_DEACCEL := 0.45
const MAX_FALL_SPEED := 9.4
const VALIGN := 0.4

const BLOOD_CNT := 200

# The kid hovers 0.4 pixels above the ground, so is_on_floor() does not work
var is_on_floor := false
var jump := false
var djump := false
var dead := false
var xdir := 0.0
var hspeed := 0.0
var vspeed := 0.0
var anim: String

var snd_jump1: AudioStream = preload("res://audio/sndJump.wav")
var snd_djump1: AudioStream = preload("res://audio/sndDJump.wav")
var snd_shoot: AudioStream = preload("res://audio/sndShoot.wav")
var snd_death: AudioStream = preload("res://audio/sndDeath.wav")

var _blood: PackedScene = preload("res://scenes/Blood.tscn")

onready var sound: AudioStreamPlayer = $AudioStreamPlayer
onready var sprite: Sprite = $Sprite
onready var floor_detect: Area2D = $FloorDetectArea
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var col_shape: CollisionShape2D = $CollisionShape2D

func _physics_process(delta):

	xdir = Input.get_action_strength("ui_right") \
			 - Input.get_action_strength("ui_left")
	hspeed = xdir * WALK_SPEED
	_flip(xdir)

	if Input.is_action_pressed("ui_up"):
		if Input.is_action_just_pressed("ui_up"):
			if not jump:
				jump = true
				vspeed = JUMP_SPEED
			elif djump:
				djump = false
				vspeed = DJUMP_SPEED

	elif jump and vspeed < 0:
		vspeed *= JUMP_DEACCEL

	if jump:
		vspeed = min(MAX_FALL_SPEED, vspeed + VALIGN)

		if vspeed < 0:
			anim = "jump"
		else:
			anim = "fall"

		if is_on_floor and vspeed >= 0:
			jump = false
		elif is_on_ceiling():
			vspeed = 0.01 # Not exact physics logic, but it works

	if not jump:
		vspeed = 0
		djump = true
		if not is_on_floor:
			jump = true

		if hspeed != 0:
			anim = "run"
		else:
			anim = "idle"

	# move_and_slide multiplies velocity by delta, but we want pixel/frame movement
	# warning-ignore:return_value_discarded
	move_and_slide(Vector2(hspeed,vspeed) / delta, Vector2.UP)
	anim_player.play(anim)

## Flips the character sprite simulating a change in scale.
## Godot has problems with continuously setting the scale to -1
func _flip(xscale: int) -> void:
	match xscale:
		1:
			sprite.flip_h = false
			sprite.offset = Vector2(0,0)
		-1:
			sprite.flip_h = true
			sprite.offset = Vector2(3,0)

func _explode() -> void:
	for i in range(BLOOD_CNT):
		var blood = _blood.instance()
		get_parent().add_child(blood)
		blood.global_position = self.global_position

func _on_FloorDetectArea_body_entered(_body) -> void:
	is_on_floor = true

func _on_FloorDetectArea_body_exited(_body) -> void:
	is_on_floor = false
