extends StaticBody2D

@export var planet_type: String = "terrestrial" # Will be randomized
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var radius: float = 8.0
var gravity: float = 100.0
var gravity_strength: float
var initial_gravity_strength: float

# Predefined planet categories with size and gravity ranges
const PLANET_TYPES = {
	"asteroid": { "radius_range": Vector2(4, 6), "gravity_range": Vector2(40, 44), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.773, 0.557, 0.459) },
	"terrestrial": { "radius_range": Vector2(12, 18), "gravity_range": Vector2(112, 118), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.722, 0.694, 0.659) },
	"gas giant": { "radius_range": Vector2(32, 48), "gravity_range": Vector2(164, 196), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.506, 0.306, 0.365) },
	"ice": { "radius_range": Vector2(6, 8), "gravity_range": Vector2(86, 90), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.373, 0.945, 0.965) },
	"metallic": { "radius_range": Vector2(18, 24), "gravity_range": Vector2(136, 148), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.624, 0.612, 0.6) },
	"earth analog": { "radius_range": Vector2(16, 20), "gravity_range": Vector2(116, 120), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.133, 0.471, 0.298) },
	"ocean": { "radius_range": Vector2(14, 26), "gravity_range": Vector2(114, 126), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.102, 0.369, 1.0) },
	"desert": { "radius_range": Vector2(10, 14), "gravity_range": Vector2(110, 114), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.878, 0.725, 0.549) },
	"lava": { "radius_range": Vector2(12, 16), "gravity_range": Vector2(112, 116), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.812, 0.247, 0.02) },
	"ice giant": { "radius_range": Vector2(28, 36), "gravity_range": Vector2(156, 172), "sprites": ["res://assets/sprites/planet_placeholder.png"], "color": Color(0.345, 0.49, 0.937) }
}

func _ready():
	gravity_strength = gravity * 100000
	initial_gravity_strength = gravity_strength
	
func randomize_planet(allowed_types: Array = []):
	# If specific types are given, pick from them
	var possible_types = PLANET_TYPES.keys() if allowed_types.size() == 0 else allowed_types
	planet_type = possible_types.pick_random()
	var type_data = PLANET_TYPES[planet_type] # Get type data
	
	radius = randf_range(type_data["radius_range"].x, type_data["radius_range"].y) # Set random radius within range
	
	# Scale gravity proportionally to radius, keeping it within range
	var min_radius = type_data["radius_range"].x
	var max_radius = type_data["radius_range"].y
	var min_gravity = type_data["gravity_range"].x
	var max_gravity = type_data["gravity_range"].y
	var normalized_radius = (radius - min_radius) / (max_radius - min_radius)
	gravity = (max_gravity - min_gravity) * normalized_radius + min_gravity
	
	sprite.texture = load(type_data["sprites"].pick_random()) # Pick a random sprite, should eventually adjust color of sprite as well
	sprite.modulate = type_data["color"]
	
	update_gravity_meter()
	update_sprite()
	update_collision_shape()

func update_gravity_meter():
	if $ProgressBar:  # Make sure the bar exists
		var percent = (gravity_strength / initial_gravity_strength) * 100
		$ProgressBar.value = percent

func update_sprite():
	if sprite:
		sprite.scale = Vector2(radius / 8.0, radius / 8.0) # Replace with sprite radius
		
func update_collision_shape():
	if collision_shape:
		collision_shape.scale = Vector2(radius / 8.0, radius / 8.0) # Replace with sprite radius
