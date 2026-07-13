class_name Employee extends Actor

@export_category("Employee")
@export var texture: Texture2D
@export var patrol_speed: float = 40.0
@export var meu_pc: Computer 

var direction_x: float = 1.0
var is_waiting: bool = false
var player_in_range: CharacterBody2D = null
var wait_timer: float = 0.0
var current_wait_duration: float = 0.0

@onready var interaction_area: Area2D = $InteractionArea
@onready var key_e: AnimatedSprite2D = $Key_E
@onready var cargo_label: Label = $CargoLabel

func _ready() -> void:
	#diminui audio do passo
	step_sound.volume_db = -10

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

	key_e.visible = false
	key_e.play("default")

	# Inicializa a Label de cargo
	cargo_label.visible = false
	cargo_label.text = job
	
	current_wait_duration = randf_range(1.0, 3.0)
	
	# SE VOCÊ COLOCOU UMA TEXTURA NO INSPECTOR, ELE RODA A MÁGICA:
	if texture != null:
		# 1. Duplica os frames para este NPC ser único (não afetar os outros)
		var new_frames = anim_sprite.sprite_frames.duplicate(true)
		
		# 2. Percorre as animações e troca o fundo delas para a sua nova textura
		for anim_name in new_frames.get_animation_names():
			for i in range(new_frames.get_frame_count(anim_name)):
				var old_frame = new_frames.get_frame_texture(anim_name, i) as AtlasTexture
				if old_frame:
					var new_frame = old_frame.duplicate() 
					new_frame.atlas = texture         
					new_frames.set_frame(anim_name, i, new_frame, new_frames.get_frame_duration(anim_name, i))
		
		# 3. Aplica os frames modificados ao boneco
		anim_sprite.sprite_frames = new_frames

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if player_in_range != null:
		velocity.x = 0
		update_animation(0, delta)
	elif is_waiting:
		velocity.x = 0
		update_animation(0, delta)

		wait_timer += delta
		
		if wait_timer >= current_wait_duration:
			is_waiting = false
			wait_timer = 0.0
		
			# Inverte a direcao
			direction_x *= -1
	else:
		velocity.x = direction_x * patrol_speed
		update_animation(direction_x, delta)
		
		#colisao
		if is_on_wall():
			is_waiting = true
			current_wait_duration = randf_range(1.0, 3.0)

	move_and_slide()

# Label do cargo
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		player_in_range = body
		idle_timer = 0.0
		key_e.visible = true
		cargo_label.visible = true

# Icon tecla E
func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		key_e.visible = false
		cargo_label.visible = false 
		
func _unhandled_input(event: InputEvent) -> void:
	if player_in_range != null and event.is_action_pressed("interact"):
		idle_timer = 0.0
		dialog()

func dialog() -> void:
	var dialog_ui = get_tree().root.get_node_or_null("Startup01/Dialog")
	if dialog_ui:
		dialog_ui.start_dialog(player_in_range, self)


func start_blink_pc() -> void:
	if meu_pc != null:
		meu_pc.start_blinking()

func stop_blink_pc() -> void:
	if meu_pc != null:
		meu_pc.stop_blinking()
