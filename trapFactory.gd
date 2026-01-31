extends Node
@onready var trapScene = preload("res://Scenes/trap.tscn")

const GRID_CORRECTION = 32

func _ready():
	EventBus.createTrap.connect(newTrap)

func newTrap(creator, position):
	var thisTrap: Trap = trapScene.instantiate()
	thisTrap.creator = creator
	thisTrap.position = correctPlacement(position)
	add_child(thisTrap)
	
func correctPlacement(position):
	var x = int(position.x / GRID_CORRECTION)
	var y = int(position.y / GRID_CORRECTION)
	
	var newPos = Vector2(x*GRID_CORRECTION,y*GRID_CORRECTION)
	return newPos
	
