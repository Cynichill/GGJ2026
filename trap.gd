class_name Trap
extends Node2D
var creator = 1

@onready var DisabledShader = preload("res://grayscale.gdshader")
@onready var EnableShader = preload("res://color.gdshader")

func _ready() -> void:
	EventBus.switchTraps.connect(switch)
	self.get_child(0).material.shader  = EnableShader
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.deviceID != creator:
			EventBus.trapInteraction.emit(body, self)

func switch(hunter):
	var mask = self.get_child(1)
	if hunter == creator:
		mask.set_collision_mask(2)
		self.get_child(0).material.shader  = EnableShader
	else:
		mask.set_collision_mask(0)
		self.get_child(0).material.shader = DisabledShader
