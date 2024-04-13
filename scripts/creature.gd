extends Node2D

class_name Creature

enum CreatureType { SUMMON, ENEMY }

@export var animated_sprite: AnimatedSprite2D

var move_speed: float = 0
var type: CreatureType
var current_health: float
var movement: BaseMovement = BaseMovement.new()
var targeter: BaseTargeter = BaseTargeter.new()

var _own_group = "summons" if type == CreatureType.SUMMON else "enemies"
var _enemy_group = "enemies" if type == CreatureType.SUMMON else "summons"

func _ready():
	assert(animated_sprite != null)
	add_to_group(_own_group)

func _process(delta):
	var enemy_creatures: Array[Creature]
	enemy_creatures.assign(get_tree().get_nodes_in_group(_enemy_group))
	var ally_creatures: Array[Creature]
	ally_creatures.assign(get_tree().get_nodes_in_group(_own_group))
	ally_creatures = ally_creatures.filter(func (c): return c != self)
	
	var target: Target = targeter.compute_target(
		global_position,
		enemy_creatures,
		ally_creatures,
		get_tree().get_nodes_in_group("player")[0].global_position
	)
	var has_target: bool = target != null
	var direction = movement.compute_next_direction(
		global_position,
		target.position if has_target else Vector2.ZERO,
		has_target,
		get_viewport_rect().grow(-50),
		delta
	)
	
	if direction != Vector2.ZERO:
		var movement = Utils.keep_movement_in_map(
			global_position,
			direction.normalized() * move_speed * delta,
			get_viewport_rect().grow(-50)  # TODO: find a better way to define the limits of the map
		)
		translate(movement)
		animated_sprite.play("move")
