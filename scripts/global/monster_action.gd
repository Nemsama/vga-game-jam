extends Action
class_name MonsterAction

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


enum Type {
	ATTACK,
	BUFF,
	NOTHING,
}

var weight: float
var icon: Texture2D
var type: Type

func _init(effect: Callable, description: String, actionType: Type, weight: float, texture: Texture2D):
	super._init(effect, description)
	self.type = actionType
	self.weight = weight
	self.icon = texture

static func getSum(actions: Array[MonsterAction]) -> float:
	var sum: float
	for action in actions:
		sum += action.weight
	return sum
