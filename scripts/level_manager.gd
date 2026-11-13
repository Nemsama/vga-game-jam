extends Node2D

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#

var currentLevel: int = 1
var currentFight: FightScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.end_of_fight.connect(_on_end_of_fight)

	newLevel(1)

func _on_end_of_fight(playerWin: bool) -> void:
	currentFight.queue_free()
	if (currentLevel == 1):
		print("last level completed, exiting the game")
		get_tree().quit()
		return
	newLevel(currentLevel+1)

func newLevel(levelNum: int):
	currentLevel = levelNum
	currentFight = FightScene.newFight(currentLevel)
	add_child(currentFight)
