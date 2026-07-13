extends Node
class_name StoryGenerator

# dicionarios
var objetos: Array = []
var epocas: Array = []
var adjetivos_positivos: Array = []
var adjetivos_gerais: Array = []
var intensidades: Array = []
var substantivos: Array = []
var verbos_pret_perf: Array = []
var verbos_futuro_do_pret: Array = []
var verbos_negativos: Array = []
var verbos_infinitivos: Array = []
var verbos_gerundio: Array = []
var pessoas_arq: Array = []
var lugares: Array = []

func _init() -> void:
	# inicializa dicionarios
	objetos = _load_json_file("res://data/objetos.json")
	epocas = _load_json_file("res://data/epocas.json")
	adjetivos_positivos = _load_json_file("res://data/adjetivos_positivos.json")
	adjetivos_gerais = _load_json_file("res://data/adjetivos_gerais.json")
	intensidades = _load_json_file("res://data/intensidades.json")
	substantivos = _load_json_file("res://data/substantivos.json")
	verbos_pret_perf = _load_json_file("res://data/verbos_pret_perf.json")
	verbos_futuro_do_pret = _load_json_file("res://data/verbos_futuro_do_pret.json")
	verbos_negativos = _load_json_file("res://data/verbos_negativos.json")
	verbos_infinitivos = _load_json_file("res://data/verbos_infinitivos.json")
	verbos_gerundio = _load_json_file("res://data/verbos_gerundio.json")
	pessoas_arq = _load_json_file("res://data/pessoas_arq.json")
	lugares = _load_json_file("res://data/lugares.json")

func _load_json_file(file_path: String) -> Array:
	if not FileAccess.file_exists(file_path):
		push_error("ERRO: Arquivo nao encontrado -> " + file_path)
		return []
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var parsed_data = JSON.parse_string(content)
	
	if parsed_data == null:
		push_error("ERRO: O arquivo " + file_path + " tem um erro de sintaxe JSON.")
		return []
		
	return parsed_data

# gera a historia
func generate_level_content(level: int, player_name: String, num_wrong_frames: int) -> Array:
	var correct_story: Array[String] = []
	
	if level == 0:
		correct_story = _generate_tutorial(player_name)
	else:
		var format_choice = randi_range(1, 3)
		match format_choice:
			1: correct_story = _generate_tragic(player_name)
			2: correct_story = _generate_slice_of_life(player_name)
			3: correct_story = _generate_mega_sena(player_name)
			
	var wrong_frames: Array[String] = _generate_wrong_frames(num_wrong_frames, player_name)
	
	var frames = []
	frames.append_array(correct_story)
	frames.append_array(wrong_frames)
	
	return frames

# Tutorial primeira parte
func _generate_tutorial(jogador: String) -> Array[String]:
	var _clima = [
	  "ensolarado",
	  "nublado",
	  "chuvoso",
	  "tempestuoso",
	  "nevoeiro",
	  "neve",
	  "ventoso",
	  "parcialmente nublado",
	  "granizo",
	  "geada"
	]
	
	var _fase_vida = ["infância", "juventude", "adolescência"]
	var _lugar = lugares.pick_random()
	var _objeto = objetos.pick_random()
	
	var ctx = {
		"jogador": jogador,
		"cidade": _lugar.nome,
		"cidade_art": _lugar.art_um,
		"clima": _clima.pick_random(),
		"fase_vida": _fase_vida.pick_random(),
		"adjetivo": adjetivos_positivos.pick_random(),
		"objeto": _objeto.nome,
		"objeto_pron": _objeto.pronome,
		"objeto_art": _objeto.artigo 
	}
	
	var ki = "{jogador} nasceu em {cidade_art} {cidade} num dia {clima}.".format(ctx)
	var sho = "A sua {fase_vida} foi muito {adjetivo}.".format(ctx)
	var ten = "{objeto_art} {objeto_pron} {objeto} também era {adjetivo}.".format(ctx)
	var ketsu = "Mesmo com uma {fase_vida} {adjetivo}, ele comprou um controlo Click e...".format(ctx)
	
	return [ki, sho, ten, ketsu]

# historia tragica
func _generate_tragic(jogador: String) -> Array[String]:
	var obj = objetos.pick_random()
	var subs = substantivos.pick_random()
	var intens = intensidades.pick_random()
	var verbo_perf = verbos_pret_perf.pick_random()
	var verbo_imperf = verbos_futuro_do_pret.pick_random()
	var verbo_neg = verbos_negativos.pick_random()
	var verbo_inf = verbos_infinitivos.pick_random()
	
	var obj_gen = "m" if obj.art_um == "um" else "f"
	var adj_raw = adjetivos_gerais.pick_random()
	var adjetivo_correto = adj_raw[obj_gen] if typeof(adj_raw) == TYPE_DICTIONARY else adj_raw
	
	# Concordancia verbais
	var intensidade_subs = intens["m"] if subs.genero == "m" else intens["f"]
	var intensidade_forma = intens["f"]
	var subst_art_def = "o" if subs.genero == "m" else "a"
	
	var ctx = {
		"jogador": jogador,
		"verbo_perf": verbo_perf,
		"prep_obj": obj.prep_do,
		"objeto": obj.nome,
		"pronome_obj": obj.pronome,
		"intensidade_subs": intensidade_subs,
		"substantivo": subs.nome,
		"verbo_imperf": verbo_imperf,
		"adjetivo": adjetivo_correto,
		"verbo_neg": verbo_neg,
		"intensidade_forma": intensidade_forma,
		"verbo_inf": verbo_inf,
		"subst_art_def": subst_art_def # o/a
	}
	
	var ki = "{jogador} {verbo_perf} {prep_obj} {objeto} com {intensidade_subs} {substantivo}.".format(ctx)
	var sho = "{pronome_obj} {objeto} parecia que finalmente {verbo_imperf} {adjetivo}.".format(ctx)
	var ten = "Um dia {pronome_obj} {objeto} {verbo_neg} de forma {intensidade_forma}.".format(ctx)
	var ketsu = "Agora, só resta a {jogador} se {verbo_inf} com {subst_art_def} {substantivo} que ocorreu...".format(ctx)
	
	return [ki, sho, ten, ketsu]

#historia comum
func _generate_slice_of_life(jogador: String) -> Array[String]:
	var epoca = epocas.pick_random()
	var obj = objetos.pick_random() 
	var lugar = lugares.pick_random() 
	var subs = substantivos.pick_random() 
	var intens = intensidades.pick_random() 
	
	var intensidade_correta = intens["m"] if subs.genero == "m" else intens["f"]
	
	var ctx = {
		"jogador": jogador,
		"art_epoca": epoca.artigo,
		"epoca": epoca.nome,
		"adj_pos": adjetivos_positivos.pick_random(),
		"lugar_art": lugar.art_um,
		"lugar_nome": lugar.nome,
		"lugar_pronome": lugar.pronome,
		"verbo_gerundio": obj.verbo_gerundio.pick_random(),
		"objeto": obj.nome,
		"subst_art": subs.art_um,
		"intensidade": intensidade_correta,
		"substantivo": subs.nome
	}
	
	var ki = "{art_epoca} {epoca} começou até que bem {adj_pos} para {lugar_art} {lugar_nome} como {lugar_pronome}.".format(ctx)
	var sho = "{jogador} passou a {epoca} inteira {verbo_gerundio} o {objeto}.".format(ctx)
	var ten = "{subst_art} {intensidade} {substantivo} aconteceu naquele dia.".format(ctx)
	var ketsu = "{jogador} continuou a sua rotina como se nada tivesse acontecido...".format(ctx)
	
	return [ki, sho, ten, ketsu]

#historia final feliz
func _generate_mega_sena(jogador: String) -> Array[String]:
	var epoca = epocas.pick_random()
	var obj = objetos.pick_random()
	var obj_secundario = objetos.pick_random()
	var lugar = lugares.pick_random()
	var intens = intensidades.pick_random()
	
	var obj_gen = "m" if obj.art_um == "um" else "f"
	var obj2_gen = "m" if obj_secundario.art_um == "um" else "f"
	
	var intensidade_correta = intens[obj_gen]
	var valioso_correto = "valioso" if obj_gen == "m" else "valiosa"
	var art_def_obj = "o" if obj_gen == "m" else "a"
	var art_def_obj2 = "o" if obj2_gen == "m" else "a"
	
	var ctx = {
		"jogador": jogador,
		"art_epoca": epoca.artigo,
		"epoca": epoca.nome,
		"adj_pos": adjetivos_positivos.pick_random(),
		"lugar_art": lugar.art_um,
		"lugar_nome": lugar.nome,
		"lugar_pronome": lugar.pronome,
		"verbo_imperf": verbos_futuro_do_pret.pick_random(),
		"naquele_epoca": epoca.naquele,
		"objeto": obj.nome,
		"art_um_obj": obj.art_um,
		"pessoa": pessoas_arq.pick_random(),
		"intensidade": intensidade_correta,
		"valioso": valioso_correto,
		"art_def_obj": art_def_obj,
		"verbo_perf": verbos_pret_perf.pick_random(),
		"obj_2": obj_secundario.nome,
		"art_def_obj2": art_def_obj2
	}
	
	var ki = "{art_epoca} {epoca} começou até que bem {adj_pos} para {lugar_art} {lugar_nome} como {lugar_pronome}.".format(ctx)
	var sho = "{jogador} nem percebeu que algo poderia mudar {naquele_epoca} {epoca}".format(ctx)
	var ten = "De repente, {jogador} recebeu de um {pessoa} {art_um_obj} {objeto} {intensidade} e {valioso} que mudou a sua vida.".format(ctx)
	var ketsu = "Com {art_def_obj} {objeto}, {verbo_perf} {art_def_obj2} {obj_2} e continuou a sua rotina...".format(ctx)
	
	return [ki, sho, ten, ketsu]

# frames errados
func _generate_wrong_frames(amount: int, player_name) -> Array[String]:
	var wrong_frames: Array[String] = []
	
	for i in range(amount):
		var _hist_list_gen = []
		var format_choice = randi_range(1, 3)
		
		match format_choice:
			1: _hist_list_gen = _generate_tragic(player_name)
			2: _hist_list_gen = _generate_slice_of_life(player_name)
			3: _hist_list_gen = _generate_mega_sena(player_name)
		
		var _wrong_frame = _hist_list_gen.pick_random()
		wrong_frames.append(_wrong_frame)
		
	return wrong_frames
