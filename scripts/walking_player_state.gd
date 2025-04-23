class_name WalkingPlayerState
extends PlayerMovementState

@export var SPEED : float = 7.0
@export var ACCELERATION : float = 11
@export var DECELERATION : float = 7 

func update(delta: float) -> void:
	if Input.is_action_pressed("action_sprint"):
		transition.emit("SprintingPlayerState")
		
	if Input.is_action_just_pressed("action_crouch"):
		transition.emit("CrouchingPlayerState")
		
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
		
	if Input.is_action_pressed("action_jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
func physics_update(delta: float) -> void:
	PLAYER.update_input()
	PLAYER.update_air(delta)
	PLAYER.update_ground(SPEED, ACCELERATION, DECELERATION, delta)
	PLAYER.headbob_effect(delta)
