extends Actor

signal task_update(new_task: String)

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

var cafe_qtd: int = 0
var drive_qtd: int = 0
var glpi_qtd: int = 0

var max_stamina: float = 100.0

var is_in_task: bool = false
#lista de tasks do jogador
var task_list: Array[String] = []
#task atual ativa para o npc
var active_task: Dictionary = {}

@onready var cafe_sfx: AudioStreamPlayer2D = $CafeSound

# movimentacao do player
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if anim_sprite.animation == "sleep":
		stamina = min(stamina + (1.0 * delta), max_stamina)
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(direction, delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		idle_timer = 0.0 # previne sono em dialogo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	job = "Estagiario"
	job_time = 8.0
	persuasion = 0.0
	stamina = max_stamina
	
	step_sound.volume_db = -8


func add_item(item_name: String) -> void:
	if item_name == "cafe":
		cafe_qtd += 1
	elif item_name == "drive":
		drive_qtd += 1
	elif item_name == "glpi":
		glpi_qtd += 1

func remove_item(item_name: String) -> void:
	if item_name == "cafe" and cafe_qtd > 0:
		cafe_qtd -= 1
	elif item_name == "drive" and drive_qtd > 0:
		drive_qtd -= 1
	elif item_name == "glpi" and glpi_qtd > 0:
		glpi_qtd -= 1

func has_item(item_name: String) -> bool:
	if item_name == "cafe":
		return cafe_qtd > 0
	elif item_name == "drive":
		return drive_qtd > 0
	elif item_name == "glpi":
		return glpi_qtd > 0
	return false

func add_persuasion(amount: float) -> void:
	persuasion += amount
	check_promotion()

func check_promotion() -> void:
	if job == "Estagiario" and persuasion >= 120:
		job = "Suporte"
		job_time = 6.0
		trigger_up_cargo()

	elif job == "Suporte" and persuasion >= 240:
		job = "Supervisor"
		job_time = 4.0
		trigger_up_cargo()

	elif job == "Supervisor" and persuasion >= 360:
		job = "Diretor"
		job_time = 2.0
		trigger_up_cargo()
		
	elif job == "Diretor" and persuasion >= 480:
		job = "Chefe"
		job_time = 0.0		
		trigger_end_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func trigger_up_cargo()-> void:
	var cargo_up = get_tree().root.get_node("Startup01/CargoScreen")
	var cargo_up_sound = get_tree().root.get_node("Startup01/Sounds/UpCargoSound")
	
	if cargo_up:
		cargo_up_sound.play()
		cargo_up.visible = true
		get_tree().paused = true
	

func   trigger_end_game() -> void:
	var end_screen = owner.get_node_or_null("EndDemoScreen")
	var hud = owner.get_node_or_null("Hud")
	var task_ui = owner.get_node_or_null("TaskUi")
	var dialog_ui = owner.get_node_or_null("Dialog")
	
	if hud: hud.hide()
	if task_ui: task_ui.hide()
	if dialog_ui: dialog_ui.hide()
	
	if end_screen:
		end_screen.visible = true
		get_tree().paused = true
		
		var win_sound = owner.get_node_or_null("Sounds/UpCargoSound")
		if win_sound: win_sound.play()

		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) 
		tween.tween_property(end_screen.get_node("ColorRect"), "modulate:a", 1.0, 2.0)

		
func start_new_task(task_data: Dictionary) -> void:
	#ativa a nova task para o player
	active_task = task_data

	task_update.emit(task_data["task"]) # joga a task para a UI

func finish_task() -> void:
	active_task = {}
	task_update.emit("") # limpa a UI de task
	
func beber_cafe() -> void:
	cafe_sfx.play()
	stamina = min(stamina + 30.0, max_stamina)
