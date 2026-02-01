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
	Dead
}

@export var deviceID = -1
@onready var healthUI: HealthUI = get_node("../CombinedUI/HealthContainer%d" % deviceID)
@onready var gameManager: GM = get_node("../GameManager")
@onready var hitbox: Area2D = get_node("Area2D")
@onready var eyeball: AnimatedSprite2D = get_node("Eyeball")
@onready var sfx: AnimatedSprite2D = get_node("SFX")
@onready var mask: AnimatedSprite2D = get_node(
	"Sprite2D%s/Mask%s" % [deviceID, deviceID]
)
var swapTimer
var stunTimer
var dashTimer
@onready var anim = get_node("Sprite2D1")
@export var currentRole = Role.Prey

const MAX_HEALTH = 3
const BASE_SPEED = 250.0
const DASH_TIMER_MAX = 0.25
const TRAP_TIMER_MAX = 3.0
const TRAP_COUNT_MAX = 2

#Animation Variables
var curAnimation = ""
var isDead = false

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
const MaxSpeed = 300
const turnSpeed = 15
var curAddSpeed = 0
var curMaxSpeed = 0
var curTurnSpeed = 0
var storedDirection = 0

var trapAvailable = true
var trapsLeft = 2
var isInvuln = false
var currentState = State.Moving

func _ready():
	mask.visible = true
	sfx.play("shock")
	swapTimer = get_node("../CombinedUI/Timer")
	swapTimer.timerEnd.connect(swapRole)
	EventBus.trapInteraction.connect(trapped)
	EventBus.playerHit.connect(playerHit)

	match deviceID:
		1:
			var otherSprite = get_node("Sprite2D2")
			otherSprite.visible = false
		2:
			anim = get_node("Sprite2D2")
			var otherSprite = get_node("Sprite2D1")
			otherSprite.visible = false
				
func _process(_delta):
	match(currentState):
		State.Moving:
			movePlayer()
		State.Dashing:
			velocity = DASH_SPEED * storedDirection
		State.Stunned:
			velocity = Vector2.ZERO
		State.Dead:
			velocity = Vector2.ZERO

	move_and_slide()
	ChangeAnimation()

func movePlayer():
	var input_dir := Vector2(
		Input.get_axis("Left_%s" % deviceID, "Right_%s" % deviceID),
		Input.get_axis("Up_%s" % deviceID, "Down_%s" % deviceID)
	)
	
	if currentRole == Role.Hunter:
		if speed < MaxSpeed:
			speed += 20
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
	if(currentState != State.Stunned) && (dashEnabled):
		dashEnabled = false
		currentState = State.Dashing
		storedDirection = moveDirection
		dashTimer = get_tree().create_timer(DASH_TIMER_MAX)
		dashTimer.timeout.connect(releaseDash)
		var invulnTimer = get_tree().create_timer(0.1)
		isInvuln = true
		invulnTimer.timeout.connect(func(): isInvuln = false)
	
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
		print(curHealth)
		healthUI.show_health(curHealth)
	if curHealth <= 0:
		KillPlayer()

func KillPlayer():
	currentState = State.Dead
	isDead = true
	gameManager.DecideWinner(deviceID)
		
func swapRole():
	match(currentRole):
		Role.Hunter:
			mask.play("Prey")
			dashEnabled = true
			currentRole = Role.Prey
		Role.Prey:
			mask.play("Hunter")
			stunPlayer()
			trapAvailable = true
			trapsLeft = 2
			EventBus.switchTraps.emit(deviceID)
			currentRole = Role.Hunter
			
func playerHit():
	match(currentRole):
		Role.Prey:
			change_health(-1)
			stunPlayer()
			trapAvailable = true
			trapsLeft = 2
			EventBus.switchTraps.emit(deviceID)
			currentRole = Role.Hunter
			mask.play("Hunter")
			
		Role.Hunter:
			dashEnabled = true
			currentRole = Role.Prey
			mask.play("Prey")

func stunPlayer():
	currentState = State.Stunned
	stunTimer = get_tree().create_timer(STUN_TIME_MAX)
	stunTimer.timeout.connect(releaseStun)

func releaseStun():
	currentState = State.Moving
	
func ChangeAnimation():
	var nextAnimation = "Idle"
	
	match(currentState):
		State.Moving:
			if velocity.y > 0:
				nextAnimation = "Walk Down"
			elif velocity.y < 0:
				nextAnimation = "Walk Up"
	
			if velocity.x > 0 && abs(velocity.x) > abs(velocity.y):
				nextAnimation = "Walk Right"
			elif velocity.x < 0 && abs(velocity.x) > abs(velocity.y):
				nextAnimation = "Walk Left"
		State.Dashing:
			if velocity.y > 0:
				nextAnimation = "Dash Down"
			elif velocity.y < 0:
				nextAnimation = "Dash Up"
	
			if velocity.x > 0 && abs(velocity.x) > abs(velocity.y):
				nextAnimation = "Dash Right"
			elif velocity.x < 0 && abs(velocity.x) > abs(velocity.y):
				nextAnimation = "Dash Left"
		State.Stunned:
			nextAnimation = "Hurt"
		State.Dead:
			nextAnimation = "Dead"
			eyeball.visible = true
			eyeball.play("Death")
	if isDead:
		nextAnimation = "Dead"
		eyeball.visible = true
		eyeball.play("Death")
			
	if curAnimation != nextAnimation:
		anim.play(nextAnimation)
		curAnimation = nextAnimation

func trapped(player: Player, trap):
	if player.deviceID == deviceID:
		sfx.visible = true
		if !isInvuln:
			slowdown = 0.5
			var cureTimer = get_tree().create_timer(3)
			cureTimer.timeout.connect(cureTimeout)
			trap.queue_free()

func cureTimeout():
	sfx.visible = false
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
		print(body.currentState)
		if body is Player && body != self:
			if currentRole == Role.Prey:
				EventBus.playerHit.emit()

func checkStunBeforeHit(body: Player):
	return body.currentRole == State.Stunned || body.currentState == State.Stunned
