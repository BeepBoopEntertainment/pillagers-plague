extends PathFollow2D



var prev_pos: Vector2
var timer_started: bool = false
var health: int = 3

var _speed: float = 150.0
const _max_speed: float = 150.0
var direction = "north"
var in_castle: bool = false
var status: Dictionary
onready var color = self.modulate


onready var health_bar = get_node("HealthBar")

func _physics_process(delta: float) -> void:
	if in_castle:
		self.queue_free()
		
	if health > 0:
		status_check()
		move(delta)

func move(delta: float) -> void:
	if prev_pos.x != position.x:
		var diffx: float = position.x - prev_pos.x
		if diffx < -1:
			$KinematicBody2D/AnimatedSprite.animation = "human_walking_west"
			direction = "west"
		if diffx > 1:
			$KinematicBody2D/AnimatedSprite.animation = "human_walking_east"
			direction = "east"
		prev_pos.x = position.x
	if prev_pos.y != position.y:
		var diffy: float = position.y - prev_pos.y
		if diffy < -1:
			$KinematicBody2D/AnimatedSprite.animation = "human_walking_north"
			direction = "north"
		if diffy > 1:
			$KinematicBody2D/AnimatedSprite.animation = "human_walking_south"
			direction = "south"
		prev_pos.y = position.y
	
	set_offset(get_offset() + _speed * delta )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedTimer.visible = false
	health_bar.value = health
	health_bar.max_value = health
	$KinematicBody2D/AnimatedSprite.animation = "human_walking_south"
	$KinematicBody2D/AnimatedSprite.playing = true
	prev_pos.x = position.x
	prev_pos.y = position.y
	
# handle animations finishing
func _on_AnimatedSprite_animation_finished() -> void:
	match $KinematicBody2D/AnimatedSprite.animation:
		"human_death":
			$KinematicBody2D/AnimatedSprite.animation = "dead"
			$AnimatedTimer.visible = true
			$AnimatedTimer.frame = 0
			$AnimatedTimer.play()
			yield(get_tree().create_timer(3.0), "timeout")
			var zombie = load("res://src/enemies/Zombie.tscn").instance()
			zombie.direction = direction
			zombie.offset = offset
			get_parent().add_child(zombie, true)
			self.queue_free()
			
			

func on_hit(damage: int, effect: String = "None") -> void:
	health = health - damage
	health_bar.value = health
	if health <= 0:
		_speed = 0
		$KinematicBody2D/HitBox.set_deferred("visible", false)
		$KinematicBody2D/HitBox/CollisionShape2D.set_deferred("disabled", true)
		$KinematicBody2D/AnimatedSprite.animation = "human_death"
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





func _on_CollisionShape2D_child_entered_tree(node):
	pass # Replace with function body.


func status_check():
	if  "Frozen" in status.keys() && status["Frozen"]:
		if _speed == _max_speed:
			_speed = _speed * 0.5
			self.modulate = Color("69a2ff")
			
func undo_status(effect: String):
	if effect == "Frozen":
		_speed = _max_speed
		self.modulate = Color(color)
		

func _status_expire(effect: String):
	undo_status(effect)
	status[effect] = false
