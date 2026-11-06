extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -850.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jumpsound: AudioStreamPlayer2D = $jumpsound
@onready var deathsound: AudioStreamPlayer2D = $deathsound

var is_dead: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity (keeps running so the player falls to the floor when dead)
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Stop player controls and other animations if dead
	if is_dead:
		velocity.x = 0
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumpsound.play()

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animation logic
	if not is_on_floor():
		animated_sprite_2d.play("jumping")
	else:
		if direction != 0:
			animated_sprite_2d.play("running")
		else:
			animated_sprite_2d.play("idle")

	# Flip the sprite left/right based on movement direction
	if direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)

	move_and_slide()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	deathsound.play()
	animated_sprite_2d.sprite_frames.set_animation_loop("dying", false)
	animated_sprite_2d.play("dying")
	await animated_sprite_2d.animation_finished
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
