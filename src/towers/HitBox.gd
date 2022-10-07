extends Area2D
class_name HitBox

onready var collision_shape := $CollisionShape2D
var damage: int
var effect: String
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func _init() -> void:
#	collision_mask = 0
#	collision_layer = 3
	pass
	
func set_disabled(is_disabled: bool) -> void:
	collision_shape.set_deferred("disabled", is_disabled)
