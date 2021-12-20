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
var dead := false # Useless for now
var xscale := 1
var _jump := false
var _djump := false
var _xdir := 0.0
var _hspeed := 0.0
var _vspeed := 0.0
var _anim: String
var _bullet_array: Array = []

var _bullet: PackedScene = preload("res://scenes/Bullet.tscn")
var _blood: PackedScene = preload("res://scenes/Blood.tscn")

onready var _snd_jump: AudioStreamPlayer = $Sounds/Jump
onready var _snd_djump: AudioStreamPlayer = $Sounds/DJump
onready var _snd_death: AudioStreamPlayer = $Sounds/Death
onready var _snd_shoot: AudioStreamPlayer = $Sounds/Shoot

onready var _sprite: Sprite = $Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_flip(xscale)

func _unhandled_key_input(_event) -> void:
	if Input.is_action_just_pressed("shoot") and _bullet_array.size() < MAX_BULLET:
		_shoot()

func _physics_process(delta) -> void:
	_set_h_mov()
	_set_jump()
	_set_v_mov()

	# move_and_slide multiplies velocity by delta, but we want pixel/frame movement
	# warning-ignore:return_value_discarded
	move_and_slide(Vector2(_hspeed,_vspeed) / delta, Vector2.UP)

	# Animation
	_anim_player.play(_anim)

## Sets the jumping movement
## Plays jumping sounds
func _set_jump() -> void:
	if Input.is_action_pressed("jump"):
		if Input.is_action_just_pressed("jump"):
			if not _jump:
				_jump = true
				_vspeed = JUMP_SPEED

				_snd_jump.play()
			elif _djump:
				_djump = false
				_vspeed = DJUMP_SPEED

				_snd_djump.play()

	elif Input.is_action_just_released("jump") and _jump and _vspeed < 0:
		_vspeed *= JUMP_DEACCEL

## Sets _hspeed, which gets used in _physics_process
## Also sets xscale, and flips the player accordingly
func _set_h_mov() -> void:
	# Left right movement
	_xdir = Input.get_action_strength("ui_right") \
			 - Input.get_action_strength("ui_left")
	_hspeed = _xdir * WALK_SPEED

	# Facing left or right
	if _xdir != 0:
		xscale = int(_xdir)
	_flip(xscale)

## Sets _vspeed, which gets used in _physics_process
## Sets _anim, which gets used in _physics_process
func _set_v_mov() -> void:
	if _jump:
		_vspeed = min(MAX_FALL_SPEED, _vspeed + VALIGN)

		if _vspeed < 0:
			_anim = "jump"
		else:
			_anim = "fall"

		if is_on_floor and _vspeed >= 0:
			_jump = false
		elif is_on_ceiling():
			_vspeed = 0.01 # Not exact physics logic, but it works

	if not _jump:
		_vspeed = 0
		_djump = true
		if not is_on_floor:
			_jump = true

		if _hspeed != 0:
			_anim = "run"
		else:
			_anim = "idle"

## Flips the character sprite simulating a change in scale.
## Godot has problems with continuously setting the scale to -1
# warning-ignore:shadowed_variable
func _flip(xscale: int) -> void:
	match xscale:
		1:
			_sprite.flip_h = false
			_sprite.offset = Vector2(0,0)
		-1:
			_sprite.flip_h = true
			_sprite.offset = Vector2(3,0)

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
	# warning-ignore:unused_variable
	for i in range(BLOOD_CNT):
		var blood = _blood.instance()
		get_parent().call_deferred("add_child", blood)
		blood.set_deferred("global_position", self.global_position)

func _shoot() -> void:
	var bullet = _bullet.instance()

	get_parent().add_child(bullet)
	bullet.dir = xscale
	bullet.global_position = self.global_position

	_bullet_array.append(bullet)
	bullet.connect("hit", self, "_remove_bullet")

	_snd_shoot.play()

func _remove_bullet(_body) -> void:
	_bullet_array.pop_front()

func _death() -> void:
	dead = true # Useless for now
	#_explode()
	_snd_death.play()
	_sprite.hide()
	emit_signal("death")

	# Can't move or shoot
	set_process_unhandled_key_input(false)
	set_physics_process(false)

func _on_FloorDetectArea_body_entered(_body) -> void:
	is_on_floor = true

func _on_FloorDetectArea_body_exited(_body) -> void:
	is_on_floor = false

func _on_SpikeHitbox_body_entered(_body) -> void:
	_death()
