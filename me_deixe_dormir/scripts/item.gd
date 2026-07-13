extends Sprite2D

@export_category("Item")
@export var label: String = "Item"

@onready var interaction_area: Area2D = $InteractionArea
@onready var key_e: AnimatedSprite2D = $Key_E

var player_in_range: CharacterBody2D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

	key_e.visible = false
	key_e.play("default")


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
	#chama balao de dialogo
	var dialog_ui = get_tree().root.get_node("Startup01/Dialog")
	if dialog_ui:
		dialog_ui.start_item_dialog(player_in_range, label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
