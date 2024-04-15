extends Node2D

class_name Room

@export var spawned_enemies_container: Node
@export var placed_runes_container: Node
@export var spawned_creatures_container: Node
@export var enemy_spawner_prefab: PackedScene
@export var player_prefab: PackedScene
@export var room_data: RoomData
@export var spawner_positions_margin: int = 200
@export var spawners_min_distance_from_player: int = 400

var _total_enemies_from_spawners: int = 0
var dead_enemies: int = 0
var dead_summons: int = 0
var _player: Player
var _enemy_spawners: Array[EnemySpawn]
var _is_stopped: bool = true

signal on_room_cleared
signal on_player_died

func setup():
	_setup_player()
	_setup_spawners()
	
func start():
	_player.enable_input(true)
	for spawner in _enemy_spawners:
		spawner.start()
	_is_stopped = false

func stop():
	_player.enable_input(false)
	_is_stopped = true
		
func _setup_player():
	_player = player_prefab.instantiate()
	_player.position = get_viewport_rect().get_center()
	_player.room = self
	_player.placed_runes_container = placed_runes_container
	_player.spawned_creatures_container = spawned_creatures_container
	add_child(_player)
	
func _setup_spawners():
	var viewport_rect = get_viewport_rect().grow(-spawner_positions_margin)
	var enemy_spawners_config = room_data.randomize_spawners_config()
	
	for config in enemy_spawners_config:
		var enemy_spawner: EnemySpawn = enemy_spawner_prefab.instantiate()
		var position = _player.global_position
		while (position - _player.global_position).length_squared() < spawners_min_distance_from_player ** 2:
			print("Position too close to player: " + str(position))
			position = Vector2(
				randf_range(viewport_rect.position.x, viewport_rect.end.x),
				randf_range(viewport_rect.position.y, viewport_rect.end.y)
			)
		enemy_spawner.position = position
		enemy_spawner.name = "Enemy Spawner %d" % config.id
		enemy_spawner.enemy_types_to_spawn = config.enemy_types_to_spawn
		enemy_spawner.delays_between_spawns = config.delays_between_spawns
		enemy_spawner.spawned_enemies_container = spawned_enemies_container
		enemy_spawner.room = self
		_total_enemies_from_spawners += len(config.enemy_types_to_spawn)
		add_child(enemy_spawner)
		_enemy_spawners.append(enemy_spawner)
		
func creature_died(creature: Creature):
	if _is_stopped:
		return

	if creature.type == Creature.CreatureType.SUMMON:
		dead_summons += 1
	elif creature.type == Creature.CreatureType.ENEMY:
		dead_enemies += 1
		if len(get_tree().get_nodes_in_group("enemies").filter(func (node): return node.name != creature.name)) == 0:
			_clear_room()

func player_died():
	if _is_stopped:
		return

	on_player_died.emit()

func _clear_room():
	on_room_cleared.emit()
