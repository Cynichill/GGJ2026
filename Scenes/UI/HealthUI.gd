class_name HealthUI
extends HBoxContainer

@onready var hearts := get_children().map(func(c):
	return c.get_node("Sprite2D")
)

func show_health(health: int) -> void:
	for i in hearts.size():
		hearts[i].visible = i < health
			
