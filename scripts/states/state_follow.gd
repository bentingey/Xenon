extends State
class_name EnemyFollow

@export var enemy: CharacterBody2D
@export var move_speed := 40.0
var player: CharacterBody2D

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	
func Physics_Update(_delta: float):
	# get the direction between the player and the enemy
	var direction = player.global_position - enemy.global_position
	
	# if player is more than 25 distance away, more towards them
	if direction.length() > 25:
		enemy.velocity = direction.normalized() * move_speed
	else:
		enemy.velocity = Vector2()
	
	# if player is more than 50 distance away, switch to wander
	if direction.length() > 50:
		Transitioned.emit(self, "wander")
