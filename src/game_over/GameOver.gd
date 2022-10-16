extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("drop")
	pass # Replace with function body.

func _on_QuitButton_pressed() -> void:
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_StartButton_pressed():
	GameData.hp = 5
	GameData.gold = 5
	GameData.current_level = 1
	get_tree().change_scene("res://src/levels/LevelOne.tscn")
