extends Node2D

class_name AreaOfEffect

var damage: float
var attacker_type: Creature.CreatureType

func _ready():
	scale = Vector2.ZERO
	
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property(self, "scale", Vector2.ONE, 1)
	
	var tween_alpha = get_tree().create_tween()
	tween_alpha.tween_property($Sprite2D, "modulate", Color.WHITE, 0.8).set_ease(Tween.EASE_IN)
	tween_alpha.tween_property($Sprite2D, "modulate", Color.TRANSPARENT, 0.2).set_ease(Tween.EASE_OUT)

func setup_sprite(sprite: Texture2D):
	$Sprite2D.texture = sprite
