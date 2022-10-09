extends Node2D
class_name Tower
var type: String
var built: bool = false
var enemy: Node
var ready: bool = true
# var check_for_enemies: bool = false 

func _ready():
	if built:
		$Range/CollisionShape2D.get_shape().radius = 0.5 * GameData.tower_data[type].range


func _physics_process(_delta: float) -> void:

	if built:
		select_enemy()
		turn()
		if ready:
			fire()
	else:
		enemy = null
	

func turn() -> void:
	if is_instance_valid(enemy):
		get_node("Turret").look_at(enemy.position)
	else:
		enemy = null

func select_enemy() -> void:
	var enemy_progress_map = {}
	for i in $Range.get_overlapping_areas():
		if is_instance_valid(i):
			enemy_progress_map[i.get_parent().get_parent().offset] = i.get_parent().get_parent()
			var max_offset = enemy_progress_map.keys().max()
			enemy = enemy_progress_map[max_offset]
		else:
			enemy = null

		
	
func fire() -> void:
	ready = false
	if is_instance_valid(enemy):
		if enemy.health > 0:
			var new_bullet = load("res://src/towers/" + GameData.tower_data[type].ammo + ".tscn").instance()
			new_bullet.enemy = enemy
			new_bullet.tower_type = type
			new_bullet.position = Vector2(self.position.x + 32.0, self.position.y + 32.0)
			add_child(new_bullet, true)
			yield(get_tree().create_timer(GameData.tower_data[type]["rof"]), "timeout")
	else:
		enemy = null
	ready = true
	
	
func _on_Range_area_entered(area: Area2D) -> void:
	# check_for_enemies = true
	pass
	
	
func _on_Range_area_exited(area: Area2D) -> void:
	# check_for_enemies = false
	pass

