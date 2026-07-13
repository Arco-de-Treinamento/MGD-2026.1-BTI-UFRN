class_name Enimie extends Actor

@export_category("Enimie")
@export var patrol_points: Array[Node2D]
@export var wait_time: float = 2.0
@export var patrol_speed: float = 50.0

var current_point_index: int = 0
var is_waiting: bool = false
var player_in_range: CharacterBody2D = null
var current_wait_time: float = 0.0

@onready var interaction_area: Area2D = $InteractionArea
@onready var key_e: AnimatedSprite2D = $Key_E


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

	key_e.visible = false
	key_e.play("default")


func _physics_process(delta: float) -> void:
	if player_in_range != null or patrol_points.is_empty():
		velocity.x = 0
		update_animation(0, delta)

	elif is_waiting: # conta tempo de falta
		velocity.x = 0
		update_animation(0, delta)
		current_wait_time += delta

		if current_wait_time >= wait_time:
			is_waiting = false
			current_wait_time = 0.0

			current_point_index = (current_point_index + 1) % patrol_points.size()
	else:
		patrol(delta)

	super._physics_process(delta)

func patrol(delta: float) -> void:
	var target = patrol_points[current_point_index]

	var dir_x = sign(target.global_position.x - global_position.x)
	velocity.x = dir_x * patrol_speed

	update_animation(dir_x, delta)

	if abs(global_position.x - target.global_position.x) < 5.0:
		is_waiting = true
		current_wait_time = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		player_in_range = body

		idle_timer = 0.0 # previne sono

		key_e.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		key_e.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range != null and event.is_action_pressed("interact"):
		idle_timer = 0.0 # previne sono

		dialog()

func dialog() -> void:
	#chama balao de dialogo
	var dialog_ui = get_tree().root.get_node("Startup01/Dialog")
	if dialog_ui:
		dialog_ui.start_dialog(player_in_range)
