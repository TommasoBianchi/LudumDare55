extends Node2D

class_name Creature

enum CreatureType { SUMMON, ENEMY }
enum AttackType { MELEE, RANGED, AOE, HEALER, AOE_BUFF_SHIELD }
enum ChildEnemySpawnType { NEVER, ON_ATTACK, ON_DEATH }

@export var animated_sprite: AnimatedSprite2D
@export var sfx_audio_player_prefab: PackedScene
@export var projectile_prefab: PackedScene
@export var area_of_effect_prefab: PackedScene

var type: CreatureType
var stats: CreaturePropertiesLoader.CreatureStats
var assets: CreaturePropertiesLoader.CreatureAssets
var behaviours: CreaturePropertiesLoader.CreatureBehaviours

var current_health: float
var current_shield: float
var room: Room

@onready var _player: Player = get_tree().get_nodes_in_group("player")[0] as Player
var _attack_cooldown: float = 0
var _sfx_audio_player: SFXAudioPlayer

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
		
	if current_shield > 0:
		($Shield as Shield).set_sprite(assets.shield_sprite)
		$Shield.show()
	else:
		$Shield.hide()

	var _own_group = "summons" if type == CreatureType.SUMMON else "enemies"
	var _enemy_group = "enemies" if type == CreatureType.SUMMON else "summons"
	
	var enemy_creatures: Array[Creature]
	enemy_creatures.assign(get_tree().get_nodes_in_group(_enemy_group))
	var ally_creatures: Array[Creature]
	ally_creatures.assign(get_tree().get_nodes_in_group(_own_group))
	ally_creatures = ally_creatures.filter(func (c): return c != self)
	
	var target: Target = behaviours.targeter.compute_target(
		global_position,
		enemy_creatures,
		ally_creatures,
		_player.global_position
	)
	
	var has_target: bool = target != null
	
	var direction = behaviours.movement.compute_next_direction(
		global_position,
		target.position if has_target else Vector2.ZERO,
		has_target,
		Utils.get_map_rect(),
		delta
	)
	
	_attack_cooldown = max(0, _attack_cooldown - delta)  # NOTE: this way the first frame attacking after a long pause moving will always be a hit
	var attack_targets: Array[Target] = behaviours.attack_targeter.compute_target(
		target,
		global_position,
		enemy_creatures,
		ally_creatures,
		_player.global_position
	)

	var can_attack: bool = attack_targets\
	.filter(func (t): return t != null)\
	.any(func (t): return (t.position - global_position).length_squared() < stats.range ** 2)
	var can_move: bool = (direction != Vector2.ZERO) and\
	(
		not can_attack or\
		stats.attack_type == AttackType.RANGED or\
		behaviours.child_enemy_spawn_type == ChildEnemySpawnType.ON_ATTACK
	)
	
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

	var has_crit: bool = randf_range(0, 100) < stats.crit_chance
	var actual_damage = stats.damage * (1 if not has_crit else min(100, stats.crit_damage) / 100)
	if stats.attack_type == AttackType.HEALER:
		actual_damage = -actual_damage
	for target in targets:
		_sfx_audio_player.play_sound(assets.hit_sound)
		if stats.attack_type in [AttackType.MELEE, AttackType.AOE, AttackType.HEALER]:
			(target.creature if target.creature else _player).receive_hit(self, actual_damage)
		elif stats.attack_type == AttackType.RANGED:
			_spawn_projectile(target, actual_damage)
		elif stats.attack_type == AttackType.AOE_BUFF_SHIELD and target.creature:
			target.creature.shield += actual_damage
	if stats.attack_type in [AttackType.AOE, AttackType.AOE_BUFF_SHIELD]:
		_spawn_area_of_effect(actual_damage)
		
	# Always face first target
	var towards_first_target = targets[0].position - global_position
	_flip_sprite(towards_first_target)
		
	_attack_cooldown = 1 / stats.attack_speed
	
	if type == CreatureType.ENEMY and behaviours.child_enemy_spawn_type == ChildEnemySpawnType.ON_ATTACK:
		_spawn_child_enemy()
	
	if behaviours.die_on_attack:
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
	# NOTE: the position offset is to make creatures spawn from the center of the sprite
	projectile.position = global_position - Vector2(0, animated_sprite.sprite_frames.get_frame_texture("move", 0).get_height() / 2 * animated_sprite.scale.y)
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
	area_of_effect.setup_sprite(assets.aoe_sprite)
	area_of_effect.set_aoe_scale(Vector2(stats.range / assets.aoe_sprite.get_size().x, stats.range / assets.aoe_sprite.get_size().y))
	
	# NOTE: this is not the cleanest, but it works as it should
	get_parent().add_child(area_of_effect)

func _process_move(direction: Vector2, delta: float):
	var movement = Utils.keep_movement_in_map(
		global_position,
		direction.normalized() * stats.speed * delta,
		Utils.get_map_rect()
	)
	translate(movement)	
	_flip_sprite(movement)

func receive_hit(from: Creature, damage: float):
	if damage >= 0:
		var damage_after_shield = max(0, damage - current_shield)
		current_shield = max(0, current_shield - damage)
		current_health -= damage_after_shield
	else:
		# This is a heal
		current_health -= damage
	
	if current_health <= 0:
		_die()

func _spawn_child_enemy(amount: int = 1):
	for i in range(amount):
		CreatureFactory.spawn_enemy(global_position, get_parent(), behaviours.child_enemy_spawn_enemy_type, room)

func _die():
	animated_sprite.play("death")
	_sfx_audio_player.play_sound(assets.death_sound, true)
	room.creature_died(self)
	if type == CreatureType.ENEMY and behaviours.child_enemy_spawn_type == ChildEnemySpawnType.ON_DEATH:
		# NOTE: this is hardcoded (since we have a single enemy with this behaviour) but time is a scarce resource
		_spawn_child_enemy(2)
	# Avoid being targeted by other creatures while dying
	var own_group = "summons" if type == CreatureType.SUMMON else "enemies"
	remove_from_group(own_group)
	$Area2D.queue_free()  # This is to stop interacting with projectiles
	($QueueFreeTimer as Timer).start(1)
