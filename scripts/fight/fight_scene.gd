extends Node2D
class_name FightScene

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


static var fightScene: PackedScene = preload("res://scenes/fight_scene.tscn")

static func newFight(level: int) -> FightScene:
	var newFight: FightScene = fightScene.instantiate()
	newFight.levelNumber = level
	return newFight

var levelNumber: int
var board: Board

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board = $Board
	var monster: Monster = MonsterGenerator.getMonster(levelNumber, board)
	if (monster == null):
		push_error("monster not implemented yet")
	setMonster(monster)
	$UI/bottomUI/ActionList.setActionList($Board/Player.actionList)
	pass # Replace with function body.

func _process(delta: float) -> void:
	$UI/TopUI/Energy/Label.text = str($Board/Player.energy)

func setMonster(monster: Monster):
	$Board.setMonster(monster)
