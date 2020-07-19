extends KinematicBody2D

const MOVE_SPEED = 25
const TARGET_DIST_SQUARED = 16
const DEBATE_TIME = .75

enum {
	WANDER = 0,
	ARGUING = 2,
	TARGET = 1
}

#Timer used to randomize position
onready var timer := $"Idle Timer"
onready var bubble := $Bubble
onready var sprite := $Sprite

var team : int setget set_team
var state : int = WANDER setget set_state

#Random value used to determine idle walking and chance of being convinced
var patience : float

var warmup : float = 5

#Where does this person want to go
var target_pos : Vector2

var has_been_convinced : bool

func _ready() -> void:
	patience = rand_range(0,1)
	timer.wait_time = patience * 2 + 3
	find_target_pos()

#Manually set target position
func rally_people(pos) -> void:
	if team == Global.TEAM_ALLY or (team == Global.TEAM_NONE and randi()%2==0):
		target_pos = pos
		timer.start()
		warmup = 0

#Set the team of this player
func set_team(otherteam) -> void:
	var lastteam = team
	team = otherteam
	sprite.modulate = Global.team_color(team)

func set_state(_state) -> void:
	#Pause for a sec when changing states
	state = _state

#Find the position of our next target
func find_target_pos() -> void:
	if state == WANDER:
		target_pos = global_position + Vector2(rand_range(-256,256),rand_range(-256,256))
	elif state == TARGET:
		#Find all other people
		var others = get_tree().get_nodes_in_group("People")
		others.shuffle()
		#Find a random person with the opposite view as you
		for p in others:
			if p != self and p.team != team:
				target_pos = p.global_position + Vector2(rand_range(-128,128),rand_range(-128,128))
				return

#Move to target position
func _physics_process(delta) -> void:
	
	if warmup > 0: warmup -= delta
	
	if state == ARGUING: return
	
	#Get target position delta
	var offset = (target_pos - global_position)
	if offset.length_squared() > TARGET_DIST_SQUARED:
		#Move there
		move_and_slide(offset.normalized() * MOVE_SPEED)

#When we hit another person, what do we do?
func argue(other) -> void:
	if state != ARGUING and other != self and other.is_in_group("People") and warmup <= 0:
		if other.team != team and other.team != Global.TEAM_NONE:
			if other.state != ARGUING:
		
				set_state(ARGUING)
				other.set_state(ARGUING)
				
				bubble.global_position = (global_position + other.global_position) * 0.5
				bubble.visible = true
				
				#Wait a bit
				yield(get_tree().create_timer(DEBATE_TIME),"timeout")
				
				bubble.visible = false
				
				match team:
					#Yeah they don't care and are easily indoctrinated
					Global.TEAM_NONE:
						set_team(other.team)
					#These guys are harder to convince
					Global.TEAM_ALLY, Global.TEAM_ENEMY:
						#Sanity check so we don't run this twice
						if has_been_convinced:
							has_been_convinced = false
							return
						var convinced = randf() < other.patience
						if convinced:
							other.set_team(team)
						else:
							set_team(other.team)
				set_state(TARGET)
				other.set_state(TARGET)
	elif other.is_in_group("Wall"):
		find_target_pos()