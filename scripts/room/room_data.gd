extends Resource

class_name RoomData

@export var min_enemies_by_type: Dictionary
@export var max_enemies_by_type: Dictionary
@export var min_spawners: int = 1
@export var max_spawners: int = 3
@export var min_time_between_spawns: float = 0
@export var max_time_between_spawns: float = 5

class EnemySpawnerConfig:
	var id: int
	var enemy_types_to_spawn: Array[String]
	var delays_between_spawns: Array[float]
	
	func _init(id: int, enemy_types_to_spawn: Array[String], delays_between_spawns: Array[float]):
		self.id = id
		self.enemy_types_to_spawn = enemy_types_to_spawn
		self.delays_between_spawns = delays_between_spawns

func randomize_spawners_config() -> Array[EnemySpawnerConfig]:
	var num_spawners: int = randi_range(min_spawners, max_spawners)
	
	var all_enemy_types_to_spawn: Array[String] = []
	for enemy_type in min_enemies_by_type.keys():
		var min_num: int = min_enemies_by_type[enemy_type]
		var max_num: int = max_enemies_by_type.get(enemy_type, min_num)
			
		var num_enemies = randi_range(min_num, max_num)
		for i in range(num_enemies):
			all_enemy_types_to_spawn.append(enemy_type)
			
	all_enemy_types_to_spawn.shuffle()
	
	var enemy_spawners_config: Array[EnemySpawnerConfig] = []
	var enemy_type_for_all_spawners: Array[Array] = []
	var delays_for_all_spawners: Array[Array] = []
	var slice_start: int = 0
	for spawner_id in range(num_spawners):
		var remaining_enemies_num: int = len(all_enemy_types_to_spawn) - slice_start
		if remaining_enemies_num <= 0:
			break
		
		var remaining_spawners: int = num_spawners - spawner_id
		var min_enemies_num: int = max(1, remaining_enemies_num / (remaining_spawners + 1))
		var max_enemies_num: int = min(remaining_enemies_num - remaining_spawners + 1, remaining_enemies_num / max(1, remaining_spawners - 1))
		var enemies_num: int = randi_range(min_enemies_num, max_enemies_num)
		if remaining_spawners == 1:
			# The last spawner has to spawn all remaining enemies
			enemies_num = remaining_enemies_num
		var enemy_types: Array[String] = all_enemy_types_to_spawn.slice(slice_start, slice_start + enemies_num)
		slice_start += enemies_num
		
		var delays: Array[float]
		delays.assign(enemy_types.map(func (t): return randf_range(min_time_between_spawns, max_time_between_spawns)))
		
		enemy_spawners_config.append(
			EnemySpawnerConfig.new(
				spawner_id,
				enemy_types,
				delays
			)
		)
		
	return enemy_spawners_config
