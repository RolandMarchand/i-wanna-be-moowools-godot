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
# Singleton, records stats such as deaths and time into memory.
#
# TODO:
# Replace the timer by an OS.get_ticks_msec recording.

extends Node

const DIFFICULTY_MEDIUM := "medium"
const DIFFICULTY_HARD := "hard"
const DIFFICULTY_VERY_HARD := "very hard"
const DIFFICULTY_IMPOSSIBLE := "impossible"

const START_SCENE := "res://scenes/screens/ExampleScene.tscn"

var _timer := Timer.new()

var deaths: int = 0
var time: int = 0 # Seconds since new game
var difficulty: String = DIFFICULTY_MEDIUM setget set_difficulty
var location: String
var scene: String
# Records the state of the scene, like if a trap has been enabled or not.
# Key: Could be anything, script's filename recommended
# Value: Whatever value you want stored
var state := {}

func _ready() -> void:
	_setup_timer()

func _setup_timer() -> void:
	_timer.wait_time = 1.0
	_timer.process_mode = Timer.TIMER_PROCESS_IDLE
	_timer.one_shot = false
	_timer.autostart = true
	# warning-ignore:return_value_discarded
	_timer.connect("timeout", self, "_on_timer_timeout")
	add_child(_timer)

func _on_timer_timeout() -> void:
	time += 1

func set_difficulty(dif: String) -> void:
	match dif:
		DIFFICULTY_MEDIUM:
			pass
		DIFFICULTY_HARD:
			pass
		DIFFICULTY_VERY_HARD:
			pass
		DIFFICULTY_IMPOSSIBLE:
			pass
		_:
			push_error("Difficulty " + dif + " does not exist.")
			return

	difficulty = dif
