extends Node2D

@export var endID: int
var tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match(endID):
		1:
			tween = create_tween().set_loops(INF).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(self, "position:x", self.position.y + 900, 2)
		2:
			tween = create_tween().set_loops(INF).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(self, "position:x", self.position.y - 900, 2)
	var endTimer = get_tree().create_timer(3)
	endTimer.timeout.connect(resetScene)

func resetScene():
	match(endID):
		1:
			tween = create_tween().set_loops(INF).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(self, "position:x", self.position.y - 900, 2)
		2:
			tween = create_tween().set_loops(INF).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(self, "position:x", self.position.y + 900, 2)
			
