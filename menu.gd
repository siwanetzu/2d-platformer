extends Control



func _on_play_button_pressed() -> void:
	PlayerStats.score = 0
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn") # Replace with function body.
	
	



func _on_quit_button_pressed() -> void:
	get_tree().quit()
