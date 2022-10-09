extends Node2D
class_name LevelHandler


var map_node: Node
var build_mode: bool = false
var build_valid: bool = false
var build_tile: Vector2
var build_location: Vector2
var build_type: String
var current_wave: int = 0
var enemies_in_wave: int = 0
var wave_data: Array
var start: bool = false
var max_waves: int = 0
var counters_visible: bool = false
var spawn_fluctuator = RandomNumberGenerator.new()
var paths: Array = []
var is_build_menu_minimized: bool = true
onready var build_menu = $UI/HUD/BuildBar
onready var build_menu_hider = $UI/HUD/BuildMenuHider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_node = get_node_or_null("GameMap")
	if map_node == null:
		map_node = self
	paths.append_array(get_paths())
	for i in get_tree().get_nodes_in_group("build_menu_control"):
		i.connect("pressed", self, "hide_or_unhide_build_menu")
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "initiate_build_mode", [i.get_name()])
	if map_node != self:
		yield(get_tree().create_timer(2.0),"timeout")
	start_next_wave()

func hide_or_unhide_build_menu() -> void:
	if is_build_menu_minimized:
		build_menu_hider.visible = false
		build_menu.visible = true
		is_build_menu_minimized = false
	else:
		build_menu_hider.visible = true
		build_menu.visible = false
		is_build_menu_minimized = true
		
func _process(_delta: float) -> void:
	if build_mode:
		update_tower_preview()
	
	var max_waves: Label = get_tree().get_root().get_node_or_null("World/UI/HUD/InfoBar/MaxWave")
	var cont: bool = false
	if max_waves != null:
		if current_wave <= int(max_waves.text):
			cont = true
		else:
			match GameData.current_level:
				1:
					GameData.current_level += 1
					get_tree().change_scene("res://src/levels/LevelTwo.tscn")
				2:
					# Show nice Win screen
					GameData.current_level = 1
					get_tree().change_scene("res://src/game_over/YouWin.tscn")
			return
			
	if enemies_in_wave == 0 and start and cont:
		start_next_wave()
		start = false	


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().get_root().get_node_or_null("StartScene") != null:
		return

	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true and GameData.gold > 0:
		verify_and_build()
		cancel_build_mode()

	
func initiate_build_mode(tower_type: String) -> void:
	if build_mode:
		build_mode = false
		if build_valid:
			verify_and_build()
			cancel_build_mode()
			return
		cancel_build_mode()
	build_type = tower_type + "1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())


func update_tower_preview() -> void:
	if get_tree().get_root().get_node_or_null("StartScene") != null:
		return
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)

	var sufficient_funds = GameData.gold >= GameData.tower_data[build_type].cost
	
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1 and sufficient_funds:
		get_node("UI").update_tower_preview(tile_position, "ca3aa100", sufficient_funds)
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position, "ccf02222", sufficient_funds)
		build_valid = false

	
func cancel_build_mode() -> void:
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").queue_free()

	
func verify_and_build() -> void:
	if build_valid:
		# Check player has enough gold
		var new_tower = load("res://src/towers/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.type = build_type
		new_tower.built = true
		map_node.get_node("Turrets").add_child(new_tower, true)
		map_node.get_node("TowerExclusion").set_cellv(build_tile, 4)
		GameData.gold -= GameData.tower_data[build_type].cost
		update_label(GameData.gold, "Gold")



func start_next_wave() -> void:
	current_wave += 1
	yield(get_tree().create_timer(0.2),"timeout")
	update_label(wave_data[1] * paths.size(), "MaxCreeps")
	update_label(0, "Creeps")
	spawn_enemies()
	update_label(current_wave, "Wave")
	wave_data[1] += current_wave * 2

func get_paths() -> Array:
	var i: int = 1
	var is_finished: bool = false
	var local_paths: Array = []
	while (!is_finished):
		var name: Array = get_path_name(i)
		if !name[0]:
			is_finished = true
			continue
	
		local_paths.append(name[1])
		i += 1
	
	return local_paths


func get_path_name(i: int) -> Array:
	var name: String = gen_name(i)
	if map_node.get_node_or_null(name) != null:
		return [true, name]
		
	return [false, name]


func gen_name(i: int) -> String:
	return "Path" if i == 1 else "Path" + str(i)


func spawn_enemies() -> void:
	paths.shuffle()
	for path_name in paths:
		for _k in range(wave_data[1]):
			var path_node: Path2D = map_node.get_node(path_name)
			var new_enemy = load("res://src/enemies/" + wave_data[0] + ".tscn").instance()
			path_node.add_child(new_enemy, true)
			enemies_in_wave = enemies_in_wave + 1
			update_label(enemies_in_wave, "Creeps")
			var fluctuation = spawn_fluctuator.randf_range(0.2, 1.0)
			yield(get_tree().create_timer(fluctuation), "timeout")
	start = true

	
func change_labels() -> void:
	update_label(max_waves, "MaxWave")
	update_label(wave_data[1], "MaxCreeps")
	update_label(GameData.hp, "Health")
		
func update_label(num: int, label_str: String) -> void:
	var label: Label = get_tree().get_root().get_node_or_null("World/UI/HUD/InfoBar/" + label_str)
	if label != null:
		label.text = String(num)
