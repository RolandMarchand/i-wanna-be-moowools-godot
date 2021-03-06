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

# Description:
# Singleton managing background music

# Todo:
# Plenty of deprecated functions to remove

extends Node

const QUIET_MULT := 3

var player := AudioStreamPlayer.new()
# Key: AudioStream
# value: float of recorded time
var _last_pos := {}
var _last_song: AudioStream
var _quiet: bool = true setget set_quiet, is_quiet
# Takes a decibel value
# Set in UI.gd
# Used for quiet bg
var original_volume: float

func _ready() -> void:
	add_child(player)

	player.bus = "Music"

	pause_mode = PAUSE_MODE_PROCESS

func _process(_delta) -> void:
	# Sets the audio quiet when window isn' focused
	# Hacky, I know, but notifications don't work
	if _quiet:
		if OS.is_window_focused():
			AudioServer.set_bus_volume_db(0, original_volume)
		else:
			var new_vol = db2linear(original_volume) / QUIET_MULT
			AudioServer.set_bus_volume_db(0, linear2db(new_vol))


func is_playing() -> bool:
	return player.playing

## Plays the music back, starts from where it left off by default
func play(stream: AudioStream, restart := false) -> void:
	player.stream = stream
	_last_song = stream

	if restart or not _last_pos.has(stream):
		player.play()
	else:
		player.play(_last_pos[stream])

## Uses the play function with the last played song
func play_last_song(restart := false):
	if not _last_song:
		push_error("Music.gd: No last song available.")
	else:
		play(_last_song, restart)

## Stops the music and records the last position
func stop() -> void:
	if player.playing:
		_last_pos[player.stream] = player.get_playback_position()
		player.stop()

func pause(p := true) -> void:
	player.stream_paused = p

func is_paused() -> bool:
	return player.stream_paused

func resume() -> void:
	player.stream_paused = false

func get_last_song() -> AudioStream:
	return _last_song

func set_quiet(quiet: bool) -> void:
	_quiet = quiet

func is_quiet() -> bool:
	return _quiet
