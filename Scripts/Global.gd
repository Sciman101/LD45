extends Node

const TEAM_COLORS = [Color.dimgray,Color.cornflower,Color.firebrick]

const LEVELS = [
	"res://Levels/Level1.tscn",
	"res://Levels/Level2.tscn",
	"res://Levels/Level3.tscn",
	"res://Levels/Level4.tscn"
]

const GOALS = [
	"DOGS SHOULD VOTE",
	"WINDOWS > MAC",
	"YOU SHOULD SUPPORT LOCAL ARTISTS",
	"JERRY SHOULD DO THE DISHES",
	"A VAUGE POLITICAL IDEOLOGY",
	"THE LUDUM DARE SHOULD BE 4 DAYS",
	"PINEAPPLE BELONGS ON PIZZA",
	"PEPSI AND COKE ARE THE SAME",
	"YOU ARE INDECISIVE",
	"THIS GAME IS AMAZING"
]
var goal_num : int = 0

var level_index : int = 0

enum {
	TEAM_ALLY = 1,
	TEAM_ENEMY = 2,
	TEAM_NONE = 0
}

func _ready() -> void:
	randomize()
	goal_num = randi() % GOALS.size()

func team_color(team):
	return TEAM_COLORS[team]

func next_level() -> String:
	return LEVELS[level_index]