# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright (c) 2021 moowool195@gmail.com.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the University nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# Description:
# Player.

extends KinematicBody2D

signal death

const JUMP_SPEED := -8.5
const DJUMP_SPEED := -7.0
const WALK_SPEED := 3.0
const WALL_SLIDE := 2.0
const WALL_JUMP := 9.0
const JUMP_DEACCEL := 0.45
const GRAVITY := 0.4
const MAX_FALL_SPEED := 9.4
const MAX_BULLET := 4

const BLOOD_CNT := 40
const MAX_BLOOD_CYCLES := 20

export(bool) var _check_for_slopes = false

var dead := false # Useless for now
var xscale := 1
var jump := false
var djump := false
var _xdir := 0.0
var hspeed := 0.0
var vspeed := 0.0
var _anim: String
var _bullet_array: Array = []
var _blood_cycles := 0
var _snap := Vector2.ZERO

var _bullet: PackedScene = preload("res://scenes/Bullet.tscn")

onready var _snd_jump: AudioStreamPlayer = $Sounds/Jump
onready var _snd_djump: AudioStreamPlayer = $Sounds/DJump
onready var _snd_death: AudioStreamPlayer = $Sounds/Death
onready var _snd_shoot: AudioStreamPlayer = $Sounds/Shoot
onready var _snd_wall_jump: AudioStreamPlayer = $Sounds/WallJump
onready var _mus_death: AudioStreamPlayer = $Sounds/DeathMus

onready var _bow_sprite: Sprite = $Bow
onready var _kid_sprite: Sprite = $Kid
onready var _anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if GameStats.difficulty == GameStats.DIFFICULTY_MEDIUM:
		_bow_sprite.show()
	flip(xscale)

func _unhandled_key_input(_event) -> void:
#	if Input.is_action_pressed("shoot"):
#		yield($Timer, "timeout")
#		_shoot()
	if Input.is_action_just_pressed("shoot"):
		$AutoFireTimer.start()
		if _bullet_array.size() < MAX_BULLET:
			_shoot()
	
	if Input.is_action_just_released("shoot"):
		$AutoFireTimer.stop()

func _physics_process(delta) -> void:
	if not dead:
		_set_snap()
		_set_h_mov()
		_set_jump()
		_set_v_mov()
		_set_wall_slide()
		_set_water()


		# move_and_slide multiplies velocity by delta, but we want pixel/frame movement
		# warning-ignore:return_value_discarded
		move_and_slide_with_snap(
				Vector2(hspeed,vspeed) / delta,
				_snap,
				Vector2.UP,
				true
		)

		# Animation
		_anim_player.play(_anim)
		
		if get_tree().get_frame() % 10 == 0\
				and Input.is_action_pressed("shoot")\
				and _bullet_array.size() < MAX_BULLET\
				and $AutoFireTimer.is_stopped():
			_shoot()

	# Blood
	elif _blood_cycles < MAX_BLOOD_CYCLES:
		_explode()
		_blood_cycles += 1

		# Can't shoot while exploding
		set_process_unhandled_key_input(false)
	# Can't move or shoot
	else:
		set_process_unhandled_key_input(false)
		set_physics_process(false)

func _set_snap() -> void:
	_snap = Vector2.ZERO
	# Slopes
	if _check_for_slopes:
		if is_on_slope():
			_snap = Vector2(0,18)

## Sets the jumping movement
## Plays jumping sounds
func _set_jump() -> void:
	if Input.is_action_pressed("jump"):
		_snap = Vector2.ZERO

		if Input.is_action_just_pressed("jump"):
			if not jump:
				jump = true
				vspeed = JUMP_SPEED

				_snd_jump.play()
			elif djump:
				djump = false
				vspeed = DJUMP_SPEED

				_snd_djump.play()

	elif Input.is_action_just_released("jump")and jump and vspeed < 0:
		vspeed *= JUMP_DEACCEL#/2

## Sets hspeed, which gets used in _physics_process
## Also sets xscale, and flips the player accordingly
func _set_h_mov() -> void:
	# Left right movement
	_xdir = Input.get_action_strength("right") \
			 - Input.get_action_strength("left")
	hspeed = _xdir * WALK_SPEED

	# Facing left or right
	if _xdir != 0:
		xscale = int(_xdir)
	flip(xscale)

## Sets vspeed, which gets used in _physics_process
## Sets _anim, which gets used in _physics_process
func _set_v_mov() -> void:
	if jump:
		vspeed = min(9, vspeed + GRAVITY)

		if vspeed < 0:
			_anim = "jump"
		else:
			_anim = "fall"

		if is_on_floor() and vspeed >= 0:
			jump = false
		elif is_on_ceiling():
			vspeed = 0.01 # Not exact physics logic, but it works
	else:
		vspeed = 0
		djump = true
		if not is_on_floor():
			jump = true

		if hspeed != 0:
			_anim = "run"
		else:
			_anim = "idle"

func _set_wall_slide() -> void:
	if $LVines.get_overlapping_bodies():
		flip(1)
		vspeed = 2
		_anim = "wall"

		if Input.is_action_pressed("jump") and Input.is_action_pressed("right"):
			hspeed = 15
			vspeed = -9
			_snd_wall_jump.play()

	if $RVines.get_overlapping_bodies():
		flip(-1)
		vspeed = 2
		_anim = "wall"

		if Input.is_action_pressed("jump") and Input.is_action_pressed("left"):
			hspeed = -15
			vspeed = -9
			_snd_wall_jump.play()

func _set_water() -> void:
	if is_in_water():
		vspeed = min(vspeed, 2)
		djump = 1

## Flips the character sprite simulating a change in scale.
## Godot has problems with continuously setting the scale to -1
# warning-ignore:shadowed_variable
func flip(xscale: int) -> void:
	match xscale:
		1:
			_kid_sprite.flip_h = false
			_kid_sprite.offset = Vector2(0,0)

		-1:
			_kid_sprite.flip_h = true
			_kid_sprite.offset = Vector2(3,0)

	_bow_sprite.flip_h = _kid_sprite.flip_h
	_bow_sprite.offset = _kid_sprite.offset

func _explode() -> void:
	var parent: Node = get_parent()

	var blood = preload("res://scenes/Blood.tscn")

	# warning-ignore:unused_variable
	for i in range(BLOOD_CNT):
		var b = blood.instance()
		parent.call_deferred("add_child", b)
		b.global_position = self.global_position

func _shoot() -> void:
	var bullet = _bullet.instance()

	get_parent().add_child(bullet)
	bullet.dir = xscale
	bullet.global_position = self.global_position

	_bullet_array.append(bullet)
	bullet.connect("hit", self, "_remove_bullet", [bullet])

	_snd_shoot.play()

func _remove_bullet(_body, bullet: KinematicBody2D) -> void:
	_bullet_array.erase(bullet)

func _death() -> void:
	#Shortcuts._reset()
	dead = true

	_snd_death.play()
	_mus_death.play()

	_kid_sprite.hide()
	_bow_sprite.hide()

	$Hazards.set_deferred("monitoring", false)

	emit_signal("death")

func is_on_slope() -> bool:
	if is_on_floor() and not $Slope.is_colliding():
		return true
	return false

func is_on_floor() -> bool:
	return not $Floor.get_overlapping_bodies().empty()

func is_in_water() -> bool:
	return not $Water.get_overlapping_bodies().empty()

func _on_Hazards_body_entered(_body: Node) -> void:
	_death()
