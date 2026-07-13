extends Node

# Historia completa do jogador
var recovered_stories: Array[String] = []
var player_name: String = "Lindeberg"

func add_to_history(story_acts: Array):
	var full_text = " ".join(story_acts)
	recovered_stories.append(full_text)

func reset_game():
	recovered_stories.clear()
