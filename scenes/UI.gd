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

extends CanvasLayer

onready var _go: MarginContainer = $GameOver
onready var _menu: MarginContainer = $Menu

onready var _master: HSlider = $Menu/PanelContainer/VBoxContainer/HBoxContainer/HBoxContainer3/Master
onready var _sound: HSlider = $Menu/PanelContainer/VBoxContainer/HBoxContainer/HBoxContainer/Sound
onready var _music: HSlider = $Menu/PanelContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Music
onready var _fs: CheckBox = $Menu/PanelContainer/VBoxContainer/VBoxContainer/Fullscreen
onready var _quiet_bg: CheckBox = $Menu/PanelContainer/VBoxContainer/VBoxContainer/QuietBG
onready var _vsync: CheckBox = $Menu/PanelContainer/VBoxContainer/VBoxContainer/VSync
onready var _ok: Button = $Menu/PanelContainer/VBoxContainer/HBoxContainer5/Ok
onready var _back_ts: Button = $Menu/PanelContainer/VBoxContainer/HBoxContainer5/Back2Title

onready var _sound_test: AudioStreamPlayer = $Menu/PanelContainer/VBoxContainer/HBoxContainer/Test

func _ready():
	# warning-ignore:return_value_discarded
	Shortcuts.connect("paused", self, "set_menu_visible")

func game_over() -> void:
	_go.show() # Is hidden when scene is reloaded on reset

func set_menu_visible(visible: bool) -> void:
	if visible:
		_refresh_settings()

	_menu.set_visible(visible)


func _refresh_settings() -> void:
	_fs.pressed = OS.is_window_fullscreen()
	_vsync.pressed = OS.is_vsync_enabled()
	_quiet_bg.pressed = Music.is_quiet()
	_master.value = db2linear(AudioServer.get_bus_volume_db(0))
	_sound.value = db2linear(AudioServer.get_bus_volume_db(1))
	_music.value = db2linear(AudioServer.get_bus_volume_db(2))

func _test_audio():
	if not Input.is_action_just_pressed("pause"):
		_sound_test.play()

func _on_Ok_pressed():
	_menu.hide()
	get_tree().set_pause(false)

## Title screen to be implemented
func _on_Back2Title_pressed():
	pass # Replace with function body.


func _on_VSync_pressed():
	OS.set_use_vsync(_vsync.is_pressed())


func _on_QuietBG_pressed():
	Music.set_quiet(_quiet_bg.is_pressed())


func _on_Fullscreen_pressed():
	OS.set_window_fullscreen(_fs.is_pressed())

func _on_Sound_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear2db(value))

	# Don't test the sound when the menu appears
	_test_audio()

func _on_Music_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear2db(value))


func _on_Master_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear2db(value))

	# Don't test the sound when the menu appears
	_test_audio()
