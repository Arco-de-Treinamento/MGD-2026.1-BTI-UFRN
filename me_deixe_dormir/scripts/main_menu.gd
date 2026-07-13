extends Control

@onready var start_button: Button = $Start
@onready var exit_button: Button = $Exit
@onready var sound_button: AudioStreamPlayer = $HoverSound

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	sound_button.play()
	get_tree().change_scene_to_file("res://scenes/levels/Startup01.tscn")

func _on_exit_pressed() -> void:
	sound_button.play()
	get_tree().quit()
