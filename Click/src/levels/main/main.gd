extends Node2D

# itens
@export var frame_scene: PackedScene
@export var battery_scene: PackedScene

# elementos visuais
@export var frame_sprite: Texture2D
@export var img_gratification: Texture2D

# audio
@export var sfx_success: AudioStream
@export var sfx_error: AudioStream
@export var sfx_level_up: AudioStream
@export var sfx_flush: AudioStream
@export var sfx_tick: AudioStream

# elementos da tela
@onready var camera = $Camera2D
@onready var timer_label = $HUDLayer/TimerLabel
@onready var bottom_bar = $HUDLayer/BottomBar
@onready var timeline_node = $Timeline
@onready var remote = $HUDLayer/RemoteAnchor/Remote
@onready var timeline_label = $HUDLayer/TimelinesLabel

# controle
@export var current_max_time: float = 60.0
@export var total_frames_to_win: int = 10

# controle interno
var current_level: int = -1
var current_timeline:int = 0
var time_left: float
var next_expected_frame: int = 0
var target_camera_x: float = 0.0
var is_game_over: bool = false
var pause_menu: Control
var grat_rect: TextureRect

# inicializa audio
var audio_bgm = AudioStreamPlayer.new()
var audio_tick = AudioStreamPlayer.new()
var audio_sfx = AudioStreamPlayer.new()
var audio_flush = AudioStreamPlayer.new()

# controle de tic tac
var tick_timer: float = 0.0 
var is_tic: bool = true     

# gerador de historias 
var gerador = StoryGenerator.new()

# tela de historia
var current_correct_story: Array = []
var story_panel: ColorRect
var story_label: Label
var story_tween: Tween

# tela de tutorial
var tutorial_panel: ColorRect
var name_input: LineEdit
var tutorial_label: Label
var tutorial_button: Button
var tutorial_step: int = 0

func _ready() -> void:
	remote.button_clicked.connect(_on_remote_action)
	setup_dynamic_nodes()
	
	# Tela inicial de texto
	get_tree().paused = true
	tutorial_panel.show()
	name_input.grab_focus() 
	
	start_next_level()
	
func _process(delta: float) -> void:
	if is_game_over: return
	
	# acerta tempo na tela
	time_left -= delta
	timer_label.text = str(int(time_left)) + " seg"
	
	# backgroud som - tic tac
	var time_ratio = max(0.0, time_left / current_max_time)
	var tick_interval = lerp(0.15, 1.0, time_ratio) 
	tick_timer -= delta
	
	if tick_timer <= 0:
		tick_timer = tick_interval

		if is_tic: audio_tick.pitch_scale = 0.8
		else: audio_tick.pitch_scale = 1.3 # 
			
		audio_tick.play()
		is_tic = !is_tic
		
	if time_left <= 0:
		trigger_game_over() 

# inicializa elementos de telas gerados
func setup_dynamic_nodes() -> void:
	# inicializa audio
	add_child(audio_tick)
	add_child(audio_sfx)
	add_child(audio_flush)
	audio_tick.stream = sfx_tick
	
	story_panel = ColorRect.new()
	story_panel.color = Color(0, 0, 0, 0.75)
	story_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	story_panel.hide()
	$HUDLayer.add_child(story_panel)
	
	###########################################################################
	#                             Tela de historia           
	
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	story_panel.add_child(center_container)
	
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 40)
	margin_container.add_theme_constant_override("margin_right", 40)
	center_container.add_child(margin_container)
	
	var story_vbox = VBoxContainer.new()
	story_vbox.add_theme_constant_override("separation", 2)
	margin_container.add_child(story_vbox)
	
	story_panel.z_index = 10
	
	story_label = Label.new()
	story_label.custom_minimum_size = Vector2(600, 0) 
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_label.add_theme_font_size_override("font_size", 18)
	story_vbox.add_child(story_label)
	
	var btn_box = CenterContainer.new()
	story_vbox.add_child(btn_box)
	
	var skip_button = Button.new()
	skip_button.text = " CONTINUAR"
	skip_button.add_theme_font_size_override("font_size", 24)
	skip_button.pressed.connect(_on_skip_pressed)
	btn_box.add_child(skip_button)
	
	###########################################################################
	#                             Tela de Pause   
	
	pause_menu = ColorRect.new()
	pause_menu.color = Color(0, 0, 0, 0.8)
	pause_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_menu.hide()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS 
	$HUDLayer.add_child(pause_menu)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.add_theme_constant_override("separation", 20)
	pause_menu.add_child(vbox)
	
	var btn_continue = Button.new()
	btn_continue.text = "CONTINUAR"
	btn_continue.pressed.connect(toggle_pause)
	vbox.add_child(btn_continue)
	
	var btn_quit = Button.new()
	btn_quit.text = "SAIR PARA O MENU"
	btn_quit.pressed.connect(func(): get_tree().paused = false; get_tree().change_scene_to_file("res://src/levels/menu/MainMenu.tscn"))
	
	vbox.add_child(btn_quit)
	
	###########################################################################
	#                             Tela inicial 
	tutorial_panel = ColorRect.new()
	tutorial_panel.color = Color(0, 0, 0, 0.8) 
	tutorial_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_panel.z_index = 100 
	tutorial_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	tutorial_panel.hide()
	$HUDLayer.add_child(tutorial_panel)
	
	var tut_center = CenterContainer.new()
	tut_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_panel.add_child(tut_center)
	
	var tut_vbox = VBoxContainer.new()
	tut_vbox.add_theme_constant_override("separation", 30)
	tut_center.add_child(tut_vbox)
	
	tutorial_label = Label.new()
	tutorial_label.text = "Bem-Vindo à Click Ltda.\n\nPara iniciar a recuperação da história,\npor favor, insira o seu nome:"
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.add_theme_font_size_override("font_size", 18)
	tut_vbox.add_child(tutorial_label)
	
	name_input = LineEdit.new()
	name_input.placeholder_text = "Seu Nome..."
	name_input.custom_minimum_size = Vector2(400, 60)
	name_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_input.add_theme_font_size_override("font_size", 16)
	tut_vbox.add_child(name_input)
	
	tutorial_button = Button.new()
	tutorial_button.text = " CONFIRMAR"
	tutorial_button.custom_minimum_size = Vector2(0, 60)
	tutorial_button.add_theme_font_size_override("font_size", 16)
	tutorial_button.pressed.connect(_on_tutorial_btn_pressed)
	tut_vbox.add_child(tutorial_button)

# inicializa nova epoca
func start_next_level() -> void:
	current_level += 1
	is_game_over = false
	next_expected_frame = 0
	target_camera_x = 0.0
	camera.position.x = 0 
	
	# O tempo diminui progressivamente - minimo de 15
	current_max_time = max(15.0, 48.0 - ((current_level - 1) * 6.0))
	time_left = current_max_time
	
	for child in timeline_node.get_children(): child.queue_free()
	for child in bottom_bar.get_children(): child.queue_free()
	
	generate_timeline()

# gera nova epoca
func generate_timeline() -> void:
	var conteudo_gerado = gerador.generate_level_content(current_level, GameManager.player_name.to_upper(), 4)
	current_correct_story = conteudo_gerado.slice(0, 4) #add historia a historia total

	# atualiza cont da epoca 
	timeline_label.text = "Epoca: " + str(int(current_timeline))
	
	var positions_x = []
	for i in range(total_frames_to_win):
		positions_x.append(800 * (i + 1) + randf_range(-200, 200))
		
	positions_x.shuffle()
	
	#gera cores dos frames
	var palette = [Color.CYAN, Color.ORANGE, Color.LIME_GREEN, Color.MAGENTA, Color.YELLOW, Color.DEEP_SKY_BLUE, Color.CHOCOLATE, Color.DARK_SEA_GREEN, Color.DEEP_PINK]
	palette.shuffle()
	var c1 = palette[0]
	var c2 = palette[1]
	var c3 = palette[2]
	
	var wrong_colors = palette.slice(6)
	
	#  randomiza frames na tela
	for i in range(total_frames_to_win):
		var frame = frame_scene.instantiate()
		frame.frame_order = i
		frame.scale = Vector2(0.3, 0.3)
		frame.story = conteudo_gerado[i]
		
		# Define os encaixes
		# gera historia em 4 atos - Kishotenketsu

		if i == 0:   # KI
			frame.frame_order = 0
			frame.left_color = Color.TRANSPARENT
			frame.right_color = c1
			
			# inicia o primeiro frame já coletado
			add_frame_to_bottom_bar(frame)
			frame.queue_free() 
			next_expected_frame = 1 
			continue 
			
		elif i == 1: # SHO
			frame.frame_order = 1
			frame.left_color = c1; frame.right_color = c2
		elif i == 2: # TEN
			frame.frame_order = 2
			frame.left_color = c2; frame.right_color = c3
		elif i == 3: # KETSU
			frame.frame_order = 3
			frame.left_color = c3; frame.right_color = Color.TRANSPARENT
		else:        
			frame.frame_order = -1 
			frame.left_color = wrong_colors.pick_random()
			frame.right_color = wrong_colors.pick_random()
			
		# Associa a posição embaralhada a este frame
		frame.position = Vector2(positions_x[i], randf_range(-150, 150)) 
		frame.frame_collected.connect(_on_frame_collected)
		timeline_node.add_child(frame)
		
	# randomiza baterias na tela 
	for i in range(2):
		var bat = battery_scene.instantiate()
		bat.scale = Vector2(0.35, 0.35)
		bat.position = Vector2(randf_range(500, 2500), randf_range(-150, 150))
		timeline_node.add_child(bat)
		
	current_timeline +=1

# acoes do controle
func _on_remote_action(action_name: String) -> void:
	# Menu de Pausa
	if action_name == "menu" or action_name == "pause":
		toggle_pause()
		return
		
	if is_game_over or get_tree().paused: return
	
	var jump_distance = 600.0
	var slide_time = 0.4 
	
	audio_flush.stream = sfx_flush
	
	# navegacao na timeline
	match action_name:
		"chapt_fwd", "skip_next":
			if action_name == "chapt_fwd":
				target_camera_x += (jump_distance * 2)
			else:
				target_camera_x += jump_distance

			audio_flush.pitch_scale = 1.0
			audio_flush.play()
			
		"chapt_rev", "skip_prev":
			if action_name == "chapt_rev":
				target_camera_x -= (jump_distance * 2)
			else:
				target_camera_x -= jump_distance
			
			audio_flush.pitch_scale = 0.7 
			audio_flush.play()
			
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "position:x", target_camera_x, slide_time)

# funcao de pausar o game
func toggle_pause() -> void:
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused

# coleta de frames
func _on_frame_collected(frame_node: Area2D) -> void:
	if is_game_over: return
	
	# acerta o frame de acordo com a cor sinalizada
	if frame_node.frame_order == next_expected_frame:
		audio_sfx.stream = sfx_success
		audio_sfx.play()
		
		add_frame_to_bottom_bar(frame_node)
		frame_node.queue_free() 
		
		next_expected_frame += 1
	
		if next_expected_frame >= 4:
			trigger_level_complete() 
	else:
		audio_sfx.stream = sfx_error
		audio_sfx.play()
		
		var tween = create_tween()
		tween.tween_property(frame_node, "position:y", frame_node.original_position.y - 50, 0.1)
		tween.tween_property(frame_node, "position:y", frame_node.original_position.y, 0.2).set_trans(Tween.TRANS_BOUNCE)

# fim de timeline
func trigger_level_complete() -> void:
	is_game_over = true
	audio_sfx.stream = sfx_level_up
	audio_sfx.play()
	
	# Salva a historia globalmente
	GameManager.add_to_history(current_correct_story)
	
	var texto_completo = "HISTÓRIA RECUPERADA:\n\n"
	for frase in current_correct_story:
		texto_completo += frase + "\n\n"
	
	story_label.text = texto_completo
	story_panel.show()
	story_panel.modulate.a = 0.0 
	
	# animacao fade
	if story_tween and story_tween.is_valid():
		story_tween.kill()
		
	story_tween = create_tween()
	story_tween.tween_property(story_panel, "modulate:a", 1.0, 0.5)
	story_tween.tween_interval(10.0) 
	
	story_tween.tween_property(story_panel, "modulate:a", 0.0, 0.5)
	story_tween.tween_callback(_on_skip_pressed)

func _on_skip_pressed() -> void:
	if story_tween and story_tween.is_valid():
		story_tween.kill()
		
	story_panel.hide()
	start_next_level()
	
func trigger_game_over() -> void:
	is_game_over = true
	
	# seta para a cena de creditos
	if GameManager.recovered_stories.size() > 0:
		get_tree().change_scene_to_file("res://src/levels/credits/credits.tscn")
	else:
		get_tree().change_scene_to_file("res://src/levels/menu/MainMenu.tscn")

func add_frame_to_bottom_bar(frame_node: FrameItem) -> void:
	var frame_ui = frame_node.get_ui_representation()
	
	bottom_bar.add_child(frame_ui)
	
func _on_tutorial_btn_pressed() -> void:
	if tutorial_step == 0:
		var typed_name = name_input.text.strip_edges()
		if typed_name == "":
			typed_name = "Fulano"
			
		GameManager.player_name = typed_name
		
		name_input.hide()
		tutorial_button.text = " INICIAR RECUPERAÇÃO"
		
		tutorial_label.text = "OLÁ, " + GameManager.player_name.to_upper() + ".\n\n" + \
		"Usou tanto o controle que bagunçou sua linha do tempo? Agora é a sua chance de recuperar a sua existência.\n\n" + \
		"Use o controle para se mover no tempo.\n" + \
		"Clique nos frames cujas bordas se encaixam como um quebra-cabeça.\n\n"
		
		tutorial_step = 1
		
	elif tutorial_step == 1:
		tutorial_panel.hide()
		get_tree().paused = false 
		start_next_level() 
