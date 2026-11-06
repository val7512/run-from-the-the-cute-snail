extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collectedsound: AudioStreamPlayer2D = $collectedsound

var collected: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	if body.name == "Player" or body.name == "player":
		collected = true
		
		# 1. Force the audio to play on a global channel so queue_free() won't block it
		if collectedsound.stream:
			var temp_audio = AudioStreamPlayer.new()
			temp_audio.stream = collectedsound.stream
			temp_audio.volume_db = collectedsound.volume_db
			temp_audio.bus = collectedsound.bus
			get_tree().root.add_child(temp_audio)
			temp_audio.play()
			temp_audio.finished.connect(temp_audio.queue_free)
		
		# 2. Process your collection animations
		animated_sprite_2d.sprite_frames.set_animation_loop("collected", false)
		animated_sprite_2d.play("collected")
		
		# 3. Wait for the collection animation sequence to complete
		await animated_sprite_2d.animation_finished
		
		# 4. Instantly free the entire node to remove everything and reset explosions safely
		queue_free()
