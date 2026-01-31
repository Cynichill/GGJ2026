extends Node
@onready var trapScene = preload("res://Scenes/trap.tscn")

func _ready():
	EventBus.createTrap.connect(newTrap)

func newTrap(creator, position):
	var thisTrap: Trap = trapScene.instantiate()
	thisTrap.creator = creator
	thisTrap.position = Vector2(floor(position.x), floor(position.y))
	add_child(thisTrap)
