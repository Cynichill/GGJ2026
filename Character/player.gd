extends CharacterBody2D

@export var deviceID = -1
@onready var healthUI: HealthUI = get_node("../CombinedUI/HealthContainer%d" % deviceID)

var maxHealth = 3
var curHealth = 3
var speed = 100.0
const ACCEL = 2.0

const BASE_SPEED = 100.0
const DASH_SPEED = 500.0

var moveDirection: Vector2

const DASH_START_TIME = 0.5
var dashTimer = DASH_START_TIME

var input: Vector2

enum Role {
	Hunter,
	Prey
}

enum State{
	Moving,
	Dashing
}
var currentState = State.Moving

@export var currentRole = Role.Prey

signal interaction(role)

func get_input():
	input.x = Input.get_action_strength("Right_%s" % [deviceID]) - Input.get_action_strength("Left_%s" % [deviceID])
	input.y = Input.get_action_strength("Down_%s" % [deviceID]) - Input.get_action_strength("Up_%s" % [deviceID])
	moveDirection = input.normalized()

func getDashInput():
	var direction = Input.get_vector("Left_%s" % [deviceID], "Right_%s" % [deviceID], "Up_%s" % [deviceID], "Down_%s" % [deviceID])
	return direction.normalized()

func _process(delta):
	print(dashTimer)
	
	match(currentState):
		State.Moving:
			get_input()
			velocity = lerp(velocity, moveDirection * speed , delta * ACCEL)
		State.Dashing:
			dashTimer -= delta
			if(dashTimer < 0):
				currentState = State.Moving
			velocity = DASH_SPEED * moveDirection

	move_and_slide()

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
	# Do Cooldown
	
func trap():
	print("trap")
	
func change_health(change):
	if curHealth + change <= maxHealth:
		curHealth = curHealth + change
		healthUI.show_health(curHealth)
		
func swap():
	print("Swap!")
