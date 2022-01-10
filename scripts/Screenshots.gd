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
# Singleton, takes, saves, loads and deletes screenshots.

extends Node

const SCREENSHOT_PATH := "user://screenshots.cfg"

## Deletes one screenshot of a save.
func delete_screenshot(save: String, id: String) -> void:
	var config = ConfigFile.new()
	config.load(SCREENSHOT_PATH)

	config.erase_section_key(save, id)

	config.save(SCREENSHOT_PATH)

	delete_file_if_empty()

## Removes all the screenshots of a save.
func delete_all_screenshots(save: String) -> void:
	var config = ConfigFile.new()
	config.load(SCREENSHOT_PATH)

	if config.has_section(save):
		config.erase_section(save)

	config.save(SCREENSHOT_PATH)
	var dir = Directory.new()
	dir.remove(SCREENSHOT_PATH)

	delete_file_if_empty()

## Removes the screenshot file if it is empty.
func delete_file_if_empty() -> void:
	var file := File.new()

	if file.open(SCREENSHOT_PATH, File.READ) != OK:
		return

	if file.get_len() == 0:
		var dir := Directory.new()
		# warning-ignore:return_value_discarded
		dir.remove(SCREENSHOT_PATH)

## Returns true if the save has a screenshot of the room
func has_screenshot(save: String, id: String) -> bool:
	var config = ConfigFile.new()
	var err: int = config.load(SCREENSHOT_PATH)

	if err != OK:
		return false

	return config.has_section_key(save, id)

## Loads, decompress and return an ImageTexture of the desired screenshot
## Kind of a mess. To fix.
func get_screenshot(save: String, id: String) -> ImageTexture:
	var config = ConfigFile.new()
	var err = config.load(SCREENSHOT_PATH)

	if err != OK:
		push_error("Screenshots.gd: ConfigFile error " + str(err))
		return null

	var image = config.get_value(save, id, null)

	if not image:
		return null

	err = image.decompress()

	assert(err == OK, "Image error " + str(err))

	var image_texture := ImageTexture.new()

	image_texture.create_from_image(image)

	return image_texture

## Takes screenshot, resizes and compresses it, and then saves it.
func take_screenshot() -> void:
	var capture: Image = get_viewport().get_texture().get_data()
	var id: String = get_tree().current_scene.filename

	capture.flip_y() # Viewport captures are reversed
	capture.resize(202,152, Image.INTERPOLATE_CUBIC)
	# warning-ignore:return_value_discarded
	capture.compress(Image.COMPRESS_PVRTC2, Image.COMPRESS_SOURCE_GENERIC, 50.0)

	var config = ConfigFile.new()
	config.load(SCREENSHOT_PATH)

	config.set_value(Save.current_save, id, capture)
	config.save(SCREENSHOT_PATH)
