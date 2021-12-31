extends Node2D

var exploding := false
var frame := 0

func _physics_process(delta):
	if exploding and frame < 25:
		for line in get_children():
			line.add_point(line.points[line.points.size() - 1] + line.points[1] * 4)
		frame +=1
	elif frame >= 25:
		pass


func _on_Hitbox_area_entered(area):
	global_position = area.global_position
	exploding = true
