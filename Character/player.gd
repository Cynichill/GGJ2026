extends CharacterBody2D
class_name Player

enum Role {
	Hunter,
	Prey
}

enum State{
	Moving,
	Dashing
}

@export var deviceID = -1
@onready var healthUI: HealthUI = get_node("../CombinedUI/HealthContainer%d" % deviceID)
@onready var anim = get_node("AnimationPlayer")
@export var currentRole = Role.Prey

const MAX_HEALTH = 3
const BASE_SPEED = 100.0
#Animation Variables
var curAnimation = ""

var slowdown = 1
const ACCEL = 2.0
const DASH_SPEED = 500.0
const DASH_START_TIME = 0.5

var curHealth = 3
var speed = 100.0
var moveDirection: Vector2
var dashTimer = DASH_START_TIME
var dashEnabled = true

var currentState = State.Moving

func _process(delta):
	print(dashTimer)
	match(currentState):
		State.Moving:
			movePlayer(delta)
		State.Dashing:
			dashPlayer(delta)
	move_and_slide()
	ChangeAnimation()

func movePlayer(delta):
	moveDirection.x = Input.get_action_strength("Right_%s" % [deviceID]) - Input.get_action_strength("Left_%s" % [deviceID])
	moveDirection.y = Input.get_action_strength("Down_%s" % [deviceID]) - Input.get_action_strength("Up_%s" % [deviceID])
	moveDirection.normalized()
	velocity = lerp(velocity, moveDirection * (speed * slowdown) , delta * ACCEL)
	

func dashPlayer(delta):
	dashTimer -= delta
	if(dashTimer < 0):
		currentState = State.Moving
		velocity = DASH_SPEED * moveDirection

func _input(event: InputEvent):
	if event.is_action_pressed("Interact_%s" % [deviceID]):
		interact()

## We have a single interaction key
## The resulting interaction is dependant on role
var interactions := {
	Role.Hunter: func(): trap(),	## Place trap on map
	Role.Prey: func(): dash()		## Evasive Trap
}
	
func interact():
	interactions[currentRole].call()
	
func dash():
	dashTimer = DASH_START_TIME
	currentState = State.Dashing
	dashEnabled = false
	
func trap():
	print("trap")

func change_health(change):
	if curHealth + change <= MAX_HEALTH:
		curHealth = curHealth + change
		healthUI.show_health(curHealth)
		
func swap():
	print("Swap!")
	
func ChangeAnimation():
	
	var nextAnimation = "Idle"
	
	if velocity.y > 0:
		nextAnimation = "WalkDown"
	elif velocity.y < 0:
		nextAnimation = "WalkUp"
	
	if velocity.x > 0 && abs(velocity.x) > abs(velocity.y):
		nextAnimation = "WalkRight"
	elif velocity.x < 0 && abs(velocity.x) > abs(velocity.y):
		nextAnimation = "WalkLeft"

	if curAnimation != nextAnimation:
		anim.play(nextAnimation)
		curAnimation = nextAnimation
		
func _on_cure_timer_timeout():
	if slowdown != 1:
		slowdown = 1
