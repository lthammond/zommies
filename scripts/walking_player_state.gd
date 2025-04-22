class_name WalkingPlayerState
extends PlayerMovementState

@export var SPEED : float = 7.0
@export var ACCELERATION : float = 11
@export var DECELERATION : float = 7 
@export var TOP_ANIM_SPEED : float = 2.2

func enter(previous_state) -> void:
	if ANIMATION_PLAYER.is_playing() and ANIMATION_PLAYER.current_animation == "JumpingEnd":
		await ANIMATION_PLAYER.animation_finished
	ANIMATION_PLAYER.play("Walking", -1.0, 1.0)
	
func exit() -> void:
	ANIMATION_PLAYER.speed_scale = 1.0

func update(delta):
	set_animation_speed(PLAYER.velocity.length())
	
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
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity(SPEED, ACCELERATION, DECELERATION, delta)
		
func set_animation_speed(spd):
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION_PLAYER.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
