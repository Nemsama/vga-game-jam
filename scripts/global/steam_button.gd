extends Node2D
class_name SteamButton

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


static var buttonScene: PackedScene = preload("res://scenes/steam_button.tscn")

const buttonWidth = 360 # width of the sprite in pixels

static func newButton(pos: Vector2, text: String) -> SteamButton:
	var button: SteamButton = buttonScene.instantiate()
	button.setPos(pos)
	button.setText(text)

	return button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func getButtonSignal() -> Signal:
	return $TextureButton.pressed


func setWidth(width: int):
	var newScale: float = float(width)/buttonWidth
	self.scale = Vector2(newScale, newScale)

func setScale(newScale: float):
	self.scale = Vector2(newScale, newScale)

func setText(newText: String):
	$TextureButton/Label.text = newText

func setPos(newPos: Vector2):
	position = newPos
