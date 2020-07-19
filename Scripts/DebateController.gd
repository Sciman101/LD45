extends Control

onready var animation = $AnimationPlayer

onready var arguer = $Characters/Arguer
onready var arguer_speech = $ArguerSpeechBubble
onready var player_speech = $PlayerSpeechBubble
onready var timer = $Timer
onready var clock = $Clock

var ready_for_player : bool = false

var debate_timer : float
var debate_timer_max : float

var target_person
var player_char

var ver_prev
var hor_prev

func _ready() -> void:
	set_process_unhandled_input(true)

func on_debate_start(player,target) -> void:
	
	arguer_speech.clear()
	player_speech.clear()
	
	ver_prev = 0
	hor_prev = 0
	
	clock.value = 0
	
	target_person = target
	player_char = player
	
	ready_for_player = false
	
	arguer.modulate = Global.TEAM_COLORS[target.team]
	arguer_speech.get_node("ArrowContainer").modulate = arguer.modulate
	arguer_speech.set_pitch(0.5+target.patience)
	
	animation.play("Fade In")
	yield(animation,"animation_finished")
	
	#Add a bunch of random arrows
	var count = 2
	if target.team == Global.TEAM_ENEMY: count = 3
	for i in range(count+(randi()%2)):
		arguer_speech.add_arrow(randi()%4) #Add a random arrow
		timer.start(.1)
		yield(timer,"timeout")
	
	ready_for_player = true
	debate_timer_max = (1.5 + target.patience * 1.5) * (0.75 if count == 4 else 1)
	debate_timer = debate_timer_max

func _process(delta) -> void:
	if ready_for_player:
		debate_timer -= delta
		clock.value = 100 - (debate_timer/debate_timer_max) * 100
		if debate_timer <= 0:
			end_debate()

func _unhandled_input(event) -> void:
	
	if not ready_for_player or not visible: return
	if event.is_echo(): return
	
	#Determine what to do based on button input
	if event.is_action_pressed("right") and hor_prev != 1:
		player_speech.add_arrow(0)
	elif event.is_action_pressed("up") and ver_prev != -1:
		player_speech.add_arrow(3)
	elif event.is_action_pressed("left") and hor_prev != -1:
		player_speech.add_arrow(2)
	elif event.is_action_pressed("down") and ver_prev != 1:
		player_speech.add_arrow(1)
	#Update previous input values
	hor_prev = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
	ver_prev = sign(Input.get_action_strength("down") - Input.get_action_strength("up"))
	
	#Check if we're done
	if player_speech.arrow_directions.size() == arguer_speech.arrow_directions.size():
		ready_for_player = false
		timer.start(0.5)
		yield(timer,"timeout")
		end_debate()

#End the debate
func end_debate() -> void:
	ready_for_player = false
	#Check for a match
	var success = true
	if player_speech.arrow_directions.size() == arguer_speech.arrow_directions.size():
		for i in range(player_speech.arrow_directions.size()):
			if player_speech.arrow_directions[i] != arguer_speech.arrow_directions[i]:
				success = false
				break
	else:
		success = false
	
	#Did I win?
	if success:
		target_person.set_team(Global.TEAM_ALLY)
		target_person.set_state(1)
	else:
		target_person.set_state(0)
	#Let them go
	player_char.is_arguing = false
	visible = false

func debate_end():
	pass # Replace with function body.
