extends KinematicBody2D

const MOVE_SPEED = 40

onready var rally_particles = $RallyParticles
onready var rally_timer = $RallyParticles/Timer
onready var rally_whistle = $Whistle

var is_arguing : bool = false

var team = Global.TEAM_ALLY

signal start_debate(player,target)

func _ready() -> void:
	get_node("Sprite").self_modulate = Global.TEAM_COLORS[team]

#Move around
func _physics_process(delta) -> void:
	if not is_arguing:
		var hor = Input.get_action_strength("right") - Input.get_action_strength("left")
		var ver = Input.get_action_strength("down") - Input.get_action_strength("up")
		move_and_slide(Vector2(hor,ver).normalized()*MOVE_SPEED)
		
		#Rally all people
		#Not sure if I'll keep this
		if Input.is_action_just_pressed("rally"):
			trigger_rally()

func trigger_rally() -> void:
	get_tree().call_group("People","rally_people",global_position)
	rally_particles.restart()
	rally_particles.emitting = true
	rally_timer.start()
	rally_whistle.play()
	yield(rally_timer,"timeout")
	rally_particles.emitting = false

#When we hit something
func argue(other) -> void:
	if not is_arguing:
		if other.is_in_group("People") and other.team != team:
			other.set_state(2)
			is_arguing = true
			emit_signal("start_debate",self,other)

#Stop moving, level is done
func stop_it_man(success) -> void:
	is_arguing = true