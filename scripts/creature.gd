extends Node2D

class_name Creature

enum CreatureType { SUMMON, ENEMY }
enum AttackType { MELEE, RANGED, AOE, HEALER }
enum ChildEnemySpawnType { NEVER, ON_ATTACK, ON_DEATH }

@export var animated_sprite: AnimatedSprite2D
@export var sfx_audio_player_prefab: PackedScene
@export var projectile_prefab: PackedScene
@export var area_of_effect_prefab: PackedScene

var move_speed: float = 0:
	get:
		return move_speed + PowerupModifiers.summon_move_speed
var type: CreatureType
var attack_type: AttackType
var current_health: float
var damage: float:
	get:
		return damage + PowerupModifiers.summon_damage
var range: float:
	get:
		return range + (PowerupModifiers.summon_melee_range if attack_type == AttackType.MELEE else PowerupModifiers.summon_melee_range)
var attack_speed: float:
	get:
		return attack_speed + PowerupModifiers.summon_attack_speed
var shield: float
var crit_chance: float:
	get:
		return crit_chance + PowerupModifiers.summon_crit_chance
var crit_damage: float:
	get:
		return crit_damage + PowerupModifiers.summon_crit_damage
var die_on_attack: bool = false
# NOTE: these make sense only for enemy creatures
var child_enemy_spawn_enemy_type: String
var child_enemy_spawn_type: ChildEnemySpawnType

var death_sound: AudioStreamWAV
var hit_sound: AudioStream
var movement: BaseMovement = BaseMovement.new()
var targeter: BaseTargeter = BaseTargeter.new()
var attack_targeter: BaseAttackTargeter = BaseAttackTargeter.new()

var room: Room

var _sfx_audio_player: SFXAudioPlayer

@onready var _player: Player = get_tree().get_nodes_in_group("player")[0] as Player
var _attack_cooldown: float = 0

func _ready():
	assert(animated_sprite != null)
	var _own_group = "summons" if type == CreatureType.SUMMON else "enemies"
	add_to_group(_own_group)
	_sfx_audio_player = sfx_audio_player_prefab.instantiate()
	get_parent().add_child(_sfx_audio_player)

func _process(delta):
	if current_health <= 0:
		# Creature is dead, don't do anything other than finishing death animation
		return

	var _own_group = "summons" if type == CreatureType.SUMMON else "enemies"
	var _enemy_group = "enemies" if type == CreatureType.SUMMON else "summons"
	
	var enemy_creatures: Array[Creature]
	enemy_creatures.assign(get_tree().get_nodes_in_group(_enemy_group))
	var ally_creatures: Array[Creature]
	ally_creatures.assign(get_tree().get_nodes_in_group(_own_group))
	ally_creatures = ally_creatures.filter(func (c): return c != self)
	
	var target: Target = targeter.compute_target(
		global_position,
		enemy_creatures,
		ally_creatures,
		_player.global_position
	)
	
	var has_target: bool = target != null
	
	var direction = movement.compute_next_direction(
		global_position,
		target.position if has_target else Vector2.ZERO,
		has_target,
		Utils.get_map_rect(),
		delta
	)
	
	_attack_cooldown = max(0, _attack_cooldown - delta)  # NOTE: this way the first frame attacking after a long pause moving will always be a hit
	var attack_targets: Array[Target] = attack_targeter.compute_target(
		target,
		global_position,
		enemy_creatures,
		ally_creatures,
		_player.global_position
	)

	var can_attack: bool = attack_targets.filter(func (t): return t != null).any(func (t): return (t.position - global_position).length_squared() < range ** 2)
	var can_move: bool = direction != Vector2.ZERO and (not can_attack or attack_type == AttackType.RANGED or child_enemy_spawn_type == ChildEnemySpawnType.ON_ATTACK)
	
	if can_attack:
		_process_attack(attack_targets)
	if can_move:
		_process_move(direction, delta)
		
	if can_attack:
		animated_sprite.play("attack")
	elif can_move:
		animated_sprite.play("move")
	else:
		# Is idle, so stop animation
		animated_sprite.stop()

func _process_attack(targets: Array[Target]):
	if _attack_cooldown > 0 or len(targets) == 0:
		return

	var has_crit: bool = randf_range(0, 100) < crit_chance
	var actual_damage = damage * (1 if not has_crit else min(100, crit_damage) / 100)
	if attack_type == AttackType.HEALER:
		actual_damage = -actual_damage
	for target in targets:
		_sfx_audio_player.play_sound(hit_sound)
		if attack_type == AttackType.MELEE or attack_type == AttackType.AOE or attack_type == AttackType.HEALER:
			(target.creature if target.creature else _player).receive_hit(self, actual_damage)
		elif attack_type == AttackType.RANGED:
			_spawn_projectile(target, actual_damage)
	if attack_type == AttackType.AOE:
		_spawn_area_of_effect(actual_damage)
		
	# Always face first target
	var towards_first_target = targets[0].position - global_position
	_flip_sprite(towards_first_target)
		
	_attack_cooldown = 1 / attack_speed
	
	if type == CreatureType.ENEMY and child_enemy_spawn_type == ChildEnemySpawnType.ON_ATTACK:
		_spawn_child_enemy()
	
	if die_on_attack:
		_die()

func _flip_sprite(facing_direction: Vector2):
	if facing_direction.x <= 0 or facing_direction.y <= 0:
		# Left or Up
		animated_sprite.flip_h = false
	else:
		# Right or Down
		animated_sprite.flip_h = true

func _spawn_projectile(target: Target, damage: float):
	var projectile: Projectile = projectile_prefab.instantiate()
	projectile.position = global_position  # TODO: think about having an explicit spawn position
	projectile.damage = damage
	projectile.direction = (target.position - global_position).normalized()
	projectile.attacker_type = type
	
	# NOTE: this is not the cleanest, but it works as it should
	get_parent().add_child(projectile)

func _spawn_area_of_effect(damage: float):
	var area_of_effect: AreaOfEffect = area_of_effect_prefab.instantiate()
	area_of_effect.position = global_position 
	area_of_effect.damage = damage
	area_of_effect.attacker_type = type
	
	# NOTE: this is not the cleanest, but it works as it should
	get_parent().add_child(area_of_effect)

func _process_move(direction: Vector2, delta: float):
	var movement = Utils.keep_movement_in_map(
		global_position,
		direction.normalized() * move_speed * delta,
		Utils.get_map_rect()
	)
	translate(movement)	
	_flip_sprite(movement)

func receive_hit(from: Creature, damage: float):
	if damage >= 0:
		var damage_after_shield = max(0, damage - shield)
		shield = max(0, shield - damage)
		current_health -= damage_after_shield
	else:
		# This is a heal
		current_health -= damage
	
	if current_health <= 0:
		_die()

func _spawn_child_enemy():
	CreatureFactory.spawn_enemy(global_position, get_parent(), child_enemy_spawn_enemy_type, room)

func _die():
	animated_sprite.play("death")
	_sfx_audio_player.play_sound(death_sound, true)
	room.creature_died(self)
	if type == CreatureType.ENEMY and child_enemy_spawn_type == ChildEnemySpawnType.ON_DEATH:
		_spawn_child_enemy()
	# Avoid being targeted by other creatures while dying
	var own_group = "summons" if type == CreatureType.SUMMON else "enemies"
	remove_from_group(own_group)
	$Area2D.queue_free()  # This is to stop interacting with projectiles
	($QueueFreeTimer as Timer).start(1)
