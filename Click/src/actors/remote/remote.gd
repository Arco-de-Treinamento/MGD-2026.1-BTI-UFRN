extends Node2D
class_name Remote

# sinal do botao
signal button_clicked(action_name: String)

# corpo do controle
@onready var body = $Body
@onready var screen_icon = $Body/Screen
@onready var screen_background = $Body/ScreenBackground

# botoes
@onready var keyboard = $Body/Keyboard
@onready var btn_chapt_fwd = $Body/Keyboard/Chapt_FWD
@onready var btn_chapt_rev = $Body/Keyboard/Chapt_REV
@onready var btn_skip_next = $Body/Keyboard/Skip_Next
@onready var btn_skip_prev = $Body/Keyboard/Skip_Prev
@onready var btn_menu = $Body/Keyboard/Menu
@onready var btn_play = $Body/Keyboard/Play
@onready var btn_pause = $Body/Keyboard/Pause
@onready var btn_slow = $Body/Keyboard/Slow
@onready var btn_mute = $Body/Keyboard/Mute

# audio
@onready var click_sound = $ClickSound

# var de controle
@export var floating_text_scene: PackedScene
@export var breath_amplitude: float = 5.0
@export var breath_speed:float = 2.0
@export var remote_front_tex: Texture2D
@export var remote_back_tex: Texture2D

# icones da tela 
@export var icon_chapt_fwd: Texture2D
@export var icon_chapt_rev: Texture2D
@export var icon_skip_next: Texture2D
@export var icon_skip_prev: Texture2D
@export var icon_menu: Texture2D
@export var icon_play: Texture2D
@export var icon_pause: Texture2D
@export var icon_slow: Texture2D
@export var icon_mute: Texture2D
@export var error_battery: Texture2D

# bateria
@onready var battery_indicator = $Body/BatteryIndicator
@onready var drop_battery_area = $Body/DropBattery
@export var max_battery_capacity: int = 40
@export var bat_sprite_0: Texture2D
@export var bat_sprite_1: Texture2D
@export var bat_sprite_2: Texture2D
@export var bat_sprite_3: Texture2D
@export var bat_sprite_4: Texture2D

var time_passed: float = 0.0      # controle da tela
var base_position: Vector2        # pos controle 
var hide_timer: Timer             # controle da tela
var current_battery: int = 20     # nivel da bateria
var is_facing_back: bool = false  # controle de visao front/back

func _ready() -> void:
	base_position = body.position
	screen_icon.hide()
	
	# inicializa os botoes
	setup_button(btn_chapt_fwd, icon_chapt_fwd, "chapt_fwd")
	setup_button(btn_chapt_rev, icon_chapt_rev, "chapt_rev")
	setup_button(btn_skip_next, icon_skip_next, "skip_next")
	setup_button(btn_skip_prev, icon_skip_prev, "skip_prev")
	setup_button(btn_menu, icon_menu, "menu")
	#setup_button(btn_play, icon_play, "play")
	setup_button(btn_pause, icon_pause, "pause")
	#setup_button(btn_slow, icon_slow, "slow")
	#setup_button(btn_mute, icon_mute, "mute")
	
	# timer do display
	hide_timer = Timer.new()
	hide_timer.wait_time = 1.0 # 2 seg
	hide_timer.one_shot = true
	
	hide_timer.timeout.connect(_on_hide_timer_timeout)
	add_child(hide_timer)
	
	# atualiza a bateria
	update_battery_display()

func _process(delta: float) -> void:
	# animacao controle
	time_passed += delta
	var offset_y = sin(time_passed * breath_speed) * breath_amplitude
	var offset_x = cos(time_passed * (breath_speed / 2.0)) * (breath_amplitude / 2.0)
	body.position = base_position + Vector2(offset_x, offset_y)

func setup_button(button: TextureButton, icon: Texture2D, action_name: String) -> void:
	button.focus_mode = Control.FOCUS_NONE #bug do spaco
	button.set_meta("lit_texture", button.texture_pressed)
	
	if button.texture_normal != null:
		var image = button.texture_normal.get_image()
		#cria mascara para reduzir bug de input
		if image != null:
			image.convert(Image.FORMAT_RGBA8)
			
			var click_mask = BitMap.new()
			click_mask.create_from_image_alpha(image, 0.5)
	
			button.texture_click_mask = click_mask
	
	button.button_down.connect(_on_button_down.bind(icon, action_name))
	button.button_up.connect(_on_button_up)

func _on_button_down(icon: Texture2D, action_name: String) -> void:
	# botao de costas
	if is_facing_back:
		return
	
	#varia o tom do audio
	click_sound.pitch_scale = randf_range(0.8, 1.15)
	click_sound.play()
		
	# troca a textura do icone
	hide_timer.stop()
	
	if action_name != "menu":
		if current_battery <= 0:
			screen_icon.texture = error_battery
			screen_icon.show()
			return 
			
		current_battery -= 1
		update_battery_display()
	
	screen_icon.texture = icon 
	screen_icon.show()
	
	spawn_effect()
	button_clicked.emit(action_name)

func _on_button_up() -> void:
	hide_timer.start()

# timer pra liberar a tela
func _on_hide_timer_timeout() -> void:
	screen_icon.hide()

func spawn_effect() -> void:
	if not floating_text_scene:
		return
		
	var effect = floating_text_scene.instantiate()
	effect.position = body.global_position 
	get_tree().current_scene.add_child(effect)

# Troca o lado do controle
func toggle_remote_side() -> void:
	is_facing_back = !is_facing_back
	
	if is_facing_back:
		body.texture = remote_back_tex
		# Esconde a UI da frente
		screen_icon.hide()
		screen_background.hide()
		battery_indicator.hide()
		keyboard.hide()
	else:
		body.texture = remote_front_tex
		# Mostra a UI da frente
		screen_background.show()
		battery_indicator.show()
		keyboard.show()

func update_battery_display() -> void:
	if max_battery_capacity <= 0: return
	
	# Calcula a proporcao da bateria
	var ratio: float = float(current_battery) / float(max_battery_capacity)
	var level: int = clampi(int(ratio * 4.0), 0, 4)
	
	match level:
		0: battery_indicator.texture = bat_sprite_0
		1: battery_indicator.texture = bat_sprite_1
		2: battery_indicator.texture = bat_sprite_2
		3: battery_indicator.texture = bat_sprite_3
		4: battery_indicator.texture = bat_sprite_4

	# verifica se tem bateria
	var has_power: bool = current_battery > 0
		
	var power_buttons = [
		btn_chapt_fwd, btn_chapt_rev, btn_skip_next, btn_skip_prev,
		btn_play, btn_pause, btn_slow, btn_mute
	]
	
	for btn in power_buttons:
		if not btn.has_meta("lit_texture"):
			btn.set_meta("lit_texture", btn.texture_pressed)
			
		if has_power:
			# Com energia - > textura laranga
			btn.texture_pressed = btn.get_meta("lit_texture")
		else:
			# Sem energia -> textura padrao
			btn.texture_pressed = btn.texture_normal
				
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		toggle_remote_side()

func receive_battery(new_charge: int) -> void:
	# verifica o lado do contrle
	if not is_facing_back:
		return
		
	current_battery = clampi(current_battery + new_charge, 0, max_battery_capacity)
	update_battery_display()
	
	toggle_remote_side()
