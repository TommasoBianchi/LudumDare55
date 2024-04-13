extends Node2D

@export var spawn_delays: Array[int]
@export var spawned_enemies_container: Node
@export var enemy_type: String

var _current_index: int = 0
var _elapsed_time: float = 0

func _process(delta):
	_elapsed_time += delta
	
	var num_to_spawn = 0
	while _current_index < len(spawn_delays) and _elapsed_time > spawn_delays[_current_index]:
		_current_index += 1
		num_to_spawn += 1
		
	_spawn_enemies(num_to_spawn)
	
	if _current_index >= len(spawn_delays):
		_turn_off()
		
func _spawn_enemies(amount: int):
	for i in range(amount):
		var creature = CreatureFactory.spawn_enemy(global_position, spawned_enemies_container, enemy_type)
	
func _turn_off():
	# TODO: add some VFX
	queue_free()
