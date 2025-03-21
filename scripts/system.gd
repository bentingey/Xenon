extends Node2D

@export var planet_scene: PackedScene

@onready var player = get_tree().get_first_node_in_group("player")

var last_planet_y: int
var num_planets_min: int = 10
var num_planets_max: int = 15

const FIRST_Y_MIN: int = 360
const FIRST_Y_MAX: int = 560
const MIN_Y_SPACING: int = 100
const MAX_Y_SPACING: int = 560
const X_OFFSET_LIMIT: int = 140
const CENTER_X = 704  # Centerline for planets


func _ready():
	if not player:
		print("Error: No player found!")
		return
	generate_system()  # Generate by default

func generate_system(min_planets: int = num_planets_min, max_planets: int = num_planets_max, allowed_types: Array = []):
	# Remove old planets before generating new ones
	for child in get_children():
		if child is StaticBody2D:  # Remove old planets
			child.queue_free()

	var num_planets = randi_range(min_planets, max_planets)  # Randomize number of planets

	# First planet
	last_planet_y = player.global_position.y - randi_range(FIRST_Y_MIN, FIRST_Y_MAX)
	spawn_planet(Vector2(CENTER_X + randi_range(-X_OFFSET_LIMIT, X_OFFSET_LIMIT), last_planet_y), allowed_types)

	# Subsequent planets
	for _i in range(num_planets - 1):
		last_planet_y -= int((randi_range(MIN_Y_SPACING, MAX_Y_SPACING) + randi_range(MIN_Y_SPACING, MAX_Y_SPACING)) / 2)  # Bias Y spacing toward the middle
		spawn_planet(Vector2(CENTER_X + randi_range(-X_OFFSET_LIMIT, X_OFFSET_LIMIT), last_planet_y), allowed_types)

func spawn_planet(position: Vector2, allowed_types: Array):
	var planet = planet_scene.instantiate()

	planet.global_position = position.round()  # Use int positions to avoid blurring
	add_child(planet)

	# Call randomize_planet() after the planet is fully added
	planet.call_deferred("randomize_planet", allowed_types)
