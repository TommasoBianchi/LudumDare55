extends Node2D

func keep_movement_in_map(current_position: Vector2, movement: Vector2, map: Rect2):
	var next_position = current_position + movement
	
	if next_position.x < map.position.x or next_position.x > map.end.x:
		movement.x = 0
	if next_position.y < map.position.y or next_position.y > map.end.y:
		movement.y = 0
		
	return movement
