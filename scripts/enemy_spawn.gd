extends Node2D

@export var enemy_types_to_span: Array[String]
@export var delays_between_spawns: Array[int]
@export var spawned_enemies_container: Node

var _current_index: int = 0
var _elapsed_time: float = 0
var _last_spawn_time: float = 0

func _process(delta):
	_elapsed_time += delta
	
	var types_to_spawn: Array[String] = []
	while _current_index < len(enemy_types_to_span) and (_elapsed_time - _last_spawn_time) > delays_between_spawns[min(_current_index, len(delays_between_spawns) - 1)]:
		print(_current_index)
		print(_elapsed_time)
		print(_last_spawn_time)
		print(_elapsed_time - _last_spawn_time)
		print(delays_between_spawns)
		
		types_to_spawn.append(enemy_types_to_span[_current_index])
		_last_spawn_time = _elapsed_time
		_current_index += 1
		
	if len(types_to_spawn) > 0:
		_spawn_enemies(types_to_spawn)
	
	if _current_index >= len(enemy_types_to_span):
		_turn_off()
		
func _spawn_enemies(types_to_spawn: Array[String]):
	print("Spawn " + str(types_to_spawn))
	for enemy_type in types_to_spawn:
		var creature = CreatureFactory.spawn_enemy(global_position, spawned_enemies_container, enemy_type)
	
func _turn_off():
	# TODO: add some VFX
	queue_free()
