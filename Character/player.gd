extends CharacterBody2D

enum Role {
	Hunter,
	Prey
}

enum State{
	Moving,
	Dashing,
	Stunned
}

@export var deviceID = -1
@onready var healthUI: HealthUI = get_node("../CombinedUI/HealthContainer%d" % deviceID)
var swapTimer
var stunTimer
@export var currentRole = Role.Prey

const MAX_HEALTH = 3
const BASE_SPEED = 100.0
const ACCEL = 2.0
const DASH_SPEED = 500.0
const DASH_START_TIME = 0.5
const STUN_TIME_MAX = 3

var curHealth = 3
var speed = 100.0
var moveDirection: Vector2
var dashTimer = DASH_START_TIME
var dashEnabled = true

var currentState = State.Moving

func _ready():
	swapTimer = get_node("../CombinedUI/Timer")
	swapTimer.timerEnd.connect(swapRole)

func _process(delta):
	match(currentState):
		State.Moving:
			movePlayer(delta)
		State.Dashing:
			dashPlayer(delta)
		State.Stunned:
			velocity = Vector2.ZERO

	move_and_slide()

func movePlayer(delta):
	moveDirection.x = Input.get_action_strength("Right_%s" % [deviceID]) - Input.get_action_strength("Left_%s" % [deviceID])
	moveDirection.y = Input.get_action_strength("Down_%s" % [deviceID]) - Input.get_action_strength("Up_%s" % [deviceID])
	moveDirection.normalized()
	velocity = lerp(velocity, moveDirection * speed , delta * ACCEL)
	

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
		
func swapRole():
	stunPlayer()
	match(currentRole):
		Role.Hunter:
			currentRole = Role.Prey
		Role.Prey:
			currentRole = Role.Hunter

func stunPlayer():
	currentState = State.Stunned
	stunTimer = get_tree().create_timer(STUN_TIME_MAX)
	stunTimer.timeout.connect(releaseStun)

func releaseStun():
	currentState = State.Moving
