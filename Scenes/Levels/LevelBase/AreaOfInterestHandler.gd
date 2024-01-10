extends Node2D


onready var camera_manager = get_node("../CameraFocus")

var area: Area2D
var cshape: CollisionShape2D

var projectiles_to_check = []


func _ready():
	var areas = get_tree().get_nodes_in_group("area_of_interest")
	assert(len(areas) == 1, "Error: only 1 AreaOfInterest is currently supported.")
	area = areas[0]
	cshape = area.get_node("CollisionShape2D")
	assert(area.get_child_count() == 1, "Error: AreaOfInterest node should have only one child CollisionShape2D")
	area.connect("body_exited", self, "_on_AreaOfInterest_body_exited")
	yield(get_tree(), "idle_frame")
	camera_manager.set_camera_limits(area)


func _on_AreaOfInterest_body_exited(body):
	if body is Projectile:
		if body.state != Projectile.STATES.MOVING:
			return
		var cshape: CollisionShape2D = area.get_node("CollisionShape2D")
		if body.position.x > area.position.x - cshape.shape.extents.x and body.position.x < area.position.x + cshape.shape.extents.x:
			projectiles_to_check.append(body)
			return
		remove_projectile(body)

func remove_projectile(obj: Projectile):
	obj.state = Projectile.STATES.STOPPED
	obj.emit_signal("almost_stopped")
	obj.queue_free()


func _process(delta):
	for proj in projectiles_to_check:
		if proj.position.x > area.position.x - cshape.shape.extents.x and proj.position.x < area.position.x + cshape.shape.extents.x:
			return
		remove_projectile(proj)
		projectiles_to_check.erase(proj)
