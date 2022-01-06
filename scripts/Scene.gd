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
# Main scene.

extends Node2D

var mus_death: AudioStream = preload("res://audio/musOnDeath.mp3")
var mus_bg: AudioStream = preload("res://audio/musGuyRock.mp3")

var location := "GB Room"
var difficulty: String

var kid: KinematicBody2D

onready var ui: CanvasLayer = $UI

func _ready() -> void:
	_connect_kid()

	GameStats.location = location

	if GameStats.difficulty == GameStats.DIFFICULTY_IMPOSSIBLE:
		$SaveButton.queue_free()
		$SaveButton2.queue_free()

	# Saves when spawning and there are no saves yet
	if not Save.load_game(Save.current_save):
		Save.save(Save.current_save, kid.global_position, kid.xscale)

	# Display deaths in the title bar.
	OS.set_window_title(ProjectSettings.get_setting("application/config/name")
	+ " (deaths: " + str(GameStats.deaths) + ")")

	# Doesn't restart music if the player dies or if the scene is reloaded
	if Music.get_last_song() != mus_bg:
		Music.play(mus_bg)
	elif Music.player.stream_paused:
		Music.player.stream_paused = false

	# Hides invisible blocks depending on debug state
	if not get_tree().is_debugging_collisions_hint():
		for node in get_tree().get_nodes_in_group("invisible"):
			node.hide()


func _connect_kid() -> void:
	kid = get_tree().get_nodes_in_group("kid")[0]

	# warning-ignore:return_value_discarded
	kid.connect("death", self, "_on_Kid_death")

	# Load save
	var save: Dictionary = Save.load_game(Save.current_save)

	if save:
		kid.global_position = save["position"]
		kid.xscale = save["xscale"]

func _on_Kid_death() -> void:
	ui.game_over()
	Music.pause()

## Temporary
func _on_Warp_body_entered(_body) -> void:
	get_tree().quit(0)

## Takes a screenshot of the stage.
## Taking a screenshot inside of the _ready function causes a bug
## where the menu is captured, because of the nature of change_scene
func _on_Timer_timeout() -> void:
	if not Screenshots.has_screenshot(Save.current_save, filename):
		Screenshots.call_deferred("take_screenshot")
