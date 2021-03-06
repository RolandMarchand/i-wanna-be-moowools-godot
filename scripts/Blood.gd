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
# Blood droplet from the player's death.

extends KinematicBody2D

var _hspeed: float
var _vspeed: float
var _stuck := false
var _grav: float
var _coll: bool = false

var _blood_array: Array = [
		preload("res://sprites/sprBlood_0.png"),
		preload("res://sprites/sprBlood_1.png"),
		preload("res://sprites/sprBlood_2.png"),
		]

onready var sprite: Sprite = $Sprite

func _ready() -> void:
	_set_speed()
	_set_grav()

	# Chooses random blood texture
	sprite.texture = _blood_array[floor(randf() * 3)]

func _physics_process(_delta) -> void:
	_vspeed += _grav

	if _coll and randf() > 0.5:
		_stuck = true

	# Stops the droplet
	if not _stuck:
		# warning-ignore:return_value_discarded
		if move_and_collide(Vector2(_hspeed, _vspeed)):
			_stuck = true
	else:
		set_physics_process(false)

func _set_speed() -> void:
	var d = floor(randf() * 36) * 10
	var s = randf() * 6

	_hspeed = cos(deg2rad(d)) * s
	_vspeed = -sin(deg2rad(d)) * s

func _set_grav() -> void:
	_grav = 0.1 + randf() * 0.2

func _on_Hitbox_body_entered(_body: Node) -> void:
	_coll = true

	if randf() > 0.5:
		_stuck = true

func _on_Hitbox_body_exited(_body) -> void:
	_coll = false
