extends Control

@onready var vbox = $Control
@onready var story_label = $Control/Historia
@onready var titulo_label = $Control/Titulo
@onready var music_player = $AudioStreamPlayer

func _ready() -> void:
	music_player.play()
	titulo_label.text = "A História de " + GameManager.player_name
	
	var final_text = "\n\n\n"
	for story in GameManager.recovered_stories:
		final_text += story + "\n\n"

	final_text += "\n\nMesmo assim, sua história foi perdida. Click Ltda. não se responsabiliza por nenhuma vida ocasionalmente perdida durante a utilização de suas ferramentas. Linhas temporais e possíveis avarias na realidade são de responsabilidade única do usuário.\n\nA Click Ltda. agradece por sua escolha."

	story_label.text = final_text

	var screen_size = get_viewport_rect().size
	vbox.position.y = screen_size.y
	
	await get_tree().process_frame
	var scroll_distance = vbox.size.y + screen_size.y + 600
	var duration = scroll_distance / 100.0
	
	var tween = create_tween()
	tween.tween_property(vbox, "position:y", -vbox.size.y, duration)
	tween.finished.connect(_on_finished)

func _on_finished():
	var audio_tween = create_tween()
	audio_tween.tween_property(music_player, "volume_db", -80.0, 1.0)
	await audio_tween.finished
	
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://src/levels/menu/MainMenu.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_finished()
