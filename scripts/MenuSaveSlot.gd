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

extends VBoxContainer

enum {START, LOAD, DIFFICULTY}

var _state: int
var _save: String
var _button_pos := 0

var _revert_confirm := false
var _delete_confirm := false

onready var _save_label := $Save
onready var _deaths_label := $PanelContainer/MarginContainer/VBoxContainer/Deaths
onready var _time_label := $PanelContainer/MarginContainer/VBoxContainer/Time
onready var _difficulty_label := $PanelContainer/MarginContainer/VBoxContainer/Difficulty
onready var _location_label := $PanelContainer/MarginContainer/VBoxContainer/Location
onready var _revert_warning := $HBoxContainer/Revert/RevertWarning
onready var _delete_warning := $HBoxContainer/Delete/DeleteWarning
onready var _previous_button := $HBoxContainer/Previous
onready var _next_button := $HBoxContainer/Next
onready var _play_button := $HBoxContainer/Play
onready var _revert_button := $HBoxContainer/Revert
onready var _delete_button := $HBoxContainer/Delete
onready var _medium_button := $HBoxContainer/Medium
onready var _hard_button := $HBoxContainer/Hard
onready var _very_hard_button := $HBoxContainer/VeryHard
onready var _impossible_button := $HBoxContainer/Impossible
onready var _capture := $PanelContainer/MarginContainer/VBoxContainer/Panel/TextureRect

onready var DIR_BUTTONS := [
	_previous_button,
	_next_button,
]

onready var START_LOAD_BUTTONS := [
	_play_button,
	_delete_button,
	_revert_button,
]

onready var DIFFICULTY_BUTTONS := [
	_medium_button,
	_hard_button,
	_very_hard_button,
	_impossible_button,
]

func _ready():
	_set_save()
	_set_state()
	_set_image()

func _set_save() -> void:
	match _save_label.text:
		"save 1":
			_save = Save.SAVE1
		"save 2":
			_save = Save.SAVE2
		"save 3":
			_save = Save.SAVE3
		_:
			push_warning(_save_label.txt + " isn't an available save name.")

func _set_image() -> void:
	var data: Dictionary = Save.load_game(_save)
	var _filename: String
	var img: ImageTexture

	if not Save.load_game(_save):
		_capture.texture = null
		return

	if data:
		_filename = data["scene"]
	else:
		return

	img = Screenshots.get_screenshot(_save, _filename)
	if img:
		_capture.texture = img


func _set_state() -> void:
	var data = Save.load_game(_save)

	if data:
		_state = LOAD

		_deaths_label.text = str(data["deaths"])
		_time_label.text = _get_time(data["time"])
		_difficulty_label.text = data["difficulty"]
		_location_label.text = data["location"]

		_hide_all_buttons()
		_play_button.show()
		for but in DIR_BUTTONS:
			but.show()
	else:
		_state = START

		_deaths_label.text = "N/A"
		_time_label.text = "N/A"
		_difficulty_label.text = "N/A"
		_location_label.text = "N/A"

		_hide_all_buttons()
		_play_button.show()

func _get_time(seconds: int) -> String:
	var minutes := 0
	var hours := 0

	while seconds - 60 >= 0:
		seconds -= 60
		minutes += 1

	while minutes - 60 >= 0:
		minutes -= 60
		hours += 1

	return "{hours}:{minutes}:{seconds}".format({
		"hours": hours,
		"minutes": minutes,
		"seconds": seconds
		})

func _on_Play_pressed():
	if _state == LOAD:
		_load_game()
	# Player chooses difficulty
	else:
		_state = DIFFICULTY

		_hide_all_buttons()
		for button in DIR_BUTTONS:
			button.show()

		_button_pos = 0
		_medium_button.show()

func _hide_all_buttons() -> void:
	for button in START_LOAD_BUTTONS + DIR_BUTTONS + DIFFICULTY_BUTTONS:
		button.hide()

func _load_game() -> void:
	# warning-ignore:return_value_discarded
	Save.set_active_save(_save)
	get_tree().change_scene_to(load(GameStats.scene))

func _new_game(dif: String) -> void:
		Save.set_active_save(_save)
		GameStats.set_difficulty(dif)
		GameStats.scene = GameStats.START_SCENE
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(load(GameStats.START_SCENE))

func _on_Next_pressed():
	# Next difficulty
	if _state == DIFFICULTY:
		DIFFICULTY_BUTTONS[_button_pos].hide()

		_button_pos += 1
		_button_pos %= DIFFICULTY_BUTTONS.size()

		DIFFICULTY_BUTTONS[_button_pos].show()

	if _state == LOAD:
		START_LOAD_BUTTONS[_button_pos].hide()

		_button_pos += 1
		_button_pos %= START_LOAD_BUTTONS.size()

		START_LOAD_BUTTONS[_button_pos].show()
func _on_Previous_pressed():
	# Previous difficulty
	if _state == DIFFICULTY:
		DIFFICULTY_BUTTONS[_button_pos].hide()

		_button_pos -= 1
		_button_pos %= DIFFICULTY_BUTTONS.size()

		DIFFICULTY_BUTTONS[_button_pos].show()

	if _state == LOAD:
		START_LOAD_BUTTONS[_button_pos].hide()

		_button_pos -= 1
		_button_pos %= START_LOAD_BUTTONS.size()

		START_LOAD_BUTTONS[_button_pos].show()

func _on_Medium_pressed():
	_new_game(GameStats.DIFFICULTY_MEDIUM)

func _on_Hard_pressed():
	_new_game(GameStats.DIFFICULTY_HARD)

func _on_VeryHard_pressed():
	_new_game(GameStats.DIFFICULTY_VERY_HARD)

func _on_Impossible_pressed():
	_new_game(GameStats.DIFFICULTY_IMPOSSIBLE)

func _on_Revert_pressed():
	if _revert_confirm:
		if Save.revert_last_save(_save) == Save.ERASED:
			_revert_warning.text = "Reverted into\noblivion"
			_set_save()
			_set_state()
			_set_image()
			return
		_load_game()
	else:
		_revert_confirm = true
		_revert_warning.show()

func _on_Delete_pressed():
	if _delete_confirm:
		Save.delete_save(_save)
		Screenshots.delete_all_screenshots(_save)
		_set_save()
		_set_state()
		_set_image()
	else:
		_delete_confirm = true
		_delete_warning.show()
