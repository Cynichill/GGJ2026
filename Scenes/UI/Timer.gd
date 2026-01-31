extends Label

# Timer child
@onready var timer: Timer = $Timer
var totalTime = 15

func _ready():
	self.text = '%02d' % [totalTime]
	timer.wait_time = 1.0
	timer.start()

func _on_timer_timeout() -> void:
	self.text = '%02d' % [totalTime]
	totalTime -= 1
	if totalTime <= 0:
		totalTime = 15
	
