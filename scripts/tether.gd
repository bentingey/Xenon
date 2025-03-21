extends Line2D

@onready var player = get_tree().get_first_node_in_group("player")

var tethered_planet: Node2D = null

func _process(_delta):
	if not player:
		return
	
	tethered_planet = player.tethered_planet
	
	# Update line only if tethered
	if player.tethered and tethered_planet:
		var player_pos = player.global_position
		var planet_pos = tethered_planet.global_position
		points = [player_pos, planet_pos]
		show()
	else:
		hide()
