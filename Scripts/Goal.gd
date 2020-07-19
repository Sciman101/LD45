extends Area2D

signal follower_exited

func _on_Goal_body_entered(body):
	if body.is_in_group("People"): 
		if body.team == Global.TEAM_ALLY:
			#Are they an ally?
			body.queue_free()
			emit_signal("follower_exited")
		else:
			#Go somewhere else!!
			body.find_target_pos()