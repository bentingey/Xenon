extends Node
class_name State

# I put this here to ignore a warning that was not helpful... there may be a better way to do this
@warning_ignore("UNUSED_SIGNAL")
signal Transitioned

func Enter():
	pass
	
func Exit():
	pass
	
func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
