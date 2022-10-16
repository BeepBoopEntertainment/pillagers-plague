extends Control

var scene: String = "res://src/levels/LevelOne.tscn"


func _on_StartButton_pressed() -> void:
	GameData.hp = 5
	GameData.gold = 5
	if get_tree().change_scene(scene) != OK:
		print('Error loading LevelOne')


# @todo - add options scene menu
func _on_OptionsButton_pressed() -> void:
	pass

