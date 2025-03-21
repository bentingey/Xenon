extends State
class_name EnemyApproach

@export var enemy: CharacterBody2D
@export var move_speed := 40.0
var player: CharacterBody2D

# called when state is entered
func Enter():
	player = get_tree().get_first_node_in_group("player")

# called every frame to decide physics
func Physics_Update(_delta: float):
	# get the direction between the player and the enemy
	var direction = player.global_position - enemy.global_position
	
	# if distance to player is greater than 50, move towards the player. If not, switch back to the idle state
	if direction.length() < 10000:
		enemy.velocity = direction.normalized() * move_speed
	else:
		Transitioned.emit(self, "idle")
