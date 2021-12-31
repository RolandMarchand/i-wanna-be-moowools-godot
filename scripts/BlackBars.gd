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

var brown_block: Dictionary = {
		Vector2(1280,720):
			preload("res://sprites/black_bars/brown_block/1280x720.png"),
		Vector2(1366,768):
			preload("res://sprites/black_bars/brown_block/1366x768.png"),
		Vector2(1440,900):
			preload("res://sprites/black_bars/brown_block/1440x900.png"),
		Vector2(1536,864):
			preload("res://sprites/black_bars/brown_block/1536x864.png"),
		Vector2(1920,1080):
			preload("res://sprites/black_bars/brown_block/1920x1080.png"),
		Vector2(3840,2160):
			preload("res://sprites/black_bars/brown_block/3840x2160.png"),
}

var brick: Dictionary = {
		Vector2(1280,720):
			preload("res://sprites/black_bars/brick/1280x720.png"),
		Vector2(1366,768):
			preload("res://sprites/black_bars/brick/1366x768.png"),
		Vector2(1440,900):
			preload("res://sprites/black_bars/brick/1440x900.png"),
		Vector2(1536,864):
			preload("res://sprites/black_bars/brick/1536x864.png"),
		Vector2(1920,1080):
			preload("res://sprites/black_bars/brick/1920x1080.png"),
		Vector2(3840,2160):
			preload("res://sprites/black_bars/brick/3840x2160.png"),
}

# Does not tile well. planning on a replacement
var metal: Dictionary = {
		Vector2(1280,720):
			preload("res://sprites/black_bars/metal/1280x720.png"),
		Vector2(1366,768):
			preload("res://sprites/black_bars/metal/1366x768.png"),
		Vector2(1440,900):
			preload("res://sprites/black_bars/metal/1440x900.png"),
		Vector2(1536,864):
			preload("res://sprites/black_bars/metal/1536x864.png"),
		Vector2(1920,1080):
			preload("res://sprites/black_bars/metal/1920x1080.png"),
		Vector2(3840,2160):
			preload("res://sprites/black_bars/metal/3840x2160.png"),
}

var _img_array := [brown_block, brick, metal]
var _img_pos := -1

func _ready():
	next_bg_img()

func next_bg_img() -> void:
	# Increment pos of the array
	_img_pos = (_img_pos + 1) % _img_array.size()
	var pattern = _img_array[_img_pos]
	var img: Resource

	if pattern.has(OS.get_screen_size()):
		img = pattern.get(OS.get_screen_size())

	if img:
		var bg_img: RID = img.get_rid()
		VisualServer.black_bars_set_images(bg_img, bg_img, bg_img, bg_img)
