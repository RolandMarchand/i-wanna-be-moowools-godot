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
# Base scene.

extends Node2D

export(AudioStream) var background_music: AudioStream
export(String) var location_name := ""

onready var ui: CanvasLayer = $UI

func _ready() -> void:
	_connect_kid()

	GameStats.location = location_name
	GameStats.scene = filename

	# Saves when spawning and there are no saves yet
	if not Save.load_game(Save.current_save):
		Save.save(Save.current_save)

	_set_difficulty()
	_set_title_bar()
	_play_music()
	_hide_invisible()
	_set_camera()


func _connect_kid() -> void:
	for kid in get_tree().get_nodes_in_group("kid"):

		# warning-ignore:return_value_discarded
		kid.connect("death", self, "_on_Kid_death")

		# Load save
		var save: Dictionary = Save.load_game(Save.current_save)

		if save.get("scene", "") == filename:
			kid.global_position = save.get("position", kid.global_position)
			kid.xscale = save.get("xscale", kid.xscale)

func _on_Kid_death() -> void:
	$GameOverTimer.start()
	Music.pause()

func _set_difficulty() -> void:
	for node in get_tree().get_nodes_in_group("difficulty"):
		if not node.is_in_group(GameStats.difficulty):
			node.queue_free()

# Hides invisible blocks depending on debug state
func _hide_invisible() -> void:
	if not get_tree().is_debugging_collisions_hint():
		for node in get_tree().get_nodes_in_group("invisible"):
			node.hide()

## Displays deaths in the title bar.
func _set_title_bar() -> void:
	OS.set_window_title(ProjectSettings.get_setting("application/config/name")
	+ " (deaths: " + str(GameStats.deaths) + ")")

# Doesn't restart music if the player dies or if the scene is reloaded
func _play_music() -> void:
	if not background_music:
		return

	if Music.get_last_song() != background_music:
		Music.play(background_music)
	elif Music.player.stream_paused:
		Music.player.stream_paused = false

## Locates where the kid is on the screen map and moves the camera over to
## the corresponding cell.
func _set_camera() -> void:
	for kid in get_tree().get_nodes_in_group("kid"):
		var cam: Camera2D = kid.camera
		var map: TileMap = $Camera/Map
		var area: Area2D = $Camera/Area2D

		var new_pos: Vector2 = map.map_to_world(
				map.world_to_map(kid.global_position)
			)
		area.global_position = new_pos

		cam.limit_top = int(new_pos.y)
		cam.limit_right = int(new_pos.x + map.cell_size.x)
		cam.limit_bottom = int(new_pos.y + map.cell_size.y)
		cam.limit_left = int(new_pos.x)

## Takes a screenshot of the stage.
## Taking a screenshot inside of the _ready function causes a bug
## where the menu is captured, because of the nature of change_scene
func _on_Timer_timeout() -> void:
	if not Screenshots.has_screenshot(Save.current_save, filename)\
			and Save.current_save != Save.TMP:
		Screenshots.take_screenshot()


func _on_GameOverTimer_timeout() -> void:
	ui.game_over()

func _on_Area2D_body_exited(_player: KinematicBody2D) -> void:
	_set_camera()
