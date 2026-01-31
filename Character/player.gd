extends CharacterBody2D

@export var deviceID = -1
@onready var healthUI: HealthUI = get_node("../CombinedUI/HealthContainer%d" % deviceID)
@onready var anim = get_node("AnimationPlayer")

#Animation Variables
var curAnimation = ""

var maxHealth = 3
var curHealth = 3
const SPEED = 100.0
const ACCEL = 2.0

var input: Vector2

func get_input():
	input.x = Input.get_action_strength("Right_%s" % [deviceID]) - Input.get_action_strength("Left_%s" % [deviceID])
	input.y = Input.get_action_strength("Down_%s" % [deviceID]) - Input.get_action_strength("Up_%s" % [deviceID])
	return input.normalized()
	
func _process(delta):
	var playerInput = get_input()
	velocity = lerp(velocity, playerInput * SPEED , delta * ACCEL)
	move_and_slide()
	ChangeAnimation()
	
func change_health(change):
	if curHealth + change <= maxHealth:
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
