extends Area2D
class_name FrameItem

signal frame_collected(frame_node: Area2D)

@export var frame_order: int = 0
@export var breath_amplitude: float = 10.0
@export var breath_speed:float = 4.0
@export var story: String ="Lorem ipsum sei la texto aleatorio"

#conexoes dos frames
@export var left_color: Color = Color.TRANSPARENT
@export var right_color: Color = Color.TRANSPARENT

@onready var body = $Body
@onready var ballon = $Body/Ballon
@onready var story_ballon = $Body/Ballon/MarginContainer/Label
@onready var left_circle = $Body/LeftCircle
@onready var right_circle = $Body/RightCircle

var time_passed: float = 0.0     
var base_position: Vector2     
var original_position: Vector2

func _ready() -> void:
	if story_ballon != null:
		story_ballon.text = str(story)
		
	original_position = global_position
	
	# gera conexoes laterais
	left_circle.add_theme_stylebox_override("panel", create_circle_theme(left_color))
	right_circle.add_theme_stylebox_override("panel", create_circle_theme(right_color))

func _process(delta: float) -> void:
	time_passed += delta
	var offset_y = sin(time_passed * breath_speed) * breath_amplitude
	var offset_x = cos(time_passed * (breath_speed / 2.0)) * (breath_amplitude / 2.0)
	body.position = base_position + Vector2(offset_x, offset_y)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		frame_collected.emit(self)


func _on_mouse_entered() -> void:
	if ballon:
			ballon.show()
			# Cria uma animação suave (fade in) para o balão aparecer
			var tween = create_tween()
			tween.tween_property(ballon, "modulate:a", 1.0, 0.2)


func _on_mouse_exited() -> void:
	if ballon:
		# Cria uma animação suave (fade out) para o balão sumir
		var tween = create_tween()
		tween.tween_property(ballon, "modulate:a", 0.0, 0.2)
		tween.tween_callback(ballon.hide)


func create_circle_theme(base_color: Color) -> StyleBox:
	if base_color == Color.TRANSPARENT:
		return StyleBoxEmpty.new() # Esconde o círculo se não tiver cor
		
	var style = StyleBoxFlat.new()
	style.bg_color = base_color

	style.corner_radius_top_left = 200
	style.corner_radius_top_right = 200
	style.corner_radius_bottom_left = 200
	style.corner_radius_bottom_right = 200
	
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.border_color = Color(1.0, 1.0, 1.0, 0.75) 
	style.border_blend = true
		
	return style

func get_ui_representation() -> Control:
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(100, 100)
	
	slot.tooltip_text = story
	
	var rect = TextureRect.new()
	rect.texture = load("res://assets/textures/ui/frame.png")
	
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(rect)
	
	var ui_label = Label.new()
	ui_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_label.add_theme_color_override("font_color", Color.BLACK)
	rect.add_child(ui_label)
	
	if left_color != Color.TRANSPARENT and frame_order == 0:
		var p_left = Panel.new()
		p_left.custom_minimum_size = Vector2(16, 16)
		slot.add_child(p_left)
		p_left.set_anchors_preset(Control.PRESET_CENTER_LEFT)
		p_left.position.y -= 10
		p_left.add_theme_stylebox_override("panel", create_circle_theme(left_color))
		
	if right_color != Color.TRANSPARENT:
		var p_right = Panel.new()
		p_right.custom_minimum_size = Vector2(16, 16)
		slot.add_child(p_right)
		p_right.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		p_right.position.y -= 10
		p_right.add_theme_stylebox_override("panel", create_circle_theme(right_color))
		
	return slot
