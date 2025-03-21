extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_margin: float = 100.0
@export var spawn_interval: float = 2.0

var player: Node2D

func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.start()

func get_offscreen_position() -> Vector2:
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if not camera:
		return Vector2.ZERO

	var screen_size = viewport.get_visible_rect().size
	var player_pos = player.global_position

	# Decide a random edge to spawn from: 0=top, 1=bottom, 2=left, 3=right
	var edge = randi() % 4
	var pos = Vector2()

	match edge:
		0: # Top
			pos.x = player_pos.x + randf_range(-screen_size.x/2, screen_size.x/2)
			pos.y = player_pos.y - screen_size.y/2 - spawn_margin
		1: # Bottom
			pos.x = player_pos.x + randf_range(-screen_size.x/2, screen_size.x/2)
			pos.y = player_pos.y + screen_size.y/2 + spawn_margin
		2: # Left
			pos.x = player_pos.x - screen_size.x/2 - spawn_margin
			pos.y = player_pos.y + randf_range(-screen_size.y/2, screen_size.y/2)
		3: # Right
			pos.x = player_pos.x + screen_size.x/2 + spawn_margin
			pos.y = player_pos.y + randf_range(-screen_size.y/2, screen_size.y/2)

	return pos


func _on_timer_timeout() -> void:
	if not player:
		print("not player")
		return

	var spawn_pos = get_offscreen_position()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
