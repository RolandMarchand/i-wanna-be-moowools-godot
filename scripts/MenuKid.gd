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

# Description:
# The kid on the title screen.

# Todo:
# 1) Add bullets to destroy spikes.
# 2) Jump animation.

extends KinematicBody2D

signal looped

const GRAVITY := 0.5
const SPEED := 3.0
const JUMP := -10.0

var _loop_counter := 0
var _velocity := Vector2()

var _jump := true
var _djump := true

func _physics_process(delta) -> void:
	_velocity.x = SPEED

	if is_on_floor():
		_jump = true
		_djump = true

	if Input.is_action_just_pressed("jump") and (_jump or _djump):
		_velocity.y = JUMP

		if _jump:
			_jump = false
		elif _djump:
			_djump = false

	# warning-ignore:return_value_discarded
	move_and_slide(_velocity / delta, Vector2.UP)

	# Gravity
	_velocity.y += GRAVITY

	# Loops around the screen
	if position.x > 852:
		_loop_counter += 1
		emit_signal("looped", _loop_counter)
		position.x = -64

## Loops kid back at the beginning if hit
func _on_Hitbox_area_entered(_area) -> void:
	# Randomizes travels
	position.x = (randi() % 128 + 64) * -1
