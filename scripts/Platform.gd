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

const BASE_SPEED := 2.0

export(float) var speed = BASE_SPEED
export(String, "Horizontal", "Vertical") var direction = "Horizontal"

var kid: KinematicBody2D
var dir := 1

func _physics_process(delta) -> void:
	var vel: Vector2 = _set_vel()
	
	# move_and_slide multiplies by delta, we don't want that
	# warning-ignore:return_value_discarded
	move_and_slide(vel / delta)
	
	# Snaps kid
	if kid and kid.is_on_floor:
		# warning-ignore:return_value_discarded
		kid.move_and_slide(vel / delta)

func _set_vel() -> Vector2:
	var vel: Vector2
	
	# Warning! Vertical platforms not supported yet!
	match direction:
		"Horizontal":
			vel = Vector2(speed * dir, 0)
		"Vertical":
			vel = Vector2(0, speed * dir)
	
	return vel

## Platform switches side
func _on_Hitbox_body_entered(_body) -> void:
	dir *= -1

func _on_PlayerHitbox_body_entered(body) -> void:
	kid = body

func _on_PlayerHitbox_body_exited(_body) -> void:
	kid = null
