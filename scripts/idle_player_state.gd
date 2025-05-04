class_name IdlePlayerState
extends PlayerMovementState

@export var SPEED : float = 7.0
@export var ACCELERATION : float = 11
@export var DECELERATION : float = 7 

func enter(previous_state) -> void:
	if ANIMATION_PLAYER.is_playing() and ANIMATION_PLAYER.current_animation == "JumpingEnd":
		await ANIMATION_PLAYER.animation_finished
	ANIMATION_PLAYER.pause()

func update(delta: float) -> void:
	if Input.is_action_just_pressed("action_crouch"):
		transition.emit("CrouchingPlayerState")
	
	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")
	
	if Input.is_action_pressed("action_jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
func physics_update(delta: float) -> void:
	PLAYER.update_input()
	PLAYER.update_air(delta)
	PLAYER.update_ground(SPEED, ACCELERATION, DECELERATION, delta)
