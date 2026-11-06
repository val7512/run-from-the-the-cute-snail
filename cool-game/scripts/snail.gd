extends Area2D

const SPEED = 100.0
var direction = -1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x += direction * SPEED * delta

func _on_timer_timeout() -> void:
	direction *= -1
	
	if direction == 1.0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "player":
		if body.has_method("die"):
			body.die()
