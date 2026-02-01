extends Sprite2D

var tween

@export var playerID: int

func _ready() -> void:
	match(playerID):
		1:
			tweenUp()
		2:
			tweenDown()
	
func tweenUp():
	tween = create_tween().set_loops(INF).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", self.position.y - 20, 2)
	var tweenTimerUp = get_tree().create_timer(2)
	tweenTimerUp.timeout.connect(tweenDown)

func tweenDown():
	tween = create_tween().set_loops(INF).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", self.position.y + 20, 2)
	var tweenTimerUp = get_tree().create_timer(2)
	tweenTimerUp.timeout.connect(tweenUp)
