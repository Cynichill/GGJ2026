extends Node2D

@onready var players: Array[Dictionary] = [
	{
		sub_viewport = $"HBoxContainer/LeftSubViewportContainer/SubViewport",
		camera = $"HBoxContainer/LeftSubViewportContainer/SubViewport/Camera2D",
		player = $"HBoxContainer/LeftSubViewportContainer/SubViewport/Map/Player1",
	},
	{
		sub_viewport = $"HBoxContainer/RightSubViewportContainer/SubViewport",
		camera = $"HBoxContainer/RightSubViewportContainer/SubViewport/Camera2D",
		player = $"HBoxContainer/LeftSubViewportContainer/SubViewport/Map/Player2",
	},
]

func _ready() -> void:
	players[1].sub_viewport.world_2d = players[0].sub_viewport.world_2d

	# For each player, we create a remote transform that pushes the character's
	# position to the corresponding camera.
	for info in players:
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = info.camera.get_path()
		info.player.add_child(remote_transform)
