extends Label

# Timer child
@onready var timer: Timer = $Timer
const TOTAL_TIME = 15.0

func _ready():
	self.text = str(TOTAL_TIME)
	timer.wait_time = TOTAL_TIME
	timer.start()

func _process(delta):
	var timeLeft = ceil(timer.get_time_left())
	self.text = str(int(timeLeft))
