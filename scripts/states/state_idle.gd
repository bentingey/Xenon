extends State
class_name EnemyIdle

@export var enemy: CharacterBody2D
@export var move_speed:= 15

var player: CharacterBody2D

var move_direction: Vector2
var wander_time: float
	
# This function runs when the enemy enters this state.
func Enter():
	# gets player do we can track distance in physics_update
	player = get_tree().get_first_node_in_group("player")
	
	# Stops movement
	enemy.velocity = Vector2.ZERO
		
func Physics_Update(_delta: float):
	# get the direction between the player and the enemy
	var direction = player.global_position - enemy.global_position
	
	# if the distance to the player is less than 50, start approaching
	if direction.length() < 5000:
		Transitioned.emit(self, "approach")
	else:
		# Stops movement
		enemy.velocity = Vector2.ZERO
