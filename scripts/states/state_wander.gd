extends State
class_name EnemyWander

@export var enemy: CharacterBody2D
@export var move_speed:= 15

var player: CharacterBody2D

var move_direction: Vector2
var wander_time: float

# choose a random direction and time to wander
func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	
# This function runs when the enemy enters this state.
func Enter():
	player = get_tree().get_first_node_in_group("Player")
	randomize_wander()
	
# This function runs every frame that the state is active.
func Update(delta: float):
	# Counts down the current wander time. When the time reaches 0, use the randomize_wander function again to choose a new direction
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
		
func Physics_Update(_delta: float):
	# if the enemy exists, set its velocity to the move direction decided by randomize_wander
	if enemy:
		enemy.velocity = move_direction * move_speed
		
	# get the direction between the player and the enemy
	var direction = player.global_position - enemy.global_position
	
	# if player is less than 50 distance away, switch to follow
	if direction.length() < 70:
		Transitioned.emit(self, "follow")
