extends Node2D
class_name Tile

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


static var tileScene: PackedScene = preload("res://scenes/tile.tscn")
const basePos = Vector2(0, 50)
const rollOffset = Vector2(0, 80) # the displacement of tokens for rolling them

var currentToken: Token.token
var atkTokenPower: int = -1 # only set for attack tokens
var isRemoved = false

var boardPos: int
var boardSize: int


static func newTile(scenePos: Vector2, boardPos: int, boardSize: int) -> Tile:
	var newTile: Tile = tileScene.instantiate()
	newTile.position = scenePos
	newTile.boardPos = boardPos
	newTile.boardSize = boardSize
	newTile.resetRemoved()
	newTile.updateTexture()
	return newTile

func _ready() -> void:
	# resetRemoved()
	pass


func rollTokenAnimated():
	isRemoved = false
	var emptyTokenProb = expDistProbability(boardPos, boardSize, 1.1, .7)
	var atkProb = .65
	# random roll here
	if randf() < emptyTokenProb:
		currentToken = Token.token.NOTHING
	elif randf() < atkProb:
		currentToken = Token.token.ATTACK
	else:
		currentToken = Token.pickToken(boardPos, boardSize)

	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Token, "position", basePos+rollOffset, 0.5)
	await tween.finished

	updateTexture()

	tween = get_tree().create_tween()
	tween.tween_property($Token, "position", basePos, 0.5)

func rollToken():
	isRemoved = false
	var emptyTokenProb = expDistProbability(boardPos, boardSize, 1.1, .7)
	var atkProb = .65
	# random roll here
	if randf() < emptyTokenProb:
		currentToken = Token.token.NOTHING
	elif randf() < atkProb:
		currentToken = Token.token.ATTACK
	else:
		currentToken = Token.pickToken(boardPos, boardSize)
	updateTexture()

func printToken():
	if (currentToken == tokens.token.ATTACK):
		print(tokens.tokenDescriptions[currentToken], getAtkPower())
	else:
		print(tokens.tokenDescriptions[currentToken])

func updateTexture():
	$Token/Removed.visible = isRemoved
	# print("my position is : ", tilePosition)
	$Token/TokenSprite.texture = tokens.tokenTextures[currentToken]
	if (currentToken == tokens.token.ATTACK):
		$Token/AtkPower.text = str(getAtkPower())
	else:
		atkTokenPower = -1
		$Token/AtkPower.text = ""


func empty():
	$Token/AtkPower.text = ""
	currentToken = Token.token.NOTHING
	updateTexture()

func resetRemoved():
	$Token/Removed.visible = false
	isRemoved = false

func removePlay():
	$Token/Removed.visible = true
	isRemoved = true


func getAtkPower():
	if (atkTokenPower != -1):
		return atkTokenPower
	computeAtkPowerAtTile()
	return atkTokenPower

func computeAtkPowerAtTile():
	var mean = meanAtkPower(boardPos, 3., 6., 1.5)
	var atk = clampedNormal(mean, 1., 1, 64)
	atkTokenPower = atk
	return atk

func expDistProbability(currentTile: int, boardSize: int, formParameter: float, probabilityEnd: float):
	var probability: float = probabilityEnd*((formParameter**currentTile)/(formParameter**boardSize))
	return probability

func clampedNormal(mean: float, deviation: float, minValue: float, maxValue: float):
	var returnValue = round(clamp(randfn(mean, deviation), minValue, maxValue))
	return int(returnValue)

func meanAtkPower(currentTile: int, formParameter: float, maxValue: float, minValue: float):
	return (maxValue - minValue)*(formParameter**(1-currentTile)) + minValue
