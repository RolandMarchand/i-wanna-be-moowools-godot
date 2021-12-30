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

const DEFAULT_MASTER_VOL := -4.0
const DEFAULT_SOUND_VOL := -8.0
const DEFAULT_MUSIC_VOL := -8.0
const DEFAULT_FS := false
const DEFAULT_VSYNC := true
const DEFAULT_QUIET_BG := true

var deaths: int = 0
var pos: Vector2
var xscale: int

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

func save_game(save: String) -> void:
	_verify_save(save)

	var config := ConfigFile.new()

	config.set_value(save, "deaths", deaths)
	config.set_value(save, "position", pos)
	config.set_value(save, "xscale", xscale)

	# warning-ignore:return_value_discarded
	config.save("user://saves.cfg")

func load_game(save: String) -> void:
	_verify_save(save)

	var config := ConfigFile.new()
	# warning-ignore:return_value_discarded
	config.load("user://saves.cfg")

	deaths = config.get_value(save, "deaths", 0)
	pos = config.get_value(save, "position")
	xscale = config.get_value(save, "xscale")


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
