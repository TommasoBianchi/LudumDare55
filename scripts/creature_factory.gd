extends Node

var creature_prefab: PackedScene = preload("res://scenes/creature.tscn")

func _spawn_creature(position: Vector2, parent: Node, type: Creature.CreatureType) -> Creature:
	var creature = creature_prefab.instantiate()
	creature.global_position = position
	parent.add_child(creature)
	return creature
	
func spawn_summon(position: Vector2, parent: Node, rune_level: int, summon_level: int):
	var creature = _spawn_creature(position, parent, Creature.CreatureType.SUMMON)
	var stats = CreatureProperties.get_summon_stats(rune_level, summon_level)
	print("Summon name: ", stats.name)
	print("Summon health: ", stats.health)
	print("Summon damage: ", stats.damage)
	return creature
	
func spawn_enemy(position: Vector2, parent: Node):
	var creature = _spawn_creature(position, parent, Creature.CreatureType.ENEMY)
	return creature
