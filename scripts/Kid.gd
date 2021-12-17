extends KinematicBody2D

signal death

const JUMP_SPEED := -8.5
const DJUMP_SPEED := -7.0
const WALK_SPEED := 3.0
const JUMP_DEACCEL := 0.45
const MAX_FALL_SPEED := 9.4
const VALIGN := 0.4
const MAX_BULLET := 3

const BLOOD_CNT := 200

# The kid hovers 0.4 pixels above the ground, so is_on_floor() does not work
var is_on_floor := false
var jump := false
var djump := false
var dead := false
var xdir := 0.0
var old_xdir := 1
var hspeed := 0.0
var vspeed := 0.0
var anim: String
var bullet_array: Array = []

var snd_jump: AudioStream = preload("res://audio/sndJump.wav")
var snd_djump: AudioStream = preload("res://audio/sndDJump.wav")
var snd_shoot: AudioStream = preload("res://audio/sndShoot.wav")
var snd_death: AudioStream = preload("res://audio/sndDeath.wav")

var _bullet: PackedScene = preload("res://scenes/Bullet.tscn")
var _blood: PackedScene = preload("res://scenes/Blood.tscn")

onready var audio: AudioStreamPlayer = $AudioStreamPlayer
onready var sprite: Sprite = $Sprite
onready var floor_detect: Area2D = $FloorDetectArea
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var col_shape: CollisionShape2D = $CollisionShape2D

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("shoot") and bullet_array.size() < MAX_BULLET:
		_shoot()


func _physics_process(delta):
	xdir = Input.get_action_strength("ui_right") \
			 - Input.get_action_strength("ui_left")
	hspeed = xdir * WALK_SPEED

	if xdir != 0:
		old_xdir = xdir

	_flip(xdir)

	if Input.is_action_pressed("jump"):
		if Input.is_action_just_pressed("jump"):
			if not jump:
				jump = true
				vspeed = JUMP_SPEED

				_sound_play(snd_jump)
			elif djump:
				djump = false
				vspeed = DJUMP_SPEED

				_sound_play(snd_djump)

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

## Laggy for expected 800 particles
##
## Godot could generate them when the scene loads and then hide them,
## when the player dies, the position of the explosion is set
## and the explosion is called
##
## Or create a system that's not node based
##
## Also shoots them all at once
func _explode() -> void:
	for i in range(BLOOD_CNT):
		var blood = _blood.instance()
		get_parent().call_deferred("add_child", blood)
		blood.set_deferred("global_position", self.global_position)

func _shoot():
	print(bullet_array.size())
	var bullet = _bullet.instance()

	get_parent().add_child(bullet)
	bullet.dir = old_xdir
	bullet.global_position = self.global_position

	bullet_array.append(bullet)
	bullet.connect("hit", self, "_remove_bullet")

	_sound_play(snd_shoot)


func _remove_bullet(_body) -> void:
	bullet_array.pop_front()

func _sound_play(sound: AudioStream) -> void:
	audio.stream = sound
	audio.play()

func _death() -> void:
	_explode()
	_sound_play(snd_death)
	sprite.hide()
	emit_signal("death")

	# Can't move or shoot
	set_process_unhandled_key_input(false)
	set_physics_process(false)

func _on_FloorDetectArea_body_entered(_body) -> void:
	is_on_floor = true

func _on_FloorDetectArea_body_exited(_body) -> void:
	is_on_floor = false

func _on_SpikeHitbox_body_entered(body):
	_death()

