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
# Animates the falling spikes from the title screen

extends Node2D

onready var tween := $Tween

onready var spikes: Array = $Spikes.get_children()
var _delay := 0.0
var _fall_time := 6.0

func _ready() -> void:
	# Randomizes the order of fallen spikes
	randomize()
	spikes.shuffle()

	_start_tween()

func _start_tween() -> void:
	for s in spikes:
		tween.interpolate_property(s,
		"position",
		s.position,
		s.position + Vector2(0,720),
		_fall_time,
		Tween.TRANS_QUINT,
		Tween.EASE_IN,
		_delay)

		_delay += clamp(randf(), 0.3, 1.0)

	_delay = 0.0
	tween.start()

func _reset_spike_pos() -> void:
	for s in spikes:
		s.position = s.position + Vector2(0,-720)

## Resets and reanimates each fallen spike
func _on_Tween_tween_completed(spike, pos):
	tween.remove(spike, pos)
	spike.position -= Vector2(0,720)
	tween.interpolate_property(spike,
			"position",
			spike.position,
			spike.position + Vector2(0,720),
			_fall_time, Tween.TRANS_QUINT,
			Tween.EASE_IN,
			_delay)
