extends Node2D

class_name Creature

enum CreatureType { SUMMON, ENEMY }
enum AttackType { MELEE, RANGED, AOE }

@export var animated_sprite: AnimatedSprite2D
@export var sfx_audio_player_prefab: PackedScene
@export var projectile_prefab: PackedScene
@export var area_of_effect_prefab: PackedScene

var move_speed: float = 0
var type: CreatureType
var attack_type: AttackType
var current_health: float
var damage: float
var range: float
var attack_speed: float
var shield: float
var crit_chance: float
var crit_damage: float
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
		get_viewport_rect().grow(-50),
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
	var can_move: bool = direction != Vector2.ZERO and (not can_attack or attack_type == AttackType.RANGED)
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
		
	var has_crit: bool = randf_range(0, 100) > crit_chance
	var actual_damage = damage * (1 if not has_crit else crit_damage / 100)
	for target in targets:
		if attack_type == AttackType.MELEE:
			(target.creature if target.creature else _player).receive_hit(self, actual_damage)
			_sfx_audio_player.play_sound(hit_sound)
		elif attack_type == AttackType.RANGED:
			_spawn_projectile(target, actual_damage)
		elif attack_type == AttackType.AOE:
			_spawn_area_of_effect(actual_damage)
		
	_attack_cooldown = 1 / attack_speed

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
		get_viewport_rect().grow(-50)  # TODO: find a better way to define the limits of the map
	)
	translate(movement)

func receive_hit(from: Creature, damage: float):
	var damage_after_shield = max(0, damage - shield)
	shield = max(0, shield - damage)
	current_health -= damage_after_shield
	
	if current_health <= 0:
		# TODO: death animation
		_sfx_audio_player.play_sound(death_sound, true)
		room.creature_died(self)
		queue_free()
