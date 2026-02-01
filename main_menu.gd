extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/map.tscn")
	AudioController.play_UI()



func _on_quit_pressed() -> void:
	get_tree().quit()
	AudioController.play.UI()
