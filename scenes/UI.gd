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

onready var go: MarginContainer = $GameOver
onready var menu: MarginContainer = $Menu

onready var sound: HSlider = $Menu/PanelContainer/VBoxContainer/HBoxContainer/HBoxContainer/Sound
onready var music: HSlider = $Menu/PanelContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Music
onready var fs: CheckBox = $Menu/PanelContainer/VBoxContainer/VBoxContainer/Fullscreen
onready var quiet_bg: CheckBox = $Menu/PanelContainer/VBoxContainer/VBoxContainer/QuietBG
onready var vsync: CheckBox = $Menu/PanelContainer/VBoxContainer/VBoxContainer/VSync
onready var ok: Button = $Menu/PanelContainer/VBoxContainer/HBoxContainer5/Ok
onready var back_ts: Button = $Menu/PanelContainer/VBoxContainer/HBoxContainer5/Back2Title

func _ready():
	# warning-ignore:return_value_discarded
	Shortcuts.connect("paused", self, "set_menu_visible")

func game_over() -> void:
	go.show() # Is hidden when scene is reloaded on reset

func set_menu_visible(visible: bool) -> void:
	if visible:
		_refresh_settings()
	
	menu.set_visible(visible)
	

func _refresh_settings() -> void:
	fs.pressed = OS.is_window_fullscreen()
	vsync.pressed = OS.is_vsync_enabled()
	quiet_bg.pressed = Music.is_quiet()
	

func _on_Ok_pressed():
	menu.hide()
	get_tree().set_pause(false)

## Title screen to be implemented
func _on_Back2Title_pressed():
	pass # Replace with function body.


func _on_VSync_pressed():
	OS.set_use_vsync(vsync.is_pressed())


func _on_QuietBG_pressed():
	Music.set_quiet(quiet_bg.is_pressed())


func _on_Fullscreen_pressed():
	OS.set_window_fullscreen(fs.is_pressed())