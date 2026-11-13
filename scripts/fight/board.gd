extends Node2D
class_name Board

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


const screenWidth: int = 1280

const leftmostTile: int = 120 # distance between screen border and leftmost tile (pixels)
const monsterTile:  int = 240 # distance between screen border and monster tile (pixels)
const tileCount: int = 12 # number of accessible tiles (from leftmostTile to the tile before the monster)
const monsterBoardPos: int = tileCount+1
const tileWidth: int = (screenWidth - leftmostTile - monsterTile) / tileCount
# the distance between each tile
const lastTileToDisplay: int = (screenWidth - leftmostTile) / tileWidth + 1

const playerInitialPos: int = 5
const monsterOffset: Vector2 = Vector2(80, 0)

var tiles: Array[Tile] = []
# class Tile:
# 	var screenPos: Vector2
# 	var boardPos: int
# 	var token: Token.token
#
# 	func _init(screenPos: Vector2, boardPos: int):
# 		self.screenPos = screenPos
# 		self.boardPos = boardPos

var monster: Monster

var resolving: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.end_of_action.connect(_on_end_of_action)
	SignalBus.end_of_turn.connect(_on_end_of_turn)
	SignalBus.player_death.connect(_on_player_death)
	SignalBus.monster_death.connect(_on_monster_death)

	tiles.append(null) # add a null tile representing death to match index with positions
	for i in range(1, monsterBoardPos):
		var currentTile = Tile.newTile(getScreenPos(i), i, tileCount)
		tiles.append(currentTile)
		add_child(currentTile)
	# for i in range(monsterBoardPos, lastTileToDisplay):
	# 	var currentTile = Tile.newTile(getScreenPos(i), i, tileCount)
	# 	add_child(currentTile)
	$Player.boardPos = playerInitialPos
	$Player.moveTo(playerInitialPos)
	roll_board()

func setMonster(newMonster: Monster):
	if (monster != null):
		monster.queue_free()

	monster = newMonster
	add_child(newMonster)
	monster.position = getScreenPos(monsterBoardPos) + monsterOffset


func getScreenPos(boardPos: int) -> Vector2:
	var screenBorderPos = leftmostTile + boardPos * tileWidth
	return Vector2(screenBorderPos - screenWidth/2, 0)


func roll_board():
	for i in range(1, tiles.size()):
		if (i == $Player.boardPos):
			continue
		if (i == tileCount):
			await tiles[i].rollTokenAnimated()
		else:
			tiles[i].rollTokenAnimated()


func _on_end_of_action() -> void:
	await monster.takeAction()
	if ($Player.energy <= 0):
		SignalBus.end_of_turn.emit()
	else:
		resolving = false

func _on_end_of_turn() -> void:
	print("waiting for player atk")
	await $Player.attack()
	print("waiting for monster atk")
	await monster.push()
	$Player.energy = $Player.maxEnergy
	print("waiting to roll board")
	await roll_board()
	print("end of turn resolved")
	resolving = false


func damageMonster(amount: int):
	monster.recieveDamage(amount)

func pushPlayer(amount: int):
	await $Player.push(-amount, true)

func playerOnTile(playerPos: int):
	if (tiles[playerPos].isRemoved):
		return

	var effect: Callable
	match tiles[playerPos].currentToken:
		Token.token.NOTHING:
			pass
		Token.token.ATTACK:
			$Player.nextAttack += tiles[playerPos].atkTokenPower
		Token.token.SPEED:
			effect = Callable($Player, "move").bind(1)
		Token.token.STUN:
			monster.stun()
		Token.token.DOUBLE_STRIKE:
			$Player.nextAttack *= 2
		Token.token.FORESEE:
			monster.foresee()
		Token.token.LAND_ON_YOUR_FEET:
			pass # TODO : not implemented yet
		Token.token.FASTER:
			$Player.maxEnergy += 1
		Token.token.SLOWER:
			$Player.maxEnergy -= 1
		Token.token.PREDICT:
			pass # to remove
		Token.token.PREPARE:
			pass

	tiles[playerPos].empty()

	if (not effect.is_null()):
		return await effect.call()


func _on_player_death():
	SignalBus.end_of_fight.emit(false)

func _on_monster_death():
	SignalBus.end_of_fight.emit(true)
