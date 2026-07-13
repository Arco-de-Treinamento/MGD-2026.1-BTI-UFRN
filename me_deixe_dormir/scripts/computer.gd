class_name Computer extends Sprite2D

@export_category("Computer")
@export var label: String = "Computer"

@onready var interaction_area: Area2D = $InteractionArea
@onready var key_e: AnimatedSprite2D = $Key_E
@onready var atention: AnimatedSprite2D = $Atention

var player_in_range: CharacterBody2D = null

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	
	key_e.visible = false
	key_e.play("default")
	
	atention.visible = false
	atention.play("default")

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
		dialog_ui.start_item_dialog(player_in_range, label)

var blink_tween: Tween

func start_blinking() -> void:
	#pisca o computador
	if blink_tween:
		blink_tween.kill()

	blink_tween = create_tween().set_loops()
	atention.visible = true

func stop_blinking() -> void:
	if blink_tween:
		blink_tween.kill()
		blink_tween = null
	
	atention.visible = false
