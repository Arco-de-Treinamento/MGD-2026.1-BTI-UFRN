extends CanvasLayer

@onready var npc_text: Label = $Panel/NPCText
@onready var options_container: HBoxContainer = $Panel/OptionsContainer

# retorno de audio
@onready var hover_sound: AudioStreamPlayer = get_node_or_null("HoverSound")
@onready var mumble_sound: AudioStreamPlayer = get_node_or_null("MumbleSound")

var dialog_data: Dictionary
var item_dialog_data: Dictionary
var intro_dialog_data: Dictionary

var current_player: Actor
var current_npc: Node2D = null
var is_item_dialog: bool = false

var current_task_data: Dictionary = {}
var current_dialog_index: int = 0

# texttimer de letras
var text_timer: Timer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	#timer de texto do dialogo
	text_timer = Timer.new()
	text_timer.wait_time = 0.05 # Velocidade letras
	text_timer.timeout.connect(_on_text_timer_timeout)
	add_child(text_timer)

	load_dialog_data()

func load_dialog_data() -> void:
	var file = FileAccess.open("res://dialogs/tasks.json", FileAccess.READ)
	if file: dialog_data = JSON.parse_string(file.get_as_text())

	var file_itens = FileAccess.open("res://dialogs/itens.json", FileAccess.READ)
	if file_itens: item_dialog_data = JSON.parse_string(file_itens.get_as_text())

	var file_intro = FileAccess.open("res://dialogs/intro.json", FileAccess.READ)
	if file_intro: intro_dialog_data = JSON.parse_string(file_intro.get_as_text())

func open_dialog() -> void:
	visible = true
	get_tree().paused = true

func close_dialog() -> void:
	visible = false
	get_tree().paused = false
	text_timer.stop()

# Escolhe tipo de dialogo
func display_text(new_text: String) -> void:
	npc_text.text = new_text

	if not is_item_dialog:
		npc_text.visible_characters = 0
		text_timer.start()
	else:
		npc_text.visible_characters = -1
		text_timer.stop()

func _on_text_timer_timeout() -> void:
	if npc_text.visible_characters < npc_text.get_total_character_count():
		npc_text.visible_characters += 1

		# som de fala
		if mumble_sound:
			mumble_sound.pitch_scale = randf_range(0.5, 0.9)
			mumble_sound.play()
	else:
		text_timer.stop()

func create_options(options: Array) -> void:
	for child in options_container.get_children():
		child.queue_free()

	var first_btn: Button = null

	for opt in options:
		if opt["action"] == "deliver_item" and not current_player.has_item(opt["item"]):
			continue

		var btn = Button.new()
		btn.text = opt["text"]

		# acao com som
		btn.pressed.connect(_on_option_selected.bind(opt))
		#btn.focus_entered.connect(_on_btn_focus)

		options_container.add_child(btn)

		if first_btn == null:
			first_btn = btn

	# select primeiro botao
	if first_btn != null:
		first_btn.call_deferred("grab_focus")

func _on_btn_focus() -> void:
	if hover_sound:
		hover_sound.play()

func _on_option_selected(opt: Dictionary) -> void:
	hover_sound.play()
	process_action(opt)

func start_dialog(player_ref: Actor, npc_ref: Node2D = null) -> void:
	current_player = player_ref
	current_npc = npc_ref
	is_item_dialog = false
	open_dialog()
	
	

	if not current_player.active_task.is_empty():
		current_task_data = current_player.active_task
		var task_item = current_task_data.get("item", "")

		var id_npc_task = current_task_data.get("npc_id", -1)
		
		if current_npc and current_npc.get_instance_id() == id_npc_task:
			display_text("Opa, deu certo?")

			if current_player.has_item(task_item):
				create_options([ {"text": "Ehh, sim. Já finalizei", "action": "deliver_item", "item": task_item}])
				current_player.is_in_task = false
			else:
				create_options([ {"text": "Ehh.. ainda não...", "action": "close"}])
			return
			
		else:
			display_text("Tudo tranquilo...")
			create_options([ {"text": "Sair", "action": "close"}])

	var cargo_atual = current_player.job.to_lower()
	var all_tasks: Array = dialog_data.get("tasks", [])
	var valid_tasks: Array = []

	for task in all_tasks:
		var allowed_roles: Array = task.get("work", [])
		if allowed_roles.has(cargo_atual):
			valid_tasks.append(task)

	var morcegar = randi_range(1, 3)

	#if not valid_tasks.is_empty() and morcegar != 1 and not current_player.is_in_task:
	if not valid_tasks.is_empty() and morcegar != 1 :
		var random_index = randi() % valid_tasks.size()
		current_task_data = valid_tasks[random_index]
		current_dialog_index = 0
		current_player.is_in_task = true
		show_current_dialog_scene()
	else:
		display_text("Tudo tranquilo...")
		create_options([ {"text": "Sair", "action": "close"}])

func show_current_dialog_scene() -> void:
	var dialog_scenes: Array = current_task_data.get("dialog", [])

	if current_dialog_index >= 0 and current_dialog_index < dialog_scenes.size():
		var current_scene = dialog_scenes[current_dialog_index]
		var custo_stamina = current_task_data.get("stamina", 0)

		if current_dialog_index == 0 and current_player.stamina < custo_stamina:
			display_text(current_scene.get("text", ""))
			current_player.is_in_task = false
			create_options([ {"text": "Ehh... estou muito cansado para isso", "action": "close"}])
		else:
			display_text(current_scene.get("text", ""))
			create_options(current_scene.get("options", []))
	else:
		close_dialog()

func process_action(opt: Dictionary) -> void:
	var action = opt["action"]

	if action == "next_text":
		current_dialog_index += 1
		show_current_dialog_scene()
		return

	elif action == "last_text":
		var dialog_scenes: Array = current_task_data.get("dialog", [])
		if not dialog_scenes.is_empty():
			current_dialog_index = dialog_scenes.size() - 1
		show_current_dialog_scene()
		return

	elif action == "get_issue":
		current_player.start_new_task(current_task_data)
		
		if current_npc: current_player.active_task["npc_id"] = current_npc.get_instance_id()
		if current_task_data.has("stamina"): current_player.stamina -= current_task_data["stamina"]

		if current_task_data.has("item"):
			if current_task_data["item"] == "glpi": current_player.add_item("glpi")
			elif current_task_data["item"] == "drive": current_player.add_item("drive")

			if current_task_data["item"] in ["glpi", "drive"]:
				if current_npc and current_npc.has_method("start_blink_pc"):
					current_npc.start_blink_pc()
		close_dialog()
		return

	elif action == "get_item":
		current_player.add_item(opt["item"])
		if opt["item"] == "cafe" and current_npc and current_npc.has_method("usar_cafe"):
			current_npc.usar_cafe()
		close_dialog()
		return

	elif action == "drink_coffee":
		if current_player.has_method("beber_cafe"): current_player.beber_cafe()
		if current_npc and current_npc.has_method("usar_cafe"): current_npc.usar_cafe()
		close_dialog()
		return

	elif action == "deliver_item":
		if is_item_dialog:
			display_text("Aguarde... \n Retorne ao usuário |")
			create_options([ {"text": "Deslogar", "action": "close"}])
			return
		else:
			current_player.remove_item(opt["item"])
			var points = current_task_data.get("points", opt.get("points", 10))
			current_player.add_persuasion(points)
			current_player.finish_task()

			if current_npc and current_npc.has_method("stop_blink_pc"):
				current_npc.stop_blink_pc()

			display_text("Valeu!")
			create_options([ {"text": "Ahh... Queria um descanso", "action": "close"}])
			return

	elif action == "close":
		close_dialog()
		return

	else:
		close_dialog()
		return

# dialogo de inicio do jogo
func start_intro_dialog(dialog_select: String) -> void:
	is_item_dialog = false
	open_dialog()
	display_text(intro_dialog_data[dialog_select]["text"])
	create_options(intro_dialog_data[dialog_select]["options"])

func start_item_dialog(player_ref: Actor, item_name: String, npc_ref: Node2D = null) -> void:
	current_player = player_ref
	current_npc = npc_ref
	is_item_dialog = true
	open_dialog()

	if item_dialog_data.has(item_name):
		var current_item = item_dialog_data[item_name]
		display_text(current_item["text"])
		create_options(current_item["options"])

	else:
		display_text("!#%&@_!...")
		create_options([ {"text": "Entendi", "action": "close"}])
		
		
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	#interect ==> tecla E	
	if event.is_action_pressed("interact"):
		var focused_node = get_viewport().gui_get_focus_owner()
		
		if focused_node is Button and focused_node.get_parent() == options_container:
			focused_node.pressed.emit()
			get_viewport().set_input_as_handled()
