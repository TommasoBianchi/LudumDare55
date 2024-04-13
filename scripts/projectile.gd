extends Node2D

class_name Projectile

@export var speed: float = 800

var damage: float
var target: Target
var direction: Vector2

func _process(delta):
	if target:
		# Homing
		direction = (target.position - global_position).normalized()
	
	rotation = direction.angle()
	translate(direction * speed * delta)
