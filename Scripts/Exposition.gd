extends Control

onready var text = $Label
onready var timer = $Timer

const LORE = [
	"The people of this town are blind.\nThey don't see what the government is hinding.\nBut you do.\nYou believe %s\nAnd you're going to convince everyone\nelse of that too. But you need supporters...\nMaybe start at the park.",
	"Many people agree with your beliefs.\nBut some don't.\nYou've been lucky enough to avoid them,\nbut protesting in the streets you found some\nYou may as well try and change their minds.",
	"More and more people are agreeing with your ideas.\nAnd more and more are disagreeing.\nDon't let negative opinion spread too far.",
	"You've reached the top - Town Hall.\nIf you can persuade everyone here,\nthen everyone will side with you.\nGood luck!",
	"Finally, you've achieved your goal.\nEveryone thinks %s.\nThough now you're not so sure yourself...\n\nThanks for playing!\nFinal Score: %s"
]

func _ready() -> void:
	Transition.trans_in()
	
	text.text = LORE[Global.level_index]
	
	if Global.level_index == 0:
		text.text = text.text % Global.GOALS[Global.goal_num]
	elif Global.level_index == 4:
		text.text = text.text % [Global.GOALS[Global.goal_num],str(Stats.total_score)]
	
	text.visible_characters = 0

func show_new_char() -> void:
	#Change wait time
	timer.start(0.1)
	
	#If we're done, go to next screen
	if text.percent_visible == 1:
		timer.start(3 if Global.level_index != 4 else 10)
		#Hacky solution
		timer.disconnect("timeout",self,"show_new_char")
		yield(timer,"timeout")
		#Go to next level
		timer.stop()
		Transition.trans_out()
		yield(Transition,"transition_done")
		if Global.level_index < 4:
			get_tree().change_scene(Global.next_level())
		else:
			get_tree().quit()

	#Show another character
	text.visible_characters += 1