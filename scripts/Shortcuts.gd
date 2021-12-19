extends Node

# There probably is a more efficient way of doing this
var bg_img: RID = preload("res://sprites/bg_black.png").get_rid()

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	VisualServer.black_bars_set_images(bg_img, bg_img, bg_img, bg_img)

func _unhandled_key_input(_event):
	var tree: SceneTree = get_tree()

	if Input.is_action_just_pressed("pause"):
		tree.set_pause(not tree.is_paused())

	if Input.is_action_just_pressed("reset"):
		Save.deaths += 1

		if not Music.is_playing():
			Music.toggle()

		tree.reload_current_scene()

		OS.set_window_title("I Don't Wanna Be Game Maker! (deaths: "
				+ str(Save.deaths) + ")")

	if Input.is_action_just_pressed("quit"):
		tree.quit(0)

	# Implement fullscreen
	if Input.is_action_just_pressed("fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())

	# Implement boss skip
	if Input.is_action_just_pressed("skip"):
		pass

	# Implement going back to title screen
	if Input.is_action_just_pressed("title_screen"):
		pass
