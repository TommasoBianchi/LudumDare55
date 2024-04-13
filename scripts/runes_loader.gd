extends Node

#class RuneD

var rune_data = [
	[
		RuneData.new(preload("res://assets/sprites/runes/rune melee 1.png")),
		RuneData.new(preload("res://assets/sprites/runes/rune melee 2.png")),
		RuneData.new(preload("res://assets/sprites/runes/rune melee 3.png"))
	],
	[
		RuneData.new(preload("res://assets/sprites/runes/rune ranged 1.png")),
		RuneData.new(preload("res://assets/sprites/runes/rune ranged 2.png")),
		RuneData.new(preload("res://assets/sprites/runes/rune ranged 3.png"))
	],
	[
		RuneData.new(preload("res://assets/sprites/runes/rune support 1.png")),
		RuneData.new(preload("res://assets/sprites/runes/rune support 2.png")),
		RuneData.new(preload("res://assets/sprites/runes/rune support 3.png"))
	]
]

func get_rune_data(type: int, tier: int) -> RuneData:
	if type - 1 >= len(rune_data) or tier - 1 >= len(rune_data[type - 1]):
		printerr("Unable to find rune data for type %d and tier %d" % type, tier)
		return RuneData.new(preload("res://assets/sprites/runes/rune melee 1.png"))
	return rune_data[type - 1][tier - 1]
