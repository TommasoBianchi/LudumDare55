extends Node2D

class_name Room

@export var spawned_enemies_container: Node
@export var placed_runes_container: Node
@export var spawned_creatures_container: Node
@export var enemy_spawner_prefab: PackedScene
@export var player_prefab: PackedScene
@export var room_data: RoomData
@export var spawner_positions_margin: int = 200

var _total_enemies: int = 0
var _dead_enemies: int = 0
var _dead_summons: int = 0

func _ready():
	_setup_player()
	_setup_spawners()
		
func _setup_player():
	var player: Player = player_prefab.instantiate()
	player.position = get_viewport_rect().get_center()
	player.room = self
	player.placed_runes_container = placed_runes_container
	player.spawned_creatures_container = spawned_creatures_container
	add_child(player)
	
func _setup_spawners():
	var viewport_rect = get_viewport_rect().grow(-spawner_positions_margin)
	var enemy_spawners_config = room_data.randomize_spawners_config()
	
	for config in enemy_spawners_config:
		var enemy_spawner: EnemySpawn = enemy_spawner_prefab.instantiate()
		var position = Vector2(
			randf_range(viewport_rect.position.x, viewport_rect.end.x),
			randf_range(viewport_rect.position.y, viewport_rect.end.y)
		)
		enemy_spawner.position = position
		enemy_spawner.name = "Enemy Spawner %d" % config.id
		enemy_spawner.enemy_types_to_spawn = config.enemy_types_to_spawn
		enemy_spawner.delays_between_spawns = config.delays_between_spawns
		enemy_spawner.spawned_enemies_container = spawned_enemies_container
		enemy_spawner.room = self
		_total_enemies += len(config.enemy_types_to_spawn)
		add_child(enemy_spawner)
		
func creature_died(creature: Creature):
	if creature.type == Creature.CreatureType.SUMMON:
		_dead_summons += 1
	elif creature.type == Creature.CreatureType.ENEMY:
		_dead_enemies += 1
		if _dead_enemies >= _total_enemies:
			_clear_room()
			
func _clear_room():
	# TODO: do something
	print("ROOM CLEARED")
