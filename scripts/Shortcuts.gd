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

extends Node

signal reset
signal paused
signal fullscreen

# There probably is a more efficient way of doing this
var bg_img: RID = preload("res://sprites/bg_black.png").get_rid()

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	VisualServer.black_bars_set_images(bg_img, bg_img, bg_img, bg_img)

func _unhandled_key_input(_event):

	# Toggles pause
	if Input.is_action_just_pressed("pause"):
		var pause := not get_tree().is_paused()

		get_tree().set_pause(pause)
		emit_signal("paused", pause)

	if Input.is_action_just_pressed("reset"):
		if not get_tree().is_paused():
			_reset()
			emit_signal("reset")

	if Input.is_action_just_pressed("quit"):
		get_tree().quit(0)

	if Input.is_action_just_pressed("fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())
		emit_signal("fullscreen")

	# Implement boss skip
	if Input.is_action_just_pressed("skip"):
		pass

	# Implement going back to title screen
	if Input.is_action_just_pressed("title_screen"):
		pass

## Reset the scene, restarts music, increments the death counter
func _reset() -> void:
		Save.deaths += 1

		if not Music.is_playing():
			Music.play()

	# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
		get_tree().set_pause(false)

		OS.set_window_title("I Don't Wanna Be Game Maker! (deaths: "
				+ str(Save.deaths) + ")")
