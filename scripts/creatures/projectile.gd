extends Node2D

class_name Projectile

@export var speed: float = 800
@export var summon_projectile_sprite: Texture2D
@export var enemy_projectile_sprite: Texture2D

var damage: float
var target: Target
var direction: Vector2
var attacker_type: Creature.CreatureType:
	set(value):
		attacker_type = value
		$Sprite2D.texture = summon_projectile_sprite if attacker_type == Creature.CreatureType.SUMMON else enemy_projectile_sprite

@onready var _viewport_rect = get_viewport_rect()

func _process(delta):
	if target:
		# Homing
		direction = (target.position - global_position).normalized()
	
	rotation = direction.angle()
	translate(direction * speed * delta)
	
	if not _viewport_rect.has_point(global_position):
		queue_free()

func _on_hit(area):
	var hit_node = area.get_parent()
	if hit_node is Creature:
		var hit_creature = hit_node as Creature
		if hit_creature.type != attacker_type:
			hit_creature.receive_hit(null, damage)
			queue_free()
	elif hit_node is Player and attacker_type == Creature.CreatureType.ENEMY:
		(hit_node as Player).receive_hit(null, damage)
		queue_free()
