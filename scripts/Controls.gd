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
# Control settings in the main menu.

extends VBoxContainer

onready var _up_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Up
onready var _down_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Down
onready var _left_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Left
onready var _right_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Right
onready var _jump_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Jump
onready var _shoot_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Shoot
onready var _reset_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Reset
onready var _pause_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Pause
onready var _skip_key := $VBoxContainer/HBoxContainer/VBoxContainer2/Skip
onready var _controls_back := $Back
onready var _press_label := $Control/Press

var _mod_key: Button

func _ready() -> void:
	_refresh_settings()

func _refresh_settings() -> void:
	_up_key.text = action2event("up").to_upper()
	_down_key.text = action2event("down").to_upper()
	_left_key.text = action2event("left").to_upper()
	_right_key.text = action2event("right").to_upper()
	_jump_key.text = action2event("jump").to_upper()
	_shoot_key.text = action2event("shoot").to_upper()
	_reset_key.text = action2event("reset").to_upper()
	_pause_key.text = action2event("pause").to_upper()
	_skip_key.text = action2event("skip").to_upper()

	Save.save_settings()

## Converts InputEventAction's action into an event string
func action2event(action: String) -> String:
	var events: Array = InputMap.get_action_list(action)
	var scancode = events[0].scancode

	return OS.get_scancode_string(scancode)

func _on_Controls_Reset_pressed() -> void:
	InputMap.load_from_globals()

	_refresh_settings()

func _unhandled_key_input(event: InputEventKey) -> void:
	var scan: int = event.scancode

	if _mod_key and (scan < KEY_F1 or scan > KEY_F16) and scan != KEY_ESCAPE:
		_mod_key.text = OS.get_scancode_string(scan).to_upper()
		_press_label.hide()

		var action: String

		match _mod_key:
			_up_key:
				action = "up"
			_down_key:
				action = "down"
			_left_key:
				action = "left"
			_right_key:
				action = "right"
			_jump_key:
				action = "jump"
			_shoot_key :
				action = "shoot"
			_reset_key:
				action = "reset"
			_pause_key:
				action = "pause"
			_skip_key:
				action = "skip"

		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

		Save.save_settings()

		_mod_key = null

func _on_Up_pressed() -> void:
	_press_label.show()
	_mod_key = _up_key

func _on_Left_pressed() -> void:
	_press_label.show()
	_mod_key = _left_key


func _on_Down_pressed() -> void:
	_press_label.show()
	_mod_key = _down_key


func _on_Right_pressed() -> void:
	_press_label.show()
	_mod_key = _right_key


func _on_Jump_pressed() -> void:
	_press_label.show()
	_mod_key = _jump_key


func _on_Shoot_pressed() -> void:
	_press_label.show()
	_mod_key = _shoot_key


func _on_Reset_pressed() -> void:
	_press_label.show()
	_mod_key = _reset_key


func _on_Pause_pressed() -> void:
	_press_label.show()
	_mod_key = _pause_key


func _on_Skip_pressed() -> void:
	_press_label.show()
	_mod_key = _skip_key
