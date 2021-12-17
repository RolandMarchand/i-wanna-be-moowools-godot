extends KinematicBody2D

const JUMP_SPEED := -8.5
const DJUMP_SPEED := -7.0
const WALK_SPEED := 3.0
const JUMP_DEACCEL := 0.45
const MAX_FALL_SPEED := 9.4

var jump := false
var djump := false
var dead := false
var xdir := 0
var hspeed := 0.0
var vspeed := 0.0

func _physics_process(delta):
	xdir = Input.get_action_strength("ui_right") \
			 - Input.get_action_strength("ui_left")
	hspeed = xdir * WALK_SPEED
	
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
		vspeed = min(MAX_FALL_SPEED, vspeed + 0.4)
		
		if is_on_floor() and vspeed >= 0:
			jump = false
		elif is_on_ceiling():
			vspeed = 0
	
	if not jump:
		vspeed = 0
		djump = true
		if not is_on_floor():
			print(is_on_floor())
			jump = true
	
	move_and_slide(Vector2(hspeed,vspeed) / delta, Vector2.UP)
