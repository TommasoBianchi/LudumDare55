extends RefCounted

class_name PlacedRuneData

var position: Vector2
var level: int
var sprite: Sprite2D

func _init(position: Vector2, level: int, sprite: Sprite2D):
	self.position = position
	self.level = level
	self.sprite = sprite
	
func set_summon_level(summon_level: int):
	sprite.texture = RunesLoader.get_rune_data(level, summon_level).sprite
	
	var old_scale = sprite.scale
	var tween = sprite.get_tree().create_tween()
	tween.tween_property(sprite, "scale", old_scale * 1.1, 0.1)
	tween.tween_property(sprite, "scale", old_scale * 1.1, 0.1)
