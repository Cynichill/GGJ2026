extends Node2D

@export var mute: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if not mute:
		play_Music()
		
		
func play_Music():
	if not mute:
		$Music.play()


func play_Ambience() -> void:
	if not mute:
		$Ambience.play()


func play_UI() -> void:
	if not mute:
		$UI.play()
	
func play_Mask() -> void:
		if not mute:
			$Mask.play()


func play_Damage() -> void:
	if not mute:
		$Damage.play()


func play_TrapDrop() -> void:
	if not mute:
		$TrapDrop.play()


func play_TrapDet() -> void:
	if not mute:
		$TrapDet.play()

func play_Dash() -> void:
	if not mute:
		$Dash.play()


func play_Doors() -> void:
	if not mute:
		$Doors.play()
