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
# Singleton, saves the current game and settings on disk.
# Can also load, delete and revert saves.
#
# Todo:
# 1) Save screen capture with get_viewport().get_texture().get_data()
#    to show on the main menu' save screen.

extends Node

const ERASED = 1

const SAVE_PATH := "user://saves.cfg"

const DEFAULT_MASTER_VOL := -4.0
const DEFAULT_SOUND_VOL := -8.0
const DEFAULT_MUSIC_VOL := -8.0
const DEFAULT_FS := false
const DEFAULT_VSYNC := true
const DEFAULT_QUIET_BG := true

const SAVE1 := "save1"
const SAVE2 := "save2"
const SAVE3 := "save3"

# Keeps the record of this amount of saves
const MAX_SAVES := INF

var active_save: String setget set_active_save
var current_save: String = "tmp"

var tmp_save := {}

func _ready():
	load_settings()

## Writes the settings on disk
func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("settings", "fullscreen", OS.is_window_fullscreen())
	config.set_value("settings", "vsync", OS.is_vsync_enabled())
	config.set_value("settings", "quiet_bg", Music.is_quiet())

	config.set_value("volume", "master", AudioServer.get_bus_volume_db(0))
	config.set_value("volume", "sound", AudioServer.get_bus_volume_db(1))
	config.set_value("volume", "music", AudioServer.get_bus_volume_db(2))

	for action in InputMap.get_actions():
		config.set_value("controls", action, InputMap.get_action_list(action))

	# warning-ignore:return_value_discarded
	config.save("user://settings.cfg")



## Writes the save's proprieties to disk.
## The saved values are written as arrays, to preserve save history.
func save(save: String, position: Vector2, xscale: int = 1) -> void:
	if not _verify_save(save):
		return

	if save == "tmp":
		tmp_save = {
			"deaths": GameStats.deaths,
			"position": position,
			"xscale": xscale,
			"time": GameStats.time,
			"difficulty": GameStats.difficulty,
			"location": GameStats.location,
			"scene": GameStats.scene,
		}
		return


	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load(SAVE_PATH)

	if not config.has_section(save):
		config.set_value(save, "deaths", [GameStats.deaths])
		config.set_value(save, "position", [position])
		config.set_value(save, "xscale", [xscale])
		config.set_value(save, "time", [GameStats.time])
		config.set_value(save, "difficulty", [GameStats.difficulty])
		config.set_value(save, "location", [GameStats.location])
		config.set_value(save, "scene", [GameStats.scene])
	else:
		var prev_val: Array = []

		# Obvious room for optimization
		prev_val = config.get_value(save, "deaths")
		prev_val.append(GameStats.deaths)
		while prev_val.size() > MAX_SAVES:
			prev_val.pop_front()
		config.set_value(save, "deaths", prev_val)

		prev_val = config.get_value(save, "position")
		prev_val.append(position)
		while prev_val.size() > MAX_SAVES:
			prev_val.pop_front()
		config.set_value(save, "position", prev_val)

		prev_val = config.get_value(save, "xscale")
		prev_val.append(xscale)
		while prev_val.size() > MAX_SAVES:
			prev_val.pop_front()
		config.set_value(save, "xscale", prev_val)

		prev_val = config.get_value(save, "time")
		prev_val.append(GameStats.time)
		while prev_val.size() > MAX_SAVES:
			prev_val.pop_front()
		config.set_value(save, "time", prev_val)

		prev_val = config.get_value(save, "difficulty")
		prev_val.append(GameStats.difficulty)
		while prev_val.size() > MAX_SAVES:
			prev_val.pop_front()
		config.set_value(save, "difficulty", prev_val)

		prev_val = config.get_value(save, "location")
		prev_val.append(GameStats.location)
		while prev_val.size() > MAX_SAVES:
			prev_val.pop_front()
		config.set_value(save, "location", prev_val)

		prev_val = config.get_value(save, "scene")
		prev_val.append(GameStats.scene)
		while prev_val.size() > MAX_SAVES:
			prev_val.pop_front()
		config.set_value(save, "scene", prev_val)

	# warning-ignore:return_value_discarded
	config.save(SAVE_PATH)

## Loads the save's propriety to disk
func load_game(save: String) -> Dictionary:
	if not _verify_save(save):
		return {}

	if save == "tmp":
		return tmp_save

	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load(SAVE_PATH)

	if config.has_section(save):
		return {
			"deaths": config.get_value(save, "deaths")[-1],
			"position": config.get_value(save, "position")[-1],
			"xscale": config.get_value(save, "xscale")[-1],
			"time": config.get_value(save, "time")[-1],
			"difficulty": config.get_value(save, "difficulty")[-1],
			"location": config.get_value(save, "location")[-1],
			"scene": config.get_value(save, "scene")[-1],
			}
	else:
		return {}

func delete_save(save: String):
	if not _verify_save(save):
		return

	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load(SAVE_PATH)

	config.erase_section(save)

	# warning-ignore:return_value_discarded
	config.save(SAVE_PATH)

func set_active_save(save: String) -> void:
	if not _verify_save(save):
		return

	current_save = save

	var data: Dictionary = load_game(save)

	if data:
		GameStats.deaths = data["deaths"]
		GameStats.time = data["time"]
		GameStats.difficulty = data["difficulty"]
		GameStats.location = data["location"]
		GameStats.scene = data["scene"]
	else:
		GameStats.time = 0

func revert_last_save(save: String) -> int:
	if not _verify_save(save):
		return ERR_UNAVAILABLE

	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load(SAVE_PATH)

	for el in ["deaths", "position", "xscale", "time", "difficulty", "location", "scene"]:
		var values: Array = config.get_value(save, el)
		if values:
			values.pop_back()

			if values.empty():
				config.erase_section(save)
				# warning-ignore:return_value_discarded
				config.save(SAVE_PATH)
				return 1

			config.set_value(save, el, values)
		else:
			push_warning("No " + el + " element to be reverted.")

	# warning-ignore:return_value_discarded
	config.save(SAVE_PATH)
	return 0

## Reads the settings from disk
func load_settings() -> void:
	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load("user://settings.cfg")

	OS.set_window_fullscreen(config.get_value("settings", "fullscreen", DEFAULT_FS))
	OS.set_use_vsync(config.get_value("settings", "vsync", DEFAULT_VSYNC))
	Music.set_quiet(config.get_value("settings", "quiet_bg", DEFAULT_QUIET_BG))

	AudioServer.set_bus_volume_db(0, config.get_value("volume", "master", DEFAULT_MASTER_VOL))
	AudioServer.set_bus_volume_db(1, config.get_value("volume", "sound", DEFAULT_SOUND_VOL))
	AudioServer.set_bus_volume_db(2, config.get_value("volume", "music", DEFAULT_MUSIC_VOL))

	for action in config.get_section_keys("controls"):
		InputMap.action_erase_events(action)
		for event in config.get_value("controls", action):
			InputMap.action_add_event(action, event)

## Resets settings to their default states
func default_settings() -> void:
	OS.set_window_fullscreen(DEFAULT_FS)
	OS.set_use_vsync(DEFAULT_VSYNC)
	Music.set_quiet(DEFAULT_QUIET_BG)

	AudioServer.set_bus_volume_db(0, DEFAULT_MASTER_VOL)
	AudioServer.set_bus_volume_db(1, DEFAULT_SOUND_VOL)
	AudioServer.set_bus_volume_db(2, DEFAULT_MUSIC_VOL)

func _verify_save(save: String) -> bool:
	match save:
		"save1":
			return true
		"save2":
			return true
		"save3":
			return true
		"tmp":
			return true
		_:
			push_error("Save " + save + " does not exist.")
			return false
