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
# Audio settings in the main menu.

extends VBoxContainer


onready var _master := $VBoxContainer/MasterSlider
onready var _sound := $VBoxContainer/SoundSlider
onready var _music := $VBoxContainer/MusicSlider
onready var _quiet_bg := $VBoxContainer/QuietBG
onready var _audio_back := $Back
onready var _sound_test := $Test

func _ready() -> void:
	_refresh_settings()

func _refresh_settings() -> void:
	_master.value = db2linear(AudioServer.get_bus_volume_db(0))
	_sound.value = db2linear(AudioServer.get_bus_volume_db(1))
	_music.value = db2linear(AudioServer.get_bus_volume_db(2))
	_quiet_bg.pressed = Music.is_quiet()

	Save.save_settings()

func _test_audio() -> void:
	# Audio musn't be tested roguely
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or \
		Input.is_mouse_button_pressed(BUTTON_RIGHT) or \
		Input.is_mouse_button_pressed(BUTTON_WHEEL_UP) or \
		Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):

		_sound_test.play()

func _on_MasterSlider_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(0, linear2db(value))
	# Used to set quiet bg
	# Notifications are broken and signals don't exist :(
	Music.original_volume = linear2db(value)

	_test_audio()

	_refresh_settings()

func _on_SoundSlider_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(1, linear2db(value))

	_test_audio()

	_refresh_settings()

func _on_MusicSlider_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(2, linear2db(value))

	_refresh_settings()


func _on_QuietBG_toggled(button_pressed: bool) -> void:
	Music.set_quiet(button_pressed)

	_refresh_settings()
