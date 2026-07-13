extends Area2D
class_name BatteryPack

@onready var body = $Body

@export var min_charge: int = 16
@export var max_charge: int = 24
var charge_amount: int

# movimentacao
@export var frame_order: int = 0
@export var breath_amplitude: float = 10.0
@export var breath_speed:float = 4.0

var time_passed: float = 0.0     
var base_position: Vector2     

# controle
var is_dragging: bool = false
var original_position: Vector2

func _ready() -> void:
	charge_amount = randi_range(min_charge, max_charge) # valor aleatorio da pilha
	original_position = global_position # Salva onde a pilha nasceu

func _process(delta: float) -> void:
	# segue o mouse
	if is_dragging:
		global_position = get_global_mouse_position()
	
	else:
		time_passed += delta
		var offset_y = sin(time_passed * breath_speed) * breath_amplitude
		var offset_x = cos(time_passed * (breath_speed / 2.0)) * (breath_amplitude / 2.0)
		body.position = base_position + Vector2(offset_x, offset_y)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			
			# Pega a camada da tela (HUDLayer)
			var hud = get_tree().current_scene.get_node("HUDLayer")
			# Se a pilha não estiver na HUD, muda ela de lugar (reparent)
			if hud and get_parent() != hud:
				reparent(hud)

# detecta quando solta o mouse 
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false
			attempt_drop()


func attempt_drop() -> void:
	#pega a altura da caixa da pilha
	var drop_zones = get_tree().get_nodes_in_group("battery_drop")

	if drop_zones.size() > 0:
		var drop_area = drop_zones[0]
		var remote = drop_area.owner 
		
		var mouse_screen_pos = get_viewport().get_mouse_position()
		var drop_shape = drop_area.get_node("CollisionShape2D")
		var target_pos = drop_shape.global_position
		
		if mouse_screen_pos.distance_to(target_pos) < 150.0:
			if remote.is_facing_back:
				remote.receive_battery(charge_amount)
				queue_free() 
				return
	
	# Volta pro lugar original se errar
	global_position = original_position
