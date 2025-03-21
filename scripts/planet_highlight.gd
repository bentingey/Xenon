extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@export var target_radius_offset: float = 5.0

var target_planet: Node2D = null
var planet_radius: float
var target: bool = false


func _ready():
	if player:
		player.tether_enabled.connect(_on_tether_enabled)
		player.tether_disabled.connect(_on_tether_disabled)

func _process(_delta):
	if not player:
		return
		
	if not target:
		visible = false
		return
	
	visible = true
	# Find nearest planet every frame
	var new_nearest_planet = player.find_nearest_planet()

	# Only update if the nearest planet changed
	if new_nearest_planet != target_planet:
		target_planet = new_nearest_planet
		planet_radius = new_nearest_planet.radius
		queue_redraw()  # Redraw only when necessary

func _on_tether_enabled():
	target = false

func _on_tether_disabled():
	target = true

func _draw():
	if target_planet:
		var center = target_planet.global_position
		var color = Color(0.881, 0.23, 0.219, 1)  # Red
		var target_radius = planet_radius + target_radius_offset  # Scale with planet size
		var hash_length = target_radius * 0.6  # Scale hashes based on planet size
		var thickness = 2  # Line thickness

		# Define the angles for each quadrant (0, 90, 180, 270 degrees)
		var angles = [0, PI / 2, PI, 3 * PI / 2]

		# Draw hash marks at each quadrant
		for angle in angles:
			var dir = Vector2(cos(angle), sin(angle))  # Get direction vector
			var start_pos = center + dir * (target_radius - hash_length / 2)  # Move inward slightly
			var end_pos = center + dir * (target_radius + hash_length / 2)  # Extend outward

			draw_line(start_pos, end_pos, color, thickness)
		draw_arc(center, target_radius, 0, TAU, 32, color, thickness)  # 3px thickness
