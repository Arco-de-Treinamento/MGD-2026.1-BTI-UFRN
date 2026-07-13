class_name Actor extends CharacterBody2D

@export_category("Actor")
@export var label: String = "Null"
@export var job: String = "Estagiario"
@export var life: int = 10
@export var social_point: int = 10
@export var money: float = 0.0
@export var job_time: float = 0.0
@export var stamina: float = 0.0
@export var persuasion: float = 0.0
@export var sleep_delay: float = 5.0
var inventory: Array[String] = []

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var step_sound: AudioStreamPlayer2D = get_node_or_null("StepSound")

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var idle_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func update_animation(direction: float, delta: float) -> void:
	if not is_on_floor():
		idle_timer = 0.0
		anim_sprite.play("jump")
		
		if step_sound and step_sound.playing:
			step_sound.stop()

		return

	if direction != 0:
		idle_timer = 0.0
		anim_sprite.flip_h = direction < 0
		anim_sprite.play("walk")

		if step_sound and not step_sound.playing:
			step_sound.pitch_scale = randf_range(0.9, 1.1) #varia pitch
			step_sound.play()
			
	else:
		if step_sound and step_sound.playing:
			step_sound.stop()
			
		idle_timer += delta

		if idle_timer >= sleep_delay:
			if anim_sprite.animation != "to_sleep" and anim_sprite.animation != "sleep":
				anim_sprite.play("to_sleep")
			elif anim_sprite.animation == "to_sleep" and not anim_sprite.is_playing():
				anim_sprite.play("sleep")
		else:
			anim_sprite.play("idle")

func die() -> void:
	anim_sprite.play("die")
	set_physics_process(false)
func add_item(item_name: String) -> void:
	inventory.append(item_name)

#func remove_item(item_name: String) -> void:
	#if inventory.has(item_name):
		#inventory.erase(item_name)
#
#func has_item(item_name: String) -> bool:
	#return inventory.has(item_name)
	#
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
