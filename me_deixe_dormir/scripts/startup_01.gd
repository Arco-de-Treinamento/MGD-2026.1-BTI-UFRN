extends Node2D

@onready var exit_button: Button = $EndDemoScreen/ColorRect/VBoxContainer/Exit
@onready var continue_button: Button = $CargoScreen/ColorRect/VBoxContainer/continue
@onready var cargo_screen: CanvasLayer = $CargoScreen
@onready var buttonSound: AudioStreamPlayer = $Sounds/HoverButtonSound

var dialog_move: bool = true
var time_accumulator: float = 0.0

func _ready() -> void:
	exit_button.pressed.connect(_on_exit_pressed)
	continue_button.pressed.connect(_on_continue_cargo_pressed)
		
	dialog("Intro")

func _process(delta: float) -> void:
	if dialog_move:
		time_accumulator += delta

		if time_accumulator >= 1.0:
			dialog("Move")
			dialog_move = false
			time_accumulator = 0.0

func _on_exit_pressed() -> void:
	if buttonSound:
		buttonSound.process_mode = Node.PROCESS_MODE_ALWAYS
		buttonSound.play()
		await buttonSound.finished 
		
	get_tree().quit()

func _on_continue_cargo_pressed() -> void:
	buttonSound.play()
	cargo_screen.visible = false
	
	get_tree().paused = false
	
func dialog(select_dialog: String) -> void:
	var dialog_ui = get_tree().root.get_node("Startup01/Dialog")
	if dialog_ui:
		dialog_ui.start_intro_dialog(select_dialog)

func _on_continue_pressed() -> void:
	_on_continue_cargo_pressed()
