extends LevelHandler


func _ready() -> void:
	level_max_waves = 7
	wave_data = ["HumanEnemy", 4]
	counters_visible = true
	change_labels()
