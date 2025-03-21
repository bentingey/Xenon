extends Camera2D

@export var prelaunch_offset: float = -380.0
@export var smoothing_speed: float = 0.25
var launched: bool = false


func _ready():
	offset.y = prelaunch_offset
	var player = get_parent()
	if player:
		player.launched_signal.connect(_on_player_launched)
	

func _on_player_launched():
	launched = true
	
func _process(delta):
	if launched:
		await get_tree().create_timer(1.0).timeout
		offset.y = lerp(offset.y, 0.0, delta * smoothing_speed)
