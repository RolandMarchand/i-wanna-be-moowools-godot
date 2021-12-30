extends KinematicBody2D

const BASE_SPEED := 2.0

var _path: Array = []
var _playback_pos := 0
var velocity: Vector2

export(float) var speed: float = BASE_SPEED

func _ready():
	_gen_path()
	if not $AnimationPlayer.autoplay:
		_next_tween()
		$Tween.start()

func _physics_process(delta):
	for player in $Drag.get_overlapping_bodies():
		player.move_and_slide(velocity / delta)

func _next_tween() -> void:
	var duration = _get_tween_duration(_path[_playback_pos].distance_to(_path[_playback_pos + 1]))
	velocity = _path[_playback_pos].direction_to(_path[_playback_pos + 1]).normalized() * speed

	$Tween.interpolate_property(self, "position", _path[_playback_pos], _path[_playback_pos + 1], duration)

	_playback_pos += 1
	_playback_pos %= _path.size() - 1


func _get_tween_duration(distance: float) -> float:
	return distance / (speed * 50)

func _gen_path() -> void:
	_path.clear()

	for point in $Trajectory.get_children():
		_path.append(point.global_position)

	# Loops back
#	var p = _path.duplicate()
#	p.invert()
#	p.pop_front()
#	_path.append_array(p)


func _on_Tween_tween_completed(_object, _key):
	_next_tween()
	$Tween.start()


func _on_Snap_area_entered(area):
	var player = area.get_parent()
	player.global_position.y = global_position.y - 8.5 - 8
	player._jump = false
