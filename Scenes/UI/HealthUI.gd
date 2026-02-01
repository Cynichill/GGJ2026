class_name HealthUI
extends HBoxContainer

@onready var hearts := get_children().map(func(c):
	return c.get_node("Sprite2D")
)

func show_health(health: int) -> void:
	for i in hearts.size():
		if i < health:
			hearts[i].frame = 0  # full
		else:
			hearts[i].frame = 1  # empty
			
