extends Node2D
class_name GM

@onready var text = get_node("Label")
@onready var timer = get_node("Timer")

func DecideWinner(loser: int):
	var winner = 0
	match loser:
		1:
			winner = 2
		2:
			winner = 1
			
	text.visible = true
	text.text = "Player " + str(winner) + " Wins!"
	timer.start()
	


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Menu.tscn")
