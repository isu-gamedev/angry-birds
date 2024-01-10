extends RigidBody2D
class_name Obstacle

export(Texture) var debris_texture

signal hit

func get_debris_texture() -> Texture:
	return debris_texture


func get_class():
	return "Obstacle"
