extends Bullet

func _on_ImpactDetector_area_entered(area: Area2D) -> void:
	hitbox.set_disabled(false)
	get_tree().create_timer(0.1).connect("timeout", self, "_disable_hitbox")
	sprite.visible = false
	yield(get_tree().create_timer(0.1), "timeout")
	self.queue_free()
	
func _disable_hitbox():
	hitbox.set_disabled(true)
