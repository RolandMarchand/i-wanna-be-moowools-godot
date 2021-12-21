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
