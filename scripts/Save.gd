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
# Manages the settings and game saves' permanent states.

# Todo:
# 1) Save screen capture with get_viewport().get_texture().get_data()
#    to show on the main menu' save screen.

extends Node

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
var current_save: String

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

	# warning-ignore:return_value_discarded
	config.save("user://settings.cfg")


## Writes the save's proprieties to disk.
## The saved values are written as arrays, to preserve save history.
func save(save: String, position: Vector2, xscale: int = 1) -> void:
	_verify_save(save)

	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load("user://saves.cfg")

	if not config.has_section(save):
		config.set_value(save, "deaths", [GameStats.deaths])
		config.set_value(save, "position", [position])
		config.set_value(save, "xscale", [xscale])
		config.set_value(save, "time", [GameStats.time])
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

	# warning-ignore:return_value_discarded
	config.save("user://saves.cfg")

## Loads the save's propriety to disk
func load_game(save: String) -> Dictionary:
	_verify_save(save)

	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load("user://saves.cfg")

	# warning-ignore:shadowed_variable
	var deaths := 0
	if config.has_section_key(save, "deaths"):
		deaths = config.get_value(save, "deaths")[-1]

	var position := Vector2()
	if config.has_section_key(save, "position"):
		position = config.get_value(save, "position")[-1]

	var xscale := 1
	if config.has_section_key(save, "xscale"):
		xscale = config.get_value(save, "xscale")[-1]

	var time = 0
	if config.has_section_key(save, "time"):
		time = config.get_value(save, "time")[-1]

	return {
		"deaths": deaths,
		"position": position,
		"xscale": xscale,
		"time": time,
		}

func delete_save(save: String):
	_verify_save(save)


	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load("user://saves.cfg")

	config.erase_section(save)

func set_active_save(save: String):
	_verify_save(save)

	current_save = save

	var data: Dictionary = load_game(save)

	GameStats.deaths = data["deaths"]
	GameStats.time = data["time"]

func revert_last_save(save: String):
	_verify_save(save)

	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load("user://saves.cfg")

	for prop in ["deaths", "position", "xscale"]:
		var values: Array = config.get_value(save, prop)
		config.set_value(save, prop, values.pop_back())

## Reads the settings from disk
func load_settings() -> void:
	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load("user://settings.cfg")

	print_debug(config.get_value("volume", "master", DEFAULT_MASTER_VOL))
	OS.set_window_fullscreen(config.get_value("settings", "fullscreen", DEFAULT_FS))
	OS.set_use_vsync(config.get_value("settings", "vsync", DEFAULT_VSYNC))
	Music.set_quiet(config.get_value("settings", "quiet_bg", DEFAULT_QUIET_BG))

	AudioServer.set_bus_volume_db(0, config.get_value("volume", "master", DEFAULT_MASTER_VOL))
	AudioServer.set_bus_volume_db(1, config.get_value("volume", "sound", DEFAULT_SOUND_VOL))
	AudioServer.set_bus_volume_db(2, config.get_value("volume", "music", DEFAULT_MUSIC_VOL))

## Resets settings to their default states
func default_settings() -> void:
	OS.set_window_fullscreen(DEFAULT_FS)
	OS.set_use_vsync(DEFAULT_VSYNC)
	Music.set_quiet(DEFAULT_QUIET_BG)

	AudioServer.set_bus_volume_db(0, DEFAULT_MASTER_VOL)
	AudioServer.set_bus_volume_db(1, DEFAULT_SOUND_VOL)
	AudioServer.set_bus_volume_db(2, DEFAULT_MUSIC_VOL)

func _verify_save(save: String) -> void:
	match save:
		"save1":
			pass
		"save2":
			pass
		"save3":
			pass
		_:
			assert("Save " + save + " does not exist.")
