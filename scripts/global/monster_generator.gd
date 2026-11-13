extends Node
class_name MonsterGenerator

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#



static func getMonster(levelNumber: int, board: Board) -> Monster:
	var monsterScene: PackedScene
	var monster: Monster
	var effect: Callable
	var texture: Texture2D
	match levelNumber:
		1:
			monsterScene = load("res://scenes/blob.tscn")
			monster = monsterScene.instantiate()
			monster.maxHealth = 20
			monster.health = 20
			monster.pushDamage = 3

			effect = Callable()
			texture = load("res://sprites/icons/monster_doNothing.png")
			monster.addAction(MonsterAction.new(effect, "will do nothing", MonsterAction.Type.NOTHING, 3, texture))

			effect = Callable(monster, "addDamage").bind(1)
			texture = load("res://sprites/icons/monster_pushBackMore.png")
			monster.addAction(MonsterAction.new(effect, "will push you more", MonsterAction.Type.BUFF, 1, texture))

			effect = Callable(board, "pushPlayer").bind(1)
			texture = load("res://sprites/icons/monster_pushBack.png")
			monster.addAction(MonsterAction.new(effect, "push you a bit", MonsterAction.Type.ATTACK, 2, texture))

			return monster
	return null
