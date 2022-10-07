extends Node2D
class_name Bullet

var enemy
var tower_type
var t = 0.0
var damage: int
var effect: String
export var speed := 0.1
onready var impact_detector := $ImpactDetector
onready var hitbox := $HitBox
onready var sprite := $AnimatedSprite
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
func _ready():
	set_as_toplevel(true)
	$HitBox.damage = GameData.tower_data[tower_type]["damage"]
	if GameData.tower_data[tower_type]["effect"]:
		$HitBox.effect = GameData.tower_data[tower_type]["effect"]
	#impact_detector.connect("body_entered", self, "_on_impact")
	
	
func _physics_process(delta: float) -> void:
	
	if is_instance_valid(enemy):
		self.look_at(enemy.position)
		t += delta * speed
		self.position = self.position.linear_interpolate(enemy.position, t )
	else:
		self.queue_free()
		
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _on_ImpactDetector_area_entered(area: Area2D) -> void:
	# this needs to actually find the correct enemy that owns the area2d passed in
	#if is_instance_valid(enemy):
	#	enemy.on_hit(GameData.tower_data[tower_type]["damage"])
	self.queue_free()
