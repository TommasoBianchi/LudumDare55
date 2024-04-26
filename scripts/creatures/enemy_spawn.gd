extends Node2D

class_name EnemySpawn

@export var enemy_types_to_spawn: Array[String]
@export var delays_between_spawns: Array[float]
@export var spawned_enemies_container: Node

var room: Room

var _current_index: int = 0
var _elapsed_time: float = 0
var _last_spawn_time: float = 0
var _is_paused: bool = true

func start():
	_is_paused = false
	_elapsed_time = 0
	_current_index = 0
	_last_spawn_time = 0
	
func pause():
	_is_paused = true

func _process(delta):
	if _is_paused:
		return

	_elapsed_time += delta
	
	var types_to_spawn: Array[String] = []
	while _current_index < len(enemy_types_to_spawn) and (_elapsed_time - _last_spawn_time) > delays_between_spawns[min(_current_index, len(delays_between_spawns) - 1)]:
		types_to_spawn.append(enemy_types_to_spawn[_current_index])
		_last_spawn_time = _elapsed_time
		_current_index += 1
		
	if len(types_to_spawn) > 0:
		_spawn_enemies(types_to_spawn)
	
	if _current_index >= len(enemy_types_to_spawn):
		_turn_off()
		
func _spawn_enemies(types_to_spawn: Array[String]):
	for enemy_type in types_to_spawn:
		var creature = CreatureFactory.spawn_enemy(global_position, spawned_enemies_container, enemy_type, room)
	
func _turn_off():
	# TODO: add some VFX
	queue_free()
