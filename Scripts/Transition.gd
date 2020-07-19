extends CanvasLayer

onready var tween = $Tween
onready var rect = $ColorRect
const TRANSPARENT = Color(0,0,0,0)

signal transition_done

func trans_in() -> void:
	tween.interpolate_property(rect,"color",Color.black,TRANSPARENT,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()

func trans_out() -> void:
	tween.interpolate_property(rect,"color",TRANSPARENT,Color.black,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()