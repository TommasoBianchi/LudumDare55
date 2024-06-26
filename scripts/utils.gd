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

func get_closest_creature(position: Vector2, creatures: Array[Creature]) -> Creature:
	var nodes: Array[Node2D]
	nodes.assign(creatures)
	var closest_node = get_closest(position, nodes)
	return closest_node as Creature

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

func get_least_health(creatures: Array[Creature]) -> Creature:
	assert(len(creatures) > 0)
	
	var least_health_creature = creatures[0]
	var health = creatures[0].current_health
	
	for creature in creatures:
		if creature.current_health < health:
			least_health_creature = creature
			health = creature.current_health
			
	return least_health_creature

func get_map_rect():
	var viewport_rect = get_viewport_rect()
	return viewport_rect.grow(-viewport_rect.size.y / (1080.0 / 80.0))
