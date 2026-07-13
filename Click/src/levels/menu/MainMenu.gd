extends Control

@onready var btn_start = $VBoxContainer/ButtonStart
@onready var btn_quit = $VBoxContainer/ButtonQuit

const MAIN_GAME = preload("res://src/levels/main/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN_GAME)

func _on_quit_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()
