class_name Elevator extends Area2D

@export_category("Elevador")
@export var elevator_name: String = "Andar 1"
@export var dest_up: Elevator
@export var dest_down: Elevator

var player_trigger: CharacterBody2D = null
var selected_dest: Elevator = null

@onready var door_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var key_up: AnimatedSprite2D = $Key_Up
@onready var key_down: AnimatedSprite2D = $Key_Down
@onready var key_e: AnimatedSprite2D = $Key_E
@onready var dest_label: Label = $DestLabel

@onready var elevator_sft: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	key_up.visible = false
	key_down.visible = false
	key_e.visible = false
	dest_label.visible = false
	
	key_e.play("default")
	key_up.play("default")
	key_down.play("default")
	
	if door_anim.sprite_frames.has_animation("idle"):
		door_anim.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	if player_trigger:
		if event.is_action_pressed("ui_up") and dest_up != null:
			selected_dest = dest_up
			atualizar_interface()
			
		elif event.is_action_pressed("ui_down") and dest_down != null:
			selected_dest = dest_down
			atualizar_interface()
			
		elif event.is_action_pressed("interact") and selected_dest != null:
			teleport()

func atualizar_interface() -> void:
	if selected_dest != null:
		dest_label.text = selected_dest.elevator_name
		dest_label.visible = true
		key_e.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_trigger = body
		selected_dest = null
		
		if door_anim.sprite_frames.has_animation("open"):
			door_anim.play("open")
			elevator_sft.play()
		
		if dest_up != null:
			key_up.visible = true
		if dest_down != null:
			key_down.visible = true
			
		dest_label.visible = false
		key_e.visible = false

func _on_body_exited(body: Node2D) -> void:
	if body == player_trigger:
		player_trigger = null
		selected_dest = null
		
		if door_anim.sprite_frames.has_animation("close"):
			door_anim.play("close")
			elevator_sft.play()
		
		key_up.visible = false
		key_down.visible = false
		key_e.visible = false
		dest_label.visible = false

func teleport() -> void:
	if selected_dest:
		player_trigger.global_position = selected_dest.global_position
