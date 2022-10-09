extends PathFollow2D

signal add_money

export var _speed: float = 100.0
const _max_speed: float = 100.0
export var health: int = 6

var prev_pos: Vector2
var direction
var in_castle: bool = false
var status: Dictionary

onready var color = self.modulate
onready var health_bar = get_node("HealthBar")

func _physics_process(delta: float) -> void:
	if in_castle:
		self.queue_free()
		

	if health > 0 && $KinematicBody2D/AnimatedSprite.animation != "revive":
		status_check()
		move(delta)
	

func move(delta: float) -> void:
	if prev_pos.x != position.x:
		var diffx: float = position.x - prev_pos.x
		if diffx < -1:
			$KinematicBody2D/AnimatedSprite.animation = "zombie_walking_west"
			direction = "west"
		if diffx > 1:
			$KinematicBody2D/AnimatedSprite.animation ="zombie_walking_east"
			direction = "east"
		prev_pos.x = position.x
	if prev_pos.y != position.y:
		var diffy: float = position.y - prev_pos.y
		if diffy < -1:
			$KinematicBody2D/AnimatedSprite.animation = "zombie_walking_north"
			direction = "north"
		if diffy > 1:
			$KinematicBody2D/AnimatedSprite.animation = "zombie_walking_south"
			direction = "south"
		prev_pos.y = position.y
	
	set_offset(get_offset() + _speed * delta )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.value = health
	health_bar.max_value = health
	$KinematicBody2D/AnimatedSprite.animation = "revive"
	$KinematicBody2D/AnimatedSprite.playing = true
	prev_pos.x = position.x
	prev_pos.y = position.y

	
# handle animations finishing
func _on_AnimatedSprite_animation_finished() -> void:
	match $KinematicBody2D/AnimatedSprite.animation:
		"zombie_death":
			$KinematicBody2D/AnimatedSprite.animation = "dead"
			emit_signal("add_money")
			var world: Node = get_tree().get_root().get_node("World")
			world.enemies_in_wave = world.enemies_in_wave - 1
			world.update_label(world.enemies_in_wave, "Creeps")
			self.queue_free()
		"revive":
			_speed = 100
			health_bar.value = health
			health_bar.max_value = health
			$KinematicBody2D/AnimatedSprite.animation = "zombie_walking_" + direction

			

func on_hit(damage: int, effect: String = "None") -> void:
	health = health - damage
	health_bar.value = health
	if health <= 0:
		_speed = 0
		$KinematicBody2D/AnimatedSprite.animation = "zombie_death"
	if effect != "None":
		status[effect] = true
		var status_timer = self.get_node_or_null(effect + "_Timer")
		if !status_timer:
			status_timer = Timer.new()
			status_timer.one_shot = true
			status_timer.set_name(effect + "_Timer")
			status_timer.connect("timeout", self, "_status_expire", [effect])
			add_child(status_timer, true)
		status_timer.start(GameData.status_data[effect].duration)

func _on_Zombie_add_money():
	GameData.gold += 1
	get_tree().get_root().get_node("World").update_label(GameData.gold, "Gold")

func status_check():
	if  "Frozen" in status.keys() && status["Frozen"]:
		if _speed == _max_speed:
			_speed = _speed * 0.5
			self.modulate = Color("69a2ff")
			
func undo_status(effect: String):
	if effect == "Frozen":
		_speed = _max_speed
		self.modulate = Color(color)
		
func _on_CollisionShape2D_child_entered_tree(node):
	pass # Replace with function body.

func _status_expire(effect: String):
	undo_status(effect)
	status[effect] = false
