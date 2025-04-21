class_name IdlePlayerState
extends PlayerMovementState

@export var SPEED : float = 5.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25 

func enter(previous_state) -> void:
	if ANIMATION_PLAYER.is_playing() and ANIMATION_PLAYER.current_animation == "JumpingEnd":
		await ANIMATION_PLAYER.animation_finished
	ANIMATION_PLAYER.pause()

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("action_crouch"):
		transition.emit("CrouchingPlayerState")
	
	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")
	
	if Input.is_action_just_pressed("action_jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
