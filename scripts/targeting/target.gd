extends RefCounted

class_name Target

var creature: Creature
var position: Vector2

func _init(creature: Creature, position: Vector2):
	self.creature = creature
	self.position = position
	
static func from_creature(creature: Creature) -> Target:
	return Target.new(creature, creature.global_position)
	
static func from_player_position(position: Vector2) -> Target:
	return Target.new(null, position)
