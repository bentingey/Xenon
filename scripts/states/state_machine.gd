extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready():
	# loops over all children to check if they are a member of the State class. If they are, add them to the states dictionary.
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child # to_lower is just error handling to make sure capitalization doesnt cause any problems
			# any time we register a new state, we connect to the transition signal from the State class. This connects to the on_child_transition function.
			child.Transitioned.connect(on_child_transition)
	
	# if an initial state has been selected via the exported variable, enter that state and set it to the current state.
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
		
			
func _process(delta):
	# if there is a current state, call the update function of that state.
	if current_state:
		current_state.Update(delta)
		
func _physics_process(delta):
	# if there is a current state, call the physics update function of that state.
	if current_state:
		current_state.Physics_Update(delta)
		
func on_child_transition(state, new_state_name):
	# check if the new state is different from the current state.
	if state != current_state:
		return
	
	# find the new state in the dictionary
	var new_state = states.get(new_state_name.to_lower()) # to_lower is just error handling to make sure capitalization doesnt cause any problems
	# check that the new state exists
	if !new_state:
		return
	
	# if we have a current state, we must exit it before entering a new one
	if current_state:
		current_state.Exit()
	
	# Now, we can enter the new state
	new_state.Enter()
	
	# finally, set the new state to be the current state.
	current_state = new_state
