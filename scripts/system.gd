extends Node2D

@export var planet_scene: PackedScene
@export var min_spacing: int = 340            # Minimum center-to-center spacing (in pixels)
@export var allowed_types: Array = []         # If empty, all planet types are allowed
@export var spawn_area: Rect2 = Rect2(-1000, -1000, 2000, 2000)  # Area (in pixels) in which to spawn planets

var planet_nodes: Array = []   # Holds references to all currently spawned planets   

# This function spawns 'count' new planets without overlapping existing ones.
func add_planets(count: int, allowed_types: Array):
	var attempts: int = 0
	var max_attempts: int = count * 50  # safeguard to avoid infinite loops

	while count > 0 and attempts < max_attempts:
		# Generate a random candidate position within spawn_area.
		var candidate = Vector2(
			randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
			randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
		)
		
		# Check that candidate is far enough from all existing planets.
		var valid = true
		for planet in planet_nodes:
			if candidate.distance_to(planet.global_position) < min_spacing:
				valid = false
				break
		if valid:
			# Instantiate the planet, set its position, and add it to the scene.
			var planet = planet_scene.instantiate()
			planet.global_position = candidate.round()  # Round to avoid subpixel issues
			add_child(planet)
			
			# Defer randomization so the planet's children (like its Sprite2D) are ready.
			planet.call_deferred("randomize_planet", allowed_types)
			
			# Add to our persistent list.
			planet_nodes.append(planet)
			
			# Connect to the planet's tree_exited signal so we remove it from planet_nodes when it's removed.
			planet.connect("tree_exited", Callable(self, "_on_planet_exited").bind(planet))

			count -= 1
		attempts += 1
	
	print("Total planets spawned:", planet_nodes.size())

# Called when a planet leaves the scene tree.
func _on_planet_exited(planet):
	if planet in planet_nodes:
		planet_nodes.erase(planet)
