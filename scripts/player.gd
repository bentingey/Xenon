extends CharacterBody2D

@export var oscillation_speed: float = 1.0
@export var oscillation_amplitude = 200.0
@export var SPEED: float = 400.0

@export var perfect_entry_threshold: float = 17.0  # Degrees
@onready var last_tethered_planet: Node2D = null

var perfect_entry_streak: int = 0

var initial_x: float
var time_elapsed: float = 0.0
var launched: bool = false
signal launched_signal

var anchor_position: Vector2
var tethered: bool = false
var tether_length: float = 0.0
var tethered_planet: Node2D = null
signal tether_enabled
signal tether_disabled

func _ready():
	initial_x = position.x

func _physics_process(delta: float) -> void:
	if launched:
		# Apply gravity from nearby planets before velocity constraint
		apply_gravity(delta)
		
		# Maintain velocity at constant speed no matter postion constraints
		if velocity.length() > 0: # Prevent division by zero
			velocity = velocity.normalized() * SPEED
			
		if Input.is_action_just_pressed("action"):
			tethered = true
			initialize_tether_parameters()
			check_orbit_entry()
			emit_signal("tether_enabled")
			
		if Input.is_action_just_released("action"):
			tethered = false
			tethered_planet = null
			emit_signal("tether_disabled")
			
		if tethered:
			constrain_to_tether(delta)

		move_and_slide()
		return # Skip launch functionality after launch
	
	# Pre-launch oscillation
	time_elapsed += delta # Increment time
	position.x = initial_x + sin(time_elapsed * oscillation_speed) * oscillation_amplitude # Oscillate left and right
	
	if Input.is_action_just_pressed("action"):
		launched = true
		emit_signal("launched_signal")
		velocity = Vector2(0, -SPEED) # Seems like this line can be omitted, not sure how its getting correct direction in that case

func apply_gravity(delta):
	var total_gravity = Vector2.ZERO  # Accumulates gravity forces from all planets

	for planet in get_tree().get_nodes_in_group("planets"):
		if not "gravity_strength" in planet:
			print(planet.name, " has no gravity_strength property")
			continue  # Skip planets without gravity

		var gravity_strength = planet.get("gravity_strength")
		if gravity_strength <= 0:
			continue  # Skip planets with no gravity left

		var distance_vector = planet.global_position - global_position
		var distance = distance_vector.length() - planet.radius

		if distance > 0:  # Prevent division by zero
			# Apply a smoothstep-like curve: stronger at mid-range, weaker near planet
			var gravity_force = gravity_strength * (1.0 - exp(-distance * 0.005)) / (distance * distance + 1)
			total_gravity += distance_vector.normalized() * gravity_force  # Sum gravity forces

			consume_gravity(planet, delta, distance, tethered_planet)

	# Apply accumulated gravity force to velocity
	velocity += total_gravity * delta

func consume_gravity(planet: StaticBody2D, delta: float, distance: float, tethered_planet: StaticBody2D):
	if planet != tethered_planet:
		return  # Skip planets that are not tethered
	
	if planet.gravity_strength <= 0:
		return  # Stop if gravity is already depleted

	# Linear decay rate (adjust as needed)
	var decay_rate = -64_000 * distance + 15_600_000  # Gravity lost per second

	# Apply constant linear decay
	planet.gravity_strength = max(0, planet.gravity_strength - (decay_rate * delta))

	# Update gravity meter
	planet.update_gravity_meter()
	
func initialize_tether_parameters():
	# Set tethered_planet and tether_length initially and not every frame
	if tethered_planet:
		return
	
	tethered_planet = find_nearest_planet()
	anchor_position = tethered_planet.global_position
	tether_length = (global_position - anchor_position).length()

func check_orbit_entry():
	if not tethered:
		return
	
	var tether_vector = (tethered_planet.global_position - global_position).normalized()
	var velocity_direction = velocity.normalized()
	
	var dot_product = velocity_direction.dot(tether_vector)
	var angle = rad_to_deg(acos(abs(dot_product))) # in degrees
	
	if tethered_planet == last_tethered_planet:
		perfect_entry_streak = 0
		return
	
	last_tethered_planet = tethered_planet
	
	if angle >= 90 - perfect_entry_threshold and angle <= 90 + perfect_entry_threshold:
		perfect_entry_streak += 1
		if perfect_entry_streak == 1:
			print("perfect entry!")
		elif perfect_entry_streak > 1:
			print("perfect entry x", perfect_entry_streak, "!")
	else:
		perfect_entry_streak = 0

func find_nearest_planet() -> Node2D:
	var min_distance = INF
	var nearest_planet = null
	for planet in get_tree().get_nodes_in_group("planets"):
		var distance = (global_position - planet.global_position).length()
		var distance_from_surface = distance - planet.radius
		if distance_from_surface < min_distance:
			min_distance = distance_from_surface
			nearest_planet = planet
	return nearest_planet

func constrain_to_tether(delta):
	var displacement: Vector2 = global_position - anchor_position
	var distance_from_anchor = displacement.length()

	# Constrain position to tether length
	global_position = anchor_position + displacement.normalized() * tether_length

	# Adjust velocity to avoid stopping but stay within the constraint
	var correction_vector = displacement.normalized() * (distance_from_anchor - tether_length)
	velocity -= correction_vector / delta
