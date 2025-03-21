extends Area2D

var sound_player := AudioStreamPlayer.new()
@onready var death: AudioStreamPlayer2D = $DeathSound
@onready var player = get_tree().get_nodes_in_group("Player").front()
@onready var coin_parent = get_tree().current_scene.get_node("Coins")

var player_start_pos: Vector2
var coin_positions: Array


func _ready():
	add_child(sound_player)
	player_start_pos = player.global_position # Set player starting position

	#Store initial positions of all coins
	for coin in get_tree().get_nodes_in_group("Coins"):
		coin_positions.append(coin.global_position)

func play_sound(sound: AudioStream):
	sound_player.stream = sound
	sound_player.play()


func _on_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		#SFX.play_sound(death.stream)  # Play sound globally
		player.global_position = player_start_pos # Send player back to start
		reload_children(coin_parent, "res://scenes/coin.tscn")


func reload_children(parent_node: Node, scene_path: String):
	parent_node.visible = false
	var scene = load(scene_path)

	# Delete all current children
	for child in parent_node.get_children():
		child.queue_free()

	await get_tree().process_frame  # Ensure old nodes are fully removed

	# Reinstantiate all original children
	for coin_pos in coin_positions:
		var new_instance = scene.instantiate()
		parent_node.add_child(new_instance)
		new_instance.global_position = coin_pos
		
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
		
	parent_node.visible = true
