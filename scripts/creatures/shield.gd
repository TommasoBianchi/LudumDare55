extends Sprite2D

class_name Shield

func set_sprite(sprite: Texture2D):
	texture = sprite
	var size: Vector2 = sprite.get_size()
	offset = Vector2(0, -size.y / 2 * scale.y)
