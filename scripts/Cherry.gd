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
# FOR ANY _dirECT, IN_dirECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# Description:
# Cherry logic.

extends KinematicBody2D

export(bool) var fall := false
export(Vector2) var _dir := Vector2.RIGHT
export(float) var speed := 2.0
export(float) var _len := 800

var fallen := false

func _ready() -> void:
	set_physics_process(false)
	$Area2D/CollisionShape2D.shape.extents.x = _len / 2
	$Area2D/CollisionShape2D.position.x = _len / 2 - 16
	$Area2D.rotate(_dir.angle())

func _on_VisibilityNotifier2D_screen_exited() -> void:
	if $VisibilityNotifier2D.is_on_screen() and not $AudioStreamPlayer.playing:
		queue_free()

func _physics_process(delta) -> void:
	# warning-ignore:return_value_discarded
	move_and_slide(_dir.clamped(1) * speed / delta)

func _on_Area2D_body_entered(_body) -> void:
	if fall and not fallen:
		$AudioStreamPlayer.play()
		set_physics_process(true)
		fallen = true

func _on_AudioStreamPlayer_finished():
	if $VisibilityNotifier2D.is_on_screen() and not $AudioStreamPlayer.playing:
		queue_free()
