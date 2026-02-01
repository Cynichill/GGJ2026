extends CharacterBody2D
class_name Player

enum Role {
	Hunter,
	Prey
}

enum State{
	Moving,
	Dashing,
	Stunned,
}

@export var deviceID = -1
@onready var healthUI: HealthUI = get_node("../CombinedUI/HealthContainer%d" % deviceID)
var swapTimer
var stunTimer
var dashTimer
@onready var anim = get_node("AnimationPlayer")
@export var currentRole = Role.Prey

const MAX_HEALTH = 3
const BASE_SPEED = 250.0
const DASH_TIMER_MAX = 0.25
const TRAP_TIMER_MAX = 3.0
const TRAP_COUNT_MAX = 2

#Animation Variables
var curAnimation = ""

var slowdown = 1
const ACCEL = 2.0
const DASH_SPEED = 750.0
const STUN_TIME_MAX = 3

var curHealth = 3
var speed = 250.0
var moveDirection: Vector2
var dashEnabled = true

#TEMP
const AddSpeed = 10
const MaxSpeed = 200
const turnSpeed = 15
var curAddSpeed = 0
var curMaxSpeed = 0
var curTurnSpeed = 0
var storedDirection = 0

var currentState = State.Moving

func _ready():
	swapTimer = get_node("../CombinedUI/Timer")
	swapTimer.timerEnd.connect(swapRole)
	EventBus.trapInteraction.connect(trapped)
	EventBus.playerHit.connect(playerHit)

func _process(delta):
	match(currentState):
		State.Moving:
			movePlayer(delta)
		State.Dashing:
			velocity = DASH_SPEED * storedDirection
		State.Stunned:
			velocity = Vector2.ZERO

	move_and_slide()
	ChangeAnimation()

func movePlayer(delta):
	var input_dir := Vector2(
		Input.get_axis("Left_%s" % deviceID, "Right_%s" % deviceID),
		Input.get_axis("Up_%s" % deviceID, "Down_%s" % deviceID)
	)

	curAddSpeed = AddSpeed
	curTurnSpeed = turnSpeed
	var final_speed = speed * slowdown

	# X axis
	velocity.x = apply_axis_movement(
		velocity.x,
		input_dir.x,
		curAddSpeed,
		curTurnSpeed,
		final_speed
	)

	# Y axis
	velocity.y = apply_axis_movement(
		velocity.y,
		input_dir.y,
		curAddSpeed,
		curTurnSpeed,
		final_speed
	)

	moveDirection.x = Input.get_action_strength("Right_%s" % [deviceID]) - Input.get_action_strength("Left_%s" % [deviceID])
	moveDirection.y = Input.get_action_strength("Down_%s" % [deviceID]) - Input.get_action_strength("Up_%s" % [deviceID])
	moveDirection.normalized()
	#velocity = lerp(velocity, moveDirection * (speed * slowdown) , delta * ACCEL)

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
	if(currentState != State.Stunned):
		interactions[currentRole].call()
	
func dash():
	if(currentState != State.Stunned) && currentState != State.Dashing:
		currentState = State.Dashing
		storedDirection = moveDirection
		dashTimer = get_tree().create_timer(DASH_TIMER_MAX)
		dashTimer.timeout.connect(releaseDash)
	
func releaseDash():
	currentState = State.Moving
	speed = BASE_SPEED
	velocity = Vector2(0,0)
	slowdown = 0.1
	var slowdownTimer = get_tree().create_timer(0.1)
	slowdownTimer.timeout.connect(func(): slowdown = 1)
	
func trap():
	if(trapAvailable):
		trapsLeft -= 1
		trapAvailable = false
		var trapTimer = get_tree().create_timer(TRAP_TIMER_MAX)
		trapTimer.timeout.connect(trapCooldownFinish)
		EventBus.createTrap.emit(deviceID, self.position)

func trapCooldownFinish():
	if(trapsLeft > 0):
		trapAvailable = true

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

func apply_axis_movement(
	vel: float,
	dir: float,
	add: float,
	turn: float,
	max_speed: float,
	friction := 0.8
) -> float:

	if dir < 0:
		if vel < -max_speed:
			return -max_speed
		elif vel > 0:
			return vel - turn
		else:
			return vel - add

	elif dir > 0:
		if vel > max_speed:
			return max_speed
		elif vel < 0:
			return vel + turn
		else:
			return vel + add
	else:
		return vel * friction

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !checkStunBeforeHit(body):
		if body is Player && body != self:
			if currentRole == Role.Prey:
				EventBus.playerHit.emit()

func checkStunBeforeHit(body: Player):
	return body.currentRole == State.Stunned || currentState == State.Stunned
	

func playerHit():
	match(currentRole):
		Role.Prey:
			change_health(-1)
			stunPlayer()
			trapAvailable = true
			trapsLeft = 2
			currentRole = Role.Hunter
		Role.Hunter:
			dashEnabled = true
			currentRole = Role.Prey
