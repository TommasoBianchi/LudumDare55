extends Node

var creature_prefab: PackedScene = preload("res://scenes/creature.tscn")

func _spawn_creature(position: Vector2, parent: Node, type: Creature.CreatureType, properties: CreaturePropertiesLoader.CreatureProperties, room: Room) -> Creature:
	var creature: Creature = creature_prefab.instantiate()
	creature.type = type
	creature.global_position = position
	creature.room = room
	
	creature.stats = properties.stats.apply_modifiers(type)
	creature.assets = properties.assets
	creature.behaviours = properties.behaviours.copy()
	
	creature.current_health = creature.stats.health
	creature.current_shield = creature.stats.shield
	creature.animated_sprite.sprite_frames = creature.assets.sprite_frames
	
	parent.add_child(creature)
	return creature
	
func spawn_summon(position: Vector2, parent: Node, rune_level: int, summon_level: int, room: Room):
	var properties = CreaturePropertiesLoader.get_summon_stats(rune_level, summon_level)
	if properties == null:
		print("[ERROR] creature_factory failed to spawn summon")
		return null

	var creature = _spawn_creature(position, parent, Creature.CreatureType.SUMMON, properties, room)
	return creature
	
func spawn_enemy(position: Vector2, parent: Node, enemy_type: String, room: Room):
	var properties = CreaturePropertiesLoader.get_enemy_stats(enemy_type)
	if properties == null:
		print("[ERROR] creature_factory failed to spawn enemy")
		return null

	var creature = _spawn_creature(position, parent, Creature.CreatureType.ENEMY, properties, room)
	return creature
