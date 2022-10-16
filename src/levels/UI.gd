extends CanvasLayer


func _ready() -> void:
	$HUD/BuildBar/Ballistae/BallistaeCost.text = String(GameData.tower_data.Ballistae1.cost)
	$HUD/BuildBar/Catapult/CatapultCost.text = String(GameData.tower_data.Catapult1.cost)
	$HUD/BuildBar/IceTower/IceTowerCost.text = String(GameData.tower_data.IceTower1.cost)
	$HUD/BuildBar.visible = false

func set_tower_preview(tower_type: String, mouse_position: Vector2) -> void:
	var drag_tower = load("res://src/towers/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ca3aa100")
	var range_texture = Sprite.new()
	range_texture.position = Vector2(32,32)
	var scaling = GameData.tower_data[tower_type].range / 500.0
	range_texture.scale = Vector2(scaling, scaling)
	var texture = load("res://assets/ui/range_preview.png")
	range_texture.texture = texture
	range_texture.modulate = Color("ca3aa100")
	
	var control = Control.new()
	
	control.add_child(drag_tower, true)
	control.add_child(range_texture, true)
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	var world = get_tree().get_root().get_node_or_null("World")
	var tower = world.get_node_or_null("TowerPreview")
	world.add_child(control, true)
	world.move_child(tower, 0)
	control.set_as_toplevel(true)
	
	
func update_tower_preview(new_position: Vector2, color: String, sufficient_funds: bool) -> void:
	var tower_preview = get_tree().get_root().get_node_or_null("World/TowerPreview")
	if tower_preview:
		tower_preview.rect_position = new_position
	else:
		return
	if get_tree().get_root().get_node("World/TowerPreview/DragTower").modulate != Color(color):
		get_tree().get_root().get_node("World/TowerPreview/DragTower").modulate = Color(color)
		get_tree().get_root().get_node("World/TowerPreview/Sprite").modulate = Color(color)
	if sufficient_funds && get_tree().get_root().get_node_or_null("World/TowerPreview/Label"):
		get_tree().get_root().get_node("World/TowerPreview/Label").visible = false
	if !sufficient_funds && not get_tree().get_root().get_node_or_null("World/TowerPreview/Label"):
		var insufficient_funds_label = Label.new()
		insufficient_funds_label.text = "Not enough dosh!"
		get_tree().get_root().get_node("World/TowerPreview").add_child(insufficient_funds_label, true)


func _on_PausePlay_pressed() -> void:
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if get_tree().is_paused():
		get_tree().paused = false
	elif get_parent().current_wave == 0:
		get_parent().current_wave += 1
		get_parent().start_next_wave()
	else:
		get_tree().paused = true

func _on_SpeedUp_pressed() -> void:
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)

