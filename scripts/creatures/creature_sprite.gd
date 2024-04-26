extends AnimatedSprite2D

@export var collision_shape: CollisionShape2D

func _ready():
	var sprite_texture: Texture2D = sprite_frames.get_frame_texture("move", 0)
	var size: Vector2 = sprite_texture.get_size()
	offset = Vector2(0, -size.y / 2)
	collision_shape.shape.height = size.y / 2
	collision_shape.shape.radius = size.x / 2
	collision_shape.position = Vector2(0, -size.y / 4)
