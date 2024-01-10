extends Node

onready var hit = $Hit
onready var obstacle_rock_hit = $ObstacleRockHit
onready var obstacle_rock_destroyed = $ObstacleRockDestroyed


func _on_EnemiesHandler_enemy_destroyed(enemy, impact_momentum):
	hit.play()
	

func _on_Obstacle_hit(obstacle, position, destroyed):
	if obstacle is StoneObstacle:
		if destroyed:
			obstacle_rock_destroyed.play()
		else:
			obstacle_rock_hit.pitch_scale = rand_range(0.85, 1.15)
			obstacle_rock_hit.play()
	else:
		hit.play()
