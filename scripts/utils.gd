extends Node2D

enum WallPosition { UP, DOWN, LEFT, RIGHT }

func find_colliding_walls(current_position: Vector2, map: Rect2) -> Array[WallPosition]:
	var colliding_walls: Array[WallPosition] = []
	
	if current_position.x <= map.position.x:
		colliding_walls.append(WallPosition.LEFT)
	if current_position.x >= map.end.x:
		colliding_walls.append(WallPosition.RIGHT)
	if current_position.y <= map.position.y:
		colliding_walls.append(WallPosition.UP)
	if current_position.y >= map.end.y:
		colliding_walls.append(WallPosition.DOWN)
		
	return colliding_walls

func keep_movement_in_map(current_position: Vector2, movement: Vector2, map: Rect2):
	var next_position = current_position + movement
	var colliding_walls = find_colliding_walls(next_position, map)
	
	if WallPosition.LEFT in colliding_walls:
		movement.x = max(map.position.x - current_position.x, movement.x)
	if WallPosition.RIGHT in colliding_walls:
		movement.x = min(map.end.x - current_position.x, movement.x)
	if WallPosition.UP in colliding_walls:
		movement.y = max(map.position.y - current_position.y, movement.y)
	if WallPosition.DOWN in colliding_walls:
		movement.y = min(map.end.y - current_position.y, movement.y)
		
	return movement

func get_closest(position: Vector2, nodes: Array[Node2D]) -> Node2D:
	assert(len(nodes) > 0)
	
	var closest_node = nodes[0]
	var closest_distance = (position - nodes[0].global_position).length_squared()
	
	for node in nodes:
		var distance = (position - node.global_position).length_squared()
		if distance < closest_distance:
			closest_node = node
			closest_distance = distance
			
	return closest_node
