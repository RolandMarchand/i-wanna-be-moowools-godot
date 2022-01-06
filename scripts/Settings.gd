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
# Controls settings in the main menu.

extends Control

onready var _vsync := $MarginContainer/Main/VBoxContainer2/Vsync
onready var _fs := $MarginContainer/Main/VBoxContainer2/Fullscreen
onready var _main_menu := $MarginContainer/Main
onready var _audio := $MarginContainer/Main/VBoxContainer2/Audio
onready var _controls_menu := $MarginContainer/Controls
onready var _back := $MarginContainer/Main/VBoxContainer/Back
onready var _audio_menu := $MarginContainer/Audio


func _ready() -> void:
	_refresh_settings()

func _refresh_settings() -> void:
	_fs.pressed = OS.is_window_fullscreen()
	_vsync.pressed = OS.is_vsync_enabled()

	Save.save_settings()

func _on_Fullscreen_toggled(button_pressed: bool) -> void:
	OS.set_window_fullscreen(button_pressed)

	_refresh_settings()

func _on_Vsync_toggled(button_pressed: bool) -> void:
	OS.set_use_vsync(button_pressed)

	_refresh_settings()

func _on_Back_pressed() -> void:
	hide()

func _on_Controls_pressed() -> void:
	_main_menu.hide()
	_controls_menu.show()

func _on_Audio_pressed() -> void:
	_main_menu.hide()
	_audio_menu.show()

func _on_Audio_Back_pressed() -> void:
	_audio_menu.hide()
	_main_menu.show()

func _on_Control_Back_pressed() -> void:
	_controls_menu.hide()
	_main_menu.show()
