extends Node
class_name Token

#
# License disclamer:
# All content in this repo is strictly for exhibition only,
# you may take a look at the contents, share them with a copy of this license and play the game using the Godot engine.
# Any other use is forbidden.
# Training any artificial intelligence on the content of this repository is forbidden.
#


# Multipliers
static var commonMultiplier 	= 1.
static var uncommonMultiplier 	= 1.
static var rareMultiplier 		= 1.
static var epicMultiplier 		= 1.

static var powerMultiplier 		= 1.
static var augmentMultiplier 	= 1.
static var movementMultiplier 	= 1.
static var miscMultiplier 		= 1.
static var trapMultiplier		= 1.

# Weights
static var weightAt0Common 		= 0
static var weightAtEndCommon 	= 6

static var constWeightUncommon 	= 3

static var weightAt0Rare 		= 1
static var weightAtEndRare 		= 5

static var weightAt0Epic 		= 5
static var growthFactorEpic 	= 7

# Enums
enum token {
	NOTHING,
	ATTACK,
	SPEED,
	STUN,
	DOUBLE_STRIKE,
	FORESEE,
	LAND_ON_YOUR_FEET,
	FASTER,
	SLOWER,
	PREDICT,
	PREPARE,
	PERSIST,
	PORTAL,
	STUMBLE,
	ARMY_MARCH,
	WEAKEN,
}

enum rarities {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	SPECIAL
}

enum types {
	ATTACK,
	POWER,
	MOVEMENT,
	AUGMENT,
	MISC,
	TRAP,
}

# Each token has an associated rarity, expect for the ATTACK and NOTHING tokens, which are drawn separately
static var tokenRarities = {
	token.NOTHING: rarities.SPECIAL,
	token.ATTACK: rarities.SPECIAL,
	token.SPEED: rarities.UNCOMMON,
	token.STUN: rarities.EPIC,
	token.DOUBLE_STRIKE: rarities.UNCOMMON,
	token.FORESEE: rarities.COMMON,
	token.LAND_ON_YOUR_FEET: rarities.EPIC,
	token.FASTER: rarities.RARE,
	token.SLOWER: rarities.RARE,
	token.PREDICT: rarities.RARE,
	token.PREPARE: rarities.UNCOMMON,
	token.PERSIST: rarities.COMMON,
	token.PORTAL: rarities.UNCOMMON,
	token.STUMBLE: rarities.COMMON,
	token.ARMY_MARCH: rarities.COMMON,
	token.WEAKEN: rarities.COMMON,
}

static var tokenTextures = {
	token.NOTHING: null,
	token.ATTACK: preload("res://sprites/tokens/token_atk.png"),
	token.SPEED: preload("res://sprites/tokens/token_spd.png"),
	token.STUN: preload("res://sprites/tokens/token_stun.png"),
	token.DOUBLE_STRIKE: preload("res://sprites/tokens/token_doublestrike.png"),
	token.FORESEE: preload("res://sprites/tokens/token_foresee.png"),
	token.LAND_ON_YOUR_FEET: preload("res://sprites/tokens/token_land_on_your_feet.png"),
	token.FASTER: preload("res://sprites/tokens/token_faster.png"),
	token.SLOWER: preload("res://sprites/tokens/token_slower.png"),
	token.PREDICT: preload("res://sprites/tokens/token_predict.png"),
	token.PREPARE: preload("res://sprites/tokens/token_prepare.png"),
	token.PERSIST: preload("res://sprites/tokens/token_persist.png"),
	token.PORTAL: preload("res://sprites/tokens/token_portal.png"),
	token.STUMBLE: preload("res://sprites/tokens/token_stumble.png"),
	token.ARMY_MARCH: preload("res://sprites/tokens/token_army_march.png"),
	token.WEAKEN: preload("res://sprites/tokens/token_weaken.png"),
}

static var tokenDescriptions = {
	null: null,
	token.NOTHING: "Il n'y a rien sur cette case",
	token.ATTACK: "Vous permet de faire des dégats au monstre, dégats du jeton: ",
	token.SPEED: "Vous fait avancer d'une case",
	token.STUN: "Étourdi le monstre, il n'attaquera pas au prochain tour",
	token.DOUBLE_STRIKE: "Double votre valeur d'attaque actuelle",
	token.FORESEE: "Permet de voir les actions du monstres un peu plus en avance",
	token.LAND_ON_YOUR_FEET: "Permet de récupérer le jeton sur lequel vous atterrissez après avoir été repoussé",
	token.FASTER: "Augmente ta vitesse maximale pour ce combat",
	token.SLOWER: "Diminue ta vitesse maximale pour ce combat",
	token.PREDICT: "Permet des déplacements plus grands au prochain tour",
	token.PREPARE: "Double l'effet du prochain jeton récupéré",
	token.PERSIST: "Permet à un jeton de ton choix de persister un tour de plus",
	token.PORTAL: "Te téléporte sur une case aléatoire",
	token.STUMBLE: "Te fait trébucher",
	token.ARMY_MARCH: "Te fait avancer au début de chaque tour",
	token.WEAKEN: "Affaiblit la prochaine attaque du monstre",
}

static var tokenTypes = {
	token.NOTHING: null,
	token.ATTACK: types.ATTACK,
	token.SPEED: types.MOVEMENT,
	token.STUN: types.POWER,
	token.DOUBLE_STRIKE: types.POWER,
	token.FORESEE: types.POWER,
	token.LAND_ON_YOUR_FEET: types.AUGMENT,
	token.FASTER: types.POWER,
	token.SLOWER: types.TRAP,
	token.PREDICT: types.MISC,
	token.PREPARE: types.MISC,
	token.PERSIST: types.MISC,
	token.PORTAL: types.TRAP,
	token.STUMBLE: types.TRAP,
	token.ARMY_MARCH: types.POWER,
	token.WEAKEN: types.POWER,
}

static var tokenMultipliers = {
	token.NOTHING: 1.,
	token.ATTACK: 1.,
	token.SPEED: 1.,
	token.STUN: 1.,
	token.DOUBLE_STRIKE: 1.,
	token.FORESEE: 1.,
	token.LAND_ON_YOUR_FEET: 1.,
	token.FASTER: 1.,
	token.SLOWER: 0.,
	token.PREDICT: 0,
	token.PREPARE: 1.,
	token.PERSIST: 0,
	token.PORTAL: 0.,
	token.STUMBLE: 0.,
	token.ARMY_MARCH: 1.,
	token.WEAKEN: 1.,
}

static func pickToken(currentTile: int, boardSize: int) -> token:
	var probDict = computeProbabilities(currentTile, boardSize)
	var rndmNum = randf()
	for i in range(1, probDict.size()):
		if rndmNum < probDict[i]:
			return i as token
	return probDict.size()-1 as token

static func computeProbabilities(currentTile: int, boardSize: int):
	var weightDict = computeWeights(currentTile, boardSize)
	var totalWeight = weightDict.values().reduce(func(accum, number): return accum + number)
	var probDict = []
	var lastProb = 0.
	for tkn in token.values():
		probDict.append(lastProb + weightDict[tkn]/totalWeight)
		lastProb = probDict[-1]
	return probDict

static func computeWeights(currentTile: int, boardSize: int):
	var weightDict = {}
	for tkn in token.values():
		weightDict[tkn] = tokenWeight(tkn, currentTile, boardSize)
	return weightDict

static func tokenWeight(tkn, currentTile: int, boardSize: int):
	var returnValue: float
	var multiplier: float = tokenMultipliers[tkn]
	match tokenTypes[tkn]:
		types.POWER:
			multiplier *= powerMultiplier
		types.MOVEMENT:
			multiplier *= movementMultiplier
		types.AUGMENT:
			multiplier *= augmentMultiplier
		types.MISC:
			multiplier *= miscMultiplier
		types.TRAP:
			multiplier *= trapMultiplier
		_:
			multiplier *= 1.
	match tokenRarities[tkn]:
		rarities.COMMON:
			returnValue = weightCommon(currentTile, boardSize)*multiplier*commonMultiplier
		rarities.UNCOMMON:
			returnValue = weightUncommon(currentTile, boardSize)*multiplier*uncommonMultiplier
		rarities.RARE:
			returnValue = weightRare(currentTile, boardSize)*multiplier*rareMultiplier
		rarities.EPIC:
			returnValue = weightEpic(currentTile, boardSize)*multiplier*epicMultiplier
		_:
			returnValue = 0.
	return returnValue

static func weightCommon(currentTile: int, boardSize: int):
	return (weightAtEndCommon - weightAt0Common)*((currentTile-1.)/(boardSize-1.)) + weightAt0Common

static func weightUncommon(currentTile: int, boardSize: int):
	return constWeightUncommon

static func weightRare(currentTile: int, boardSize: int):
	return (weightAtEndRare - weightAt0Rare)*((currentTile-1.)/(boardSize-1.))+ weightAt0Rare

static func weightEpic(currentTile: int, boardSize: int):
	return weightAt0Epic*exp(-growthFactorEpic**((currentTile-1.)/(boardSize-1.)))
