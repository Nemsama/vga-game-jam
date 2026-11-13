extends Node2D
class_name Monster

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


static var monsterScene: PackedScene = preload("res://scenes/monster.tscn")

var rng = RandomNumberGenerator.new()

var maxHealth: int = 20
var health: int = maxHealth
var nextSmallAction: MonsterAction
var nextnextSmallAction: MonsterAction
var pushDamage: int = 3

var smallActions: Array[MonsterAction]

var foreseeable: bool = false
var stunned: bool = false
var dead: bool = false

var board: Board

# static func newMonster(maxHP: int, initialDMG: int, sprite: Texture2D, actions: Array[MonsterAction]) -> Monster:
# 	var monster: Monster = monsterScene.instantiate()
# 	monster.maxHealth = maxHP
# 	monster.health = maxHP
# 	monster.pushDamage = initialDMG
# 	monster.smallActions = actions
# 	monster.setTexture(sprite)
# 	return monster


func setTexture(newTexture: Texture2D):
	$Sprite2D.texture = newTexture

func addAction(newAction: MonsterAction):
	smallActions.append(newAction)

func addDamage(amount: int):
	pushDamage += amount

func _ready():
	board = get_parent()

	nextSmallAction = smallActionRoll()
	if (foreseeable):
		nextnextSmallAction = smallActionRoll()
	await enterAnimation()


func _process(delta: float) -> void:
	if (dead):
		return
	if (not stunned and not $AnimatedSprite2D.is_playing()):
		$AnimatedSprite2D.play("idle")


func push():
	if (stunned):
		wakeUp()
		return
	animateAttack()
	await get_tree().create_timer(0.5).timeout
	board.pushPlayer(pushDamage)

func smallActionRoll() -> MonsterAction:
	var sum: float = MonsterAction.getSum(smallActions)
	var choice: float = rng.randf_range(0, sum)
	sum = 0
	for smallAction in smallActions:
		sum += smallAction.weight
		if (choice <= sum):
			# print("choosen action: ", smallAction.description)
			return smallAction
	push_error("no monster action was taken")
	return null

func takeAction():
	if (stunned):
		return
	await animateSmallAction()
	if (not nextSmallAction.effect.is_null()):
		await nextSmallAction.effect.call()
	if (foreseeable):
		nextSmallAction = nextnextSmallAction
		nextnextSmallAction = smallActionRoll()
	else:
		nextSmallAction = smallActionRoll()
	updateAttackDisplay()

func recieveDamage(amount: int) -> bool:
	animateDamageTaken()
	health -= amount
	if (health <= 0):
		await monsterDeath()
		return true
	updateHealthBar()
	return false

func monsterDeath():
	dead = true
	print("Vous avez gagné")
	health = 0
	updateHealthBar()

	await animateDeath()

	SignalBus.monster_death.emit()


func updateHealthBar():
	$healthBar/Sprite2D.scale.x = 12.5 * health / maxHealth
	$healthBar/healthAmount.text = str(health) + "/" + str(maxHealth)

func updateAttackDisplay() -> void:
	if (stunned):
		$nextAttack/PushAmount.visible = false
		$nextAttack/Sprite2D.texture = load("res://sprites/icons/monster_stun.png")
		$nextSmallAction.texture = null
		$nextnextSmallAction.texture = null
		return
	$nextAttack/PushAmount.visible = true
	$nextAttack/PushAmount.text = str(pushDamage)
	$nextAttack/Sprite2D.texture = load("res://sprites/icons/monster_pushBack.png")

	$nextSmallAction.texture = nextSmallAction.icon
	if (foreseeable):
		$nextnextSmallAction.texture = nextnextSmallAction.icon

	$nextAttack.visible = true
	$nextSmallAction.visible = true
	$nextnextSmallAction.visible = true


func stun():
	stunned = true
	$AnimatedSprite2D.pause()
	updateAttackDisplay()

func wakeUp():
	stunned = false
	updateAttackDisplay()

func foresee():
	foreseeable = true
	nextnextSmallAction = smallActionRoll()
	updateAttackDisplay()


func enterAnimation():
	$healthBar.visible = false
	$nextAttack.visible = false
	$nextSmallAction.visible = false
	$AnimatedSprite2D.play("spawn")
	await get_tree().create_timer(1.5).timeout
	$healthBar.visible = true
	updateHealthBar()
	updateAttackDisplay()

func animateSmallAction():
	var tween = get_tree().create_tween()
	match nextSmallAction.type:
		MonsterAction.Type.NOTHING:
			await tween.tween_property($nextSmallAction, "rotation", 90, 0.2).set_trans(Tween.TRANS_ELASTIC)
			tween.tween_property($nextSmallAction, "rotation",  0, 0.2).set_trans(Tween.TRANS_ELASTIC)
		MonsterAction.Type.ATTACK:
			tween.tween_property($nextSmallAction, "position:x", $nextSmallAction.position.x - 100, 0.5).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property($nextSmallAction, "modulate", Color.TRANSPARENT, 0.3)
			await tween.finished
			$nextSmallAction.visible = false
			$nextSmallAction.position.x += 100
			$nextSmallAction.modulate = Color.WHITE
		MonsterAction.Type.BUFF:
			tween.tween_property($nextSmallAction, "position:y", $nextSmallAction.position.y + 100, 0.5).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property($nextSmallAction, "modulate", Color.TRANSPARENT, 0.3)
			await tween.finished
			$nextSmallAction.visible = false
			$nextSmallAction.position.y -= 100
			$nextSmallAction.modulate = Color.WHITE

	if (foreseeable):
		tween = get_tree().create_tween()
		tween.tween_property($nextnextSmallAction, "position:y", $nextnextSmallAction.position.y + 50, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property($nextnextSmallAction, "modulate", Color.TRANSPARENT, 0.3)
		await tween.finished
		$nextnextSmallAction.visible = false
		$nextnextSmallAction.position.y -= 50
		$nextnextSmallAction.modulate = Color.WHITE

func animateAttack():
	$AnimatedSprite2D.play("attack")

func animateDamageTaken():
	$AnimatedSprite2D.play("damage")

func animateDeath():
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(2).timeout
