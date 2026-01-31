extends CharacterBody2D

@export var deviceID = -1
const SPEED = 100.0
const ACCEL = 2.0

var input: Vector2

enum Role {
	Hunter,
	Prey
}

## We have a single interaction key
## The resulting interaction is dependant on role
var interactions := {
	Role.Hunter: func(): trap(),	## Place trap on map
	Role.Prey: func(): dash()		## Evasive Trap
}

@export var currentRole = Role.Prey

func get_input():
	input.x = Input.get_action_strength("Right_%s" % [deviceID]) - Input.get_action_strength("Left_%s" % [deviceID])
	input.y = Input.get_action_strength("Down_%s" % [deviceID]) - Input.get_action_strength("Up_%s" % [deviceID])
	return input.normalized()
	
func _process(delta):
	var playerInput = get_input()
	velocity = lerp(velocity, playerInput * SPEED , delta * ACCEL)
	move_and_slide()

func _input(event: InputEvent):
	if event.is_action_pressed("Interact_%s" % [deviceID]):
		interact()
	
func interact():
	interactions[currentRole].call()
	
func dash():
	print("dash")
	
func trap():
	print("trap")
