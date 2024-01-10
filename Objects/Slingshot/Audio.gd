extends Node

onready var released = $Released
onready var slingshot = get_parent()

var last_projectile_pos = Vector2()


func _on_Slingshot_projectile_launched(projectile):
	released.play()


func _process(delta):
	if slingshot.state == slingshot.States.AIMING:
		if last_projectile_pos:
			if last_projectile_pos.distance_to(slingshot.projectile.position) > 50:
				last_projectile_pos = slingshot.projectile.position
		else:
			last_projectile_pos = slingshot.projectile.position
	else:
		last_projectile_pos = null

