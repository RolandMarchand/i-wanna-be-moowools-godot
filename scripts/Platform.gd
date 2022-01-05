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
extends Node2D

const BASE_SPEED := 2.0

var _path: Array = []
var _playback_pos := 0
var velocity: Vector2

onready var body := $KinematicBody2D

export(float) var speed: float = BASE_SPEED
export(bool) var _snap := true
export(bool) var _drag := true

func _ready():
	_gen_path()
	if not $AnimationPlayer.autoplay:
		_next_tween()
		$Tween.start()

func _physics_process(delta):
	if _drag:
		for player in $KinematicBody2D/Drag.get_overlapping_bodies():
			player.djump = true
			player.move_and_slide(velocity / delta)

func _next_tween() -> void:
	var duration = _get_tween_duration(_path[_playback_pos].distance_to(_path[_playback_pos + 1]))
	velocity = _path[_playback_pos].direction_to(_path[_playback_pos + 1]).normalized() * speed

	$Tween.interpolate_property($KinematicBody2D, "global_position", _path[_playback_pos], _path[_playback_pos + 1], duration)

	_playback_pos += 1
	_playback_pos %= _path.size() - 1


func _get_tween_duration(distance: float) -> float:
	return distance / (speed * 50)

func _gen_path() -> void:
	_path.clear()

	for point in $KinematicBody2D/Trajectory.get_children():
		_path.append(point.global_position)


func _on_Tween_tween_completed(_object, _key):
	_next_tween()
	$Tween.start()


func _on_Snap_area_entered(area):
	if _snap:
		var player = area.get_parent()
		player.global_position.y = global_position.y - 8.5 - 8 # player and platform height
		player.jump = false
