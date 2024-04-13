extends Node2D

class_name Creature

enum CreatureType { SUMMON, ENEMY }

@export var animated_sprite: AnimatedSprite2D

var move_speed: float = 0
var type: CreatureType
var current_health: float
var movement: BaseMovement = BaseMovement.new()

func _ready():
	assert(animated_sprite != null)

func _process(delta):
	var enemy_creatures: Array[Creature] = []
	var ally_creatures: Array[Creature] = []
	
	var direction = movement.compute_next_direction(
		global_position,
		enemy_creatures,
		ally_creatures,
		Vector2.ZERO,  # player_position: Vector2,
		get_viewport_rect().grow(-50)
	)
	
	if direction != Vector2.ZERO:
		var movement = Utils.keep_movement_in_map(
			global_position,
			direction.normalized() * move_speed * delta,
			get_viewport_rect().grow(-50)  # TODO: find a better way to define the limits of the map
		)
		translate(movement)
		animated_sprite.play("move")
