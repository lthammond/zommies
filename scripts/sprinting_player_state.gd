class_name SprintingPlayerState
extends PlayerMovementState

@export var SPEED : float = 8.5
@export var ACCELERATION : float = 11
@export var DECELERATION : float = 7 

func update(delta: float) -> void:
	if Input.is_action_just_released("action_sprint") or PLAYER.velocity.length() == 0:
		transition.emit("WalkingPlayerState")
	
	if Input.is_action_just_pressed("action_crouch") and PLAYER.velocity.length() > SPEED - 1:
		transition.emit("SlidingPlayerState")
		
	if Input.is_action_pressed("action_jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
func physics_update(delta: float) -> void:
	PLAYER.update_input()
	PLAYER.update_air(delta)
	PLAYER.update_ground(SPEED, ACCELERATION, DECELERATION, delta)
	PLAYER.headbob_effect(delta)
