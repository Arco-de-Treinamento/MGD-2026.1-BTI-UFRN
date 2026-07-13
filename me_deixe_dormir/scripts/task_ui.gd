extends CanvasLayer

@export var player: Actor
@onready var task: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/task

func _ready() -> void:
	#task.visible = false
	if player:
		player.task_update.connect(_on_new_task)

func _on_new_task(new_task: String) -> void:
	#task.visible = true # Mostra o painel
	task.text = new_task
