extends RefCounted

class_name PlacedRuneData

var position: Vector2
var charge: float

func _init(position: Vector2, charge: float):
	self.position = position
	self.charge = charge
