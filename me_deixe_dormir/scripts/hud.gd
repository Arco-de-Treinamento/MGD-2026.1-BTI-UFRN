extends CanvasLayer

@export var player: Actor 

@onready var name_label: Label = $Cracha/NameLabel
@onready var persuasion_label: Label = $Cracha/Persuasion/PersuasionLabel

@onready var cafe_label: Label = $Bag/cafe_count
@onready var drive_label: Label = $Bag/drive_count
@onready var glpi_label: Label = $Bag/glpi_count

@onready var stamina_bar: ProgressBar = $Bars/Stamina

func _process(_delta: float) -> void:
	if player != null:
		atualizar_cracha()

func atualizar_cracha() -> void:
	name_label.text = player.label
	persuasion_label.text = str(player.persuasion)
	
	cafe_label.text = str(player.cafe_qtd)
	drive_label.text = str(player.drive_qtd)
	glpi_label.text	= str(player.glpi_qtd)
	
	stamina_bar.max_value = player.max_stamina
	stamina_bar.value = player.stamina
