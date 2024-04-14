extends Node

var creature_prefab: PackedScene = preload("res://scenes/creature.tscn")

func _spawn_creature(position: Vector2, parent: Node, type: Creature.CreatureType, stats: CreatureProperties.CreatureStats) -> Creature:
	var creature: Creature = creature_prefab.instantiate()
	creature.type = type
	creature.global_position = position
	creature.movement = stats.movement_builder.call()
	creature.targeter = stats.targeter_builder.call()
	creature.move_speed = stats.speed
	creature.current_health = stats.health
	creature.damage = stats.damage
	creature.range = stats.range
	creature.attack_speed = stats.attack_speed
	creature.shield = stats.shield
	creature.crit_chance = stats.crit_chance
	creature.crit_damage = stats.crit_damage
	creature.animated_sprite.sprite_frames = stats.sprite_frames
	creature.death_sound = stats.death_sound
	creature.hit_sound = stats.hit_sound
	parent.add_child(creature)
	return creature
	
func spawn_summon(position: Vector2, parent: Node, rune_level: int, summon_level: int):
	var stats = CreatureProperties.get_summon_stats(rune_level, summon_level)
	var creature = _spawn_creature(position, parent, Creature.CreatureType.SUMMON, stats)
	return creature
	
func spawn_enemy(position: Vector2, parent: Node, enemy_type: String):
	var stats = CreatureProperties.get_enemy_stats(enemy_type)
	var creature = _spawn_creature(position, parent, Creature.CreatureType.ENEMY, stats)
	return creature
