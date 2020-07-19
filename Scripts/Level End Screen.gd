extends Control

const FORMAT_STRING = """[center]
[color=#5DBCD2]Followers: %d[/color]
[color=red]Enemies: %d[/color]
Time Left: %d
------------
Score: %d
Press any key
[/center]"""

const FAILURE_STRING = """
[center]Press any button
to try again[/center]"""

#Get nodes
onready var score_display = $"Page/Score Display"
onready var success_texture = $Page/SuccessPanel/Success
onready var anim = $AnimationPlayer

signal anim_done

#Show the level end screen
func show_score(success) -> void:
	#Calculate score
	var score = Stats.followers - Stats.enemies + Stats.time_remaining
	Stats.total_score += score
	
	#Update display
	if success:
		score_display.bbcode_text = FORMAT_STRING % [Stats.followers, Stats.enemies, Stats.time_remaining, score]
	else:
		score_display.bbcode_text = FAILURE_STRING
		success_texture.rect_position.y -= 71
	
	#Show
	visible = true
	rect_position.y = 400
	anim.play("Show")
	
	yield(anim,"animation_finished")
	emit_signal("anim_done")