extends Node2D

const TIME_FORMAT_STRING : String = "%d:%02d"
const EXPOSITION_SCENE : String = "res://Levels/Exposition.tscn"

onready var Person = preload("res://Person.tscn")

onready var counter = $"UI Layer/Counter/HBox/CounterLabel"
onready var timer = $"UI Layer/Time"

export (int) var follower_goal : int
export(int) var total_people : int
export(int) var total_enemies : int
export(Vector2) var spawn_area : Vector2
export(int) var time_in_seconds : int
export(String) var next_scene_path : String

var follower_count : int = 0
var level_time_remaining : int

var level_over : bool = false
var won : bool = false

var hrt : bool = false

signal on_level_end(success)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_process_unhandled_input(false)
	Transition.trans_in()
	
	#Initialize level timer
	level_time_remaining = time_in_seconds
	
	#Update UI
	update_counter()
	update_timer()
	
	#Randomize everything
	randomize()
	
	#Get number of enemies to spawn
	var enemies = total_enemies
	
	#Instantiate people
	for i in range(total_people):
		var p = Person.instance()
		p.position = Vector2(rand_range(-spawn_area.x,spawn_area.x),rand_range(-spawn_area.y,spawn_area.y))
		add_child(p)
		p.set_team(Global.TEAM_ENEMY if enemies > 0 else Global.TEAM_NONE)
		if enemies > 0: enemies -= 1

#Called when the level is complete, either by the goal being reached or time running out
func level_complete(success:bool) -> void:
	level_over = true
	won = success
	if success:
		#Update stats
		Stats.time_remaining = level_time_remaining
		
		#Calculate people count
		var stat_followers = follower_count - 1
		var state_enemies = 0
		for person in get_tree().get_nodes_in_group("People"):
			match person.team:
				Global.TEAM_ALLY: stat_followers += 1
				Global.TEAM_ENEMY: state_enemies += 1
		Stats.followers = stat_followers
		Stats.enemies = state_enemies
	
	emit_signal("on_level_end",success)

#Ui updating functions
func update_timer() -> void:
	timer.text = TIME_FORMAT_STRING % [level_time_remaining / 60, level_time_remaining % 60]

func update_counter() -> void:
	counter.text = str(follower_count)+"/"+str(follower_goal)

#Called when a follower reaches the goal
func on_follower_exit() -> void:
	if not level_over:
		follower_count += 1
		update_counter()
		if follower_count >= follower_goal:
			level_complete(true)

#Called when a second passes
func on_second_pass() -> void:
	if not level_over:
		level_time_remaining -= 1
		update_timer()
		if level_time_remaining <= 0:
			level_complete(false)

#Used to determine what to do next
func _unhandled_input(event) -> void:
	if level_over and not hrt:
		hrt = true
		Transition.trans_out()
		yield(Transition,"transition_done")
		if won:
			#Next level
			Global.level_index += 1
			get_tree().change_scene(EXPOSITION_SCENE)
		else:
			get_tree().reload_current_scene()