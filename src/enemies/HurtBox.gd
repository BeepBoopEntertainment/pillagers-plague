class_name HurtBox
extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _on_area_entered(hitbox: HitBox) -> void:
	if self.get_parent().get_parent().has_method("on_hit"):
		if hitbox.effect:
			self.get_parent().get_parent().on_hit(hitbox.damage, hitbox.effect)
		self.get_parent().get_parent().on_hit(hitbox.damage)
