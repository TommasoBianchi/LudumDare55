extends Node2D

class_name AreaOfEffect

var damage: float
var attacker_type: Creature.CreatureType

func _on_finished():
	queue_free()
