extends Label

# Timer child
var timer
const TOTAL_TIME = 15.0
signal timerEnd

func _ready():
	setRoundTimer()

func _process(delta):
	var timeLeft = ceil(timer.get_time_left())
	self.text = str(int(timeLeft))
	
func setRoundTimer():
	set("theme_override_colors/font_color", Color(1.0,1.0,1.0,1.0))
	timer = get_tree().create_timer(TOTAL_TIME)
	timer.timeout.connect(releaseTimer)
	
func releaseTimer():
	timerEnd.emit()
	setStunTimer()

func setStunTimer():
	set("theme_override_colors/font_color", Color(1.0,0.0,0.0,1.0))
	timer = get_tree().create_timer(3)
	timer.timeout.connect(setRoundTimer)
