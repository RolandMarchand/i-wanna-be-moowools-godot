extends KinematicBody2D

const JUMP_SPEED := -8.5
const DJUMP_SPEED := -7.0
const WALK_SPEED := 3.0
const JUMP_DEACCEL := 0.45
const MAX_FALL_SPEED := 9.4
const VALIGN := 0.4

# The kid hovers 0.4 pixels above the ground, so is_on_floor() does not work
var is_on_floor := false
var jump := false
var djump := false
var dead := false
var xdir := 0.0
var hspeed := 0.0
var vspeed := 0.0
var anim: String

onready var sprite: Sprite = $Sprite
onready var floor_detect: Area2D = $FloorDetectArea
onready var anim_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta):
	xdir = Input.get_action_strength("ui_right") \
			 - Input.get_action_strength("ui_left")
	hspeed = xdir * WALK_SPEED
	match xdir:
		-1.0:
			sprite.flip_h = true
		1.0:
			sprite.flip_h = false

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


func _on_FloorDetectArea_body_entered(_body):
	is_on_floor = true

func _on_FloorDetectArea_body_exited(_body):
	is_on_floor = false
