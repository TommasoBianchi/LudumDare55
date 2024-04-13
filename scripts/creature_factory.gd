extends Node

var creature_prefab: PackedScene = preload("res://scenes/creature.tscn")

func _spawn_creature(position: Vector2, parent: Node, type: Creature.CreatureType) -> Creature:
	var creature = creature_prefab.instantiate()
	creature.global_position = position
	parent.add_child(creature)
	return creature
	
func spawn_summon(position: Vector2, parent: Node, rune_level: int, summon_level: int):
	var creature = _spawn_creature(position, parent, Creature.CreatureType.SUMMON)
	return creature
	
func spawn_enemy(position: Vector2, parent: Node):
	var creature = _spawn_creature(position, parent, Creature.CreatureType.ENEMY)
	return creature
