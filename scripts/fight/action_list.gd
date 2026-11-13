extends Node2D

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


const buttonWidth = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func setActionList(actionList: Array[Action]):
	var posStart: int = -(actionList.size() - 1) * buttonWidth / 2
	for i in range(actionList.size()):
		var effect: Callable    = actionList[i].effect
		var description: String = actionList[i].description
		var pos: Vector2 = Vector2(posStart + i*buttonWidth, 0)

		var button: SteamButton = SteamButton.newButton(pos, description)
		button.setWidth(buttonWidth)
		button.getButtonSignal().connect(effect)

		add_child(button)
