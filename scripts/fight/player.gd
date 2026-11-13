extends Node2D

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


const idle_1 = Vector2i(0, 0)
const idle_2 = Vector2i(1, 0)
const dash   = Vector2i(2, 0)
const atk_1  = Vector2i(0, 1)
const atk_2  = Vector2i(1, 1)
const atk_3  = Vector2i(2, 1)
const fall_1 = Vector2i(0, 2)
const fall_2 = Vector2i(1, 2)
const fall_3 = Vector2i(2, 2)

var actionList: Array[Action] = [
	Action.new(Callable(self, "moveAction").bind(-1), "Reculer de 1"),
	Action.new(Callable(self, "moveAction").bind(0),  "Ne pas bouger"),
	Action.new(Callable(self, "moveAction").bind(1),  "Avancer de 1"),
	Action.new(Callable(self, "moveAction").bind(2),  "Avancer de 2"),
	Action.new(Callable(self, "moveAction").bind(3),  "Avancer de 3"),
]

const deathHeight: int = 700

var boardPos: int
var board: Board

var maxEnergy: int = 3
var energy: int = maxEnergy

var nextAttack: int = 0

var idle: bool
var dead: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board = get_parent()
	dead = false
	idle = true
	animationLoop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Attack/Label.text = str(nextAttack)


func attack():
	idle = false
	$Sprite2D.frame_coords = atk_1
	await get_tree().create_timer(0.5).timeout
	$Sprite2D.frame_coords = atk_2
	board.damageMonster(nextAttack)
	nextAttack = 0
	await get_tree().create_timer(0.5).timeout
	$Sprite2D.frame_coords = atk_3
	await get_tree().create_timer(0.3).timeout
	# $Sprite2D.frame_coords = idle_2
	idle = true


func move(amount: int) -> int:
	return await moveTo(boardPos + amount)

func moveTo(newPos: int) -> int:
	newPos = await pushTo(newPos, false)
	if (await board.playerOnTile(boardPos) is int):
		return boardPos
	return boardPos

func push(amount: int, loseBalance: bool) -> int:
	return await pushTo(boardPos + amount, loseBalance)

func pushTo(newPos: int, loseBalance: bool) -> int:
	if (dead):
		return 0

	var dest: int
	if (newPos >= board.monsterBoardPos):
		dest = board.monsterBoardPos-1
	elif (newPos <= 0):
		await playerDeath()
		return 0
	else:
		dest = newPos

	if (loseBalance):
		idle = false
		$Sprite2D.frame_coords = fall_1
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", board.getScreenPos(dest), 0.6).set_trans(Tween.TRANS_BACK)
		await tween.finished
	elif (board.getScreenPos(dest) != position):
		idle = false
		$Sprite2D.frame_coords = idle_1
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", board.getScreenPos(dest), 0.6).set_trans(Tween.TRANS_QUART)
		await get_tree().create_timer(0.2).timeout
		$Sprite2D.frame_coords = dash
		await get_tree().create_timer(0.25).timeout
		$Sprite2D.frame_coords = idle_2
		await tween.finished
	# $Sprite2D.frame_coords = idle_2
	idle = true


	boardPos = dest
	return boardPos

func moveAction(amount: int):
	if (dead or board.resolving):
		return
	print("taking action")
	board.resolving = true
	if (energy <= 0):
		push_error("moveAction taken without energy")
		return
	energy -= 1
	await move(amount)
	SignalBus.end_of_action.emit()


func playerDeath():
	dead = true
	# movement to death
	idle = false
	$Sprite2D.frame_coords = fall_1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", board.getScreenPos(-1), 0.6).set_trans(Tween.TRANS_BACK)
	await tween.finished

	# fall
	$Sprite2D.frame_coords = fall_2
	await get_tree().create_timer(0.5).timeout
	$Sprite2D.frame_coords = fall_3
	tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", deathHeight, 3).set_trans(Tween.TRANS_QUAD)
	await tween.finished

	SignalBus.player_death.emit()


func animationLoop():
	var timer: SceneTreeTimer
	while true:
		timer = get_tree().create_timer(0.5)
		await timer.timeout
		if (not idle):
			continue
		if ($Sprite2D.frame_coords == idle_1):
			$Sprite2D.frame_coords = idle_2
		else:
			$Sprite2D.frame_coords = idle_1
