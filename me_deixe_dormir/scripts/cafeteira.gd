class_name CoffeeMachine extends Sprite2D

@export var label: String = "Cafeteira"

@onready var interaction_area: Area2D = $InteractionArea
@onready var key_e: AnimatedSprite2D = $Key_E
@onready var machine_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

const TRES_MIN_DELAY = 180

var player_in_range: CharacterBody2D = null
var cups_left: int = 3
var refill_timer: float = 0.0

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	key_e.visible = false
	key_e.play("default")
	update_animation()

func _process(delta: float) -> void:
	if cups_left <= 0:
		refill_timer += delta
		if refill_timer >= TRES_MIN_DELAY:
			cups_left = 3
			refill_timer = 0.0
			label = "Cafeteira" 
			update_animation()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		player_in_range = body
		key_e.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		key_e.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range != null and event.is_action_pressed("interact"):
		dialog()

func dialog() -> void:
	var dialog_ui = get_tree().root.get_node_or_null("Startup01/Dialog")
	
	if dialog_ui:
		dialog_ui.start_item_dialog(player_in_range, label, self)

func usar_cafe() -> void:
	if cups_left > 0:
		cups_left -= 1
		machine_anim.play("get_coffee")
		
		audio.play()
		
		if cups_left <= 0:
			label = "CafeteiraVazia"

func update_animation() -> void:
	if cups_left > 0:
		machine_anim.play("full")
	else:
		machine_anim.play("empty")

func _on_animated_sprite_2d_animation_finished() -> void:
	if machine_anim.animation == "get_coffee":
		update_animation()
