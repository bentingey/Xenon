extends Node2D

@export var system_scene: PackedScene
@export var planet_scene: PackedScene


func _ready() -> void:
	var system = system_scene.instantiate()
	add_child(system)
	system.generate_system(5, 1000, ["terrestrial", "gas giant", "ice", "lava", "ocean"])
	
	$EnemySpawner.player = $Player
