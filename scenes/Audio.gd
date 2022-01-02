extends VBoxContainer


onready var _master := $MasterSlider
onready var _sound := $SoundSlider
onready var _music := $MusicSlider
onready var _audio_back := $Back
onready var _sound_test := $Test
onready var _quiet_bg := $QuietBG

func _ready() -> void:
	_refresh_settings()

func _refresh_settings() -> void:
	_master.value = db2linear(AudioServer.get_bus_volume_db(0))
	_sound.value = db2linear(AudioServer.get_bus_volume_db(1))
	_music.value = db2linear(AudioServer.get_bus_volume_db(2))
	_quiet_bg.pressed = Music.is_quiet()

	Save.save_settings()

func _test_audio() -> void:
	# Audio musn't be tested roguely
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or \
		Input.is_mouse_button_pressed(BUTTON_RIGHT) or \
		Input.is_mouse_button_pressed(BUTTON_WHEEL_UP) or \
		Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):

		_sound_test.play()

	_refresh_settings()

func _on_MasterSlider_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(0, linear2db(value))
	# Used to set quiet bg
	# Notifications are broken and signals don't exist :(
	Music.original_volume = linear2db(value)

	_test_audio()

	_refresh_settings()

func _on_SoundSlider_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(1, linear2db(value))

	_test_audio()

	_refresh_settings()

func _on_MusicSlider_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(2, linear2db(value))

	_refresh_settings()


func _on_QuietBG_toggled(button_pressed: bool) -> void:
	Music.set_quiet(button_pressed)

	_refresh_settings()
