extends LevelHandler


func _ready() -> void:
	wave_data = ["HumanEnemy", 10]
	print(wave_data[1])
	$AnimationPlayer.play("Titlecard")

	
func _on_QuitButton_pressed() -> void:
	get_tree().quit()
