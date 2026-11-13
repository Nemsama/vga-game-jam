extends Node
class_name Action

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


var effect: Callable
var description: String

func _init(effect: Callable, description: String):
	self.effect = effect
	self.description = description
