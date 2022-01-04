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

onready var _master: HSlider = $Menu/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer3/Master
onready var _sound: HSlider = $Menu/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/Sound
onready var _music: HSlider = $Menu/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer2/Music
onready var _fs: Button = $Menu/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer/Fullscreen
onready var _change_bg: Button = $Menu/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer/Fullscreen/ChangeBG
onready var _quiet_bg: Button = $Menu/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer/QuietBG
onready var _vsync: Button = $Menu/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer/VSync
onready var _ok: Button = $Menu/NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer5/VBoxContainer2/Ok
onready var _back_ts: Button = $Menu/NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer5/VBoxContainer2/Back2Title
onready var _hide: Button = $Menu/NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer5/VBoxContainer/Hide
onready var _show: Button = $Show

onready var _sound_test: AudioStreamPlayer = $Menu/NinePatchRect/MarginContainer/VBoxContainer/VBoxContainer2/Test

func _ready() -> void:
	# warning-ignore:return_value_discarded
	Shortcuts.connect("paused", self, "_set_menu_visible")
	# warning-ignore:return_value_discarded
	Shortcuts.connect("fullscreen", self, "_refresh_settings")

	_refresh_settings()

func game_over() -> void:
	_go.show() # Is hidden when scene is reloaded on reset

func _set_menu_visible(visible: bool) -> void:
	_menu.set_visible(visible)
	_show.set_visible(false)

	_refresh_settings()

func _refresh_settings() -> void:
	_fs.pressed = OS.is_window_fullscreen()
	_vsync.pressed = OS.is_vsync_enabled()
	_quiet_bg.pressed = Music.is_quiet()
	_master.value = db2linear(AudioServer.get_bus_volume_db(0))
	_sound.value = db2linear(AudioServer.get_bus_volume_db(1))
	_music.value = db2linear(AudioServer.get_bus_volume_db(2))
	_change_bg.disabled = not OS.is_window_fullscreen()

	if _change_bg.disabled:
		_change_bg.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	else:
		_change_bg.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	Save.save_settings()

func _test_audio() -> void:
	# Audio musn't be tested roguely
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or \
		Input.is_mouse_button_pressed(BUTTON_RIGHT) or \
		Input.is_mouse_button_pressed(BUTTON_WHEEL_UP) or \
		Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):

		_sound_test.play()

	_refresh_settings()

func _on_Ok_pressed() -> void:
	_menu.hide()
	get_tree().set_pause(false)

	_refresh_settings()

func _on_Back2Title_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/menu/Menu.tscn")

	_refresh_settings()

func _on_Master_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(0, linear2db(value))
	# Used to set quiet bg
	# Notifications are broken and signals don't exist :(
	Music.original_volume = linear2db(value)

	_test_audio()

	_refresh_settings()

func _on_Sound_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(1, linear2db(value))

	_test_audio()

	_refresh_settings()

func _on_Music_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(2, linear2db(value))

	_refresh_settings()

func _on_Button_pressed() -> void:
	_show.hide()
	_menu.show()

	_refresh_settings()

func _on_Hide_pressed() -> void:
	_menu.hide()
	_show.show()

	_refresh_settings()


func _on_Fullscreen_toggled(button_pressed: bool) -> void:
	OS.set_window_fullscreen(button_pressed)

	_refresh_settings()


func _on_Vsync_toggled(button_pressed: bool) -> void:
	OS.set_use_vsync(button_pressed)

	_refresh_settings()


func _on_QuietBG_toggled(button_pressed) -> void:
	Music.set_quiet(button_pressed)

	_refresh_settings()


func _on_ChangeBG_pressed():
	BlackBars.next_bg_img()

	_refresh_settings()


func _on_Default_pressed() -> void:
	Save.default_settings()

	_refresh_settings()
