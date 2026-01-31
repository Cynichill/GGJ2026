extends Node2D

var creator = 1
var affliction = 0.5

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.deviceID != creator:
			body.slowdown = affliction
			body.get_node("CureTimer").start()
